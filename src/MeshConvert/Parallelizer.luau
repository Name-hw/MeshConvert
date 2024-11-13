--[[
	| Parallelizer � v0.1.6a
	| Released in the 21st of September, 2024 by @Artzified
	| Licensed under the MIT License
]]

local Parallelizer = {}
local JobScheduler = {}
local InstructionData = {}

type AllowedInstructionValues = Vector2 | Vector3 | CFrame | Color3 | UDim | UDim2 | number | boolean | string
type InstructionTableData = { [number]: AllowedInstructionValues | InstructionTableData }

type InstructionData = {
	Data: SharedTable,
	SetData: (self: InstructionData, newData: InstructionTableData) -> nil,
	GetData: (self: InstructionData) -> InstructionTableData,
}

type JobScheduler = {
	Actors: { Actor },
	PacketBindable: BindableEvent,
	DispatchEquallyAsync: (self: JobScheduler, threadName: string, threadCount: number, callback: (result) -> nil, instructionData: InstructionData?) -> nil,
	DispatchAsync: (self: JobScheduler, threadName: string, threadCount: number, batchSize: number, callback: (result) -> nil, instructionData: InstructionData?) -> nil,
	Destroy: (self: JobScheduler) -> nil,
}

function Parallelizer.CreateInstructionData(data: InstructionTableData): InstructionData
	return setmetatable({ Data = SharedTable.new(data or {}) }, { __index = InstructionData })
end

function Parallelizer.CreateThread(actor: Actor, threadName: string, callback: (threadId: number, instructionTable: SharedTable) -> any)
	actor:BindToMessageParallel(threadName, function(threadCount: number, dispatchId: number, batchSize: number, packetBindable: BindableEvent, instructionTable: SharedTable?)
		for i = dispatchId, math.min(dispatchId + (batchSize - 1), threadCount) do
			local response = { callback(i, instructionTable) }

			if #response > 0 then
				packetBindable:Fire(i, response)
			else
				warn(`[Parallelizer] Thread "{threadName}" with dispatch id of {i} is missing a return value`)
			end
		end
	end)
end

function Parallelizer.CreateJobScheduler(jobScript: Script | LocalScript, actorCount: number, actorStorage: Instance): JobScheduler
	local actors = table.create(actorCount)

	for i = 1, actorCount do
		local actor = Instance.new("Actor")
		local jobScriptClone = jobScript:Clone()
		actor.Parent = actorStorage
		jobScriptClone.Parent = actor
		jobScriptClone.Enabled = true

		actors[i] = actor

		if i % 4 == 0 then
			task.wait()
		end
	end

	return setmetatable({
		Actors = actors,
		PacketBindable = Instance.new("BindableEvent"),
	}, { __index = JobScheduler })
end

-- Instruction Data
function InstructionData:SetData(newData: InstructionTableData)
	self.Data = SharedTable.new(newData)
end

function InstructionData:GetData(): InstructionData
	return self.Data
end

-- Job Scheduler
function JobScheduler:DispatchEquallyAsync(threadName: string, threadCount: number, callback: (result) -> nil, instData: InstructionData?)
	self:DispatchAsync(threadName, threadCount, threadCount // #self.Actors, callback, instData)
end

function JobScheduler:DispatchAsync(threadName: string, threadCount: number, batchSize: number, callback: (result) -> nil, instData: InstructionData?)
	batchSize = math.max(batchSize, 1)

	local data = if instData then instData.Data else nil
	local actorIndex = 1

	-- Dispatch on the next resumption cycle
	return task.defer(function()
		for i = 1, threadCount, batchSize do
			self.Actors[actorIndex]:SendMessage(threadName, threadCount, i, batchSize, self.PacketBindable, data)

			actorIndex = (actorIndex % #self.Actors) + 1
		end

		local connection
		local count = 0

		local result = {}
		connection = self.PacketBindable.Event:Connect(function(id: number, response)
			local baseIndex = ((id - 1) * #response)

			-- Tried using table.move, got slower by 50ms
			for i, v in response do
				result[baseIndex + i] = v
			end
			count += 1

			if count == threadCount then
				connection:Disconnect()
				callback(result)
			end
		end)
	end)
end

function JobScheduler:Destroy()
	for _, actor in self.Actors do
		actor:Destroy()
	end

	self.Actors = nil
	self.PacketBindable:Destroy()

	self = nil
end

return Parallelizer
