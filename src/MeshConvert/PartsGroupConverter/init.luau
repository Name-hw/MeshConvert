--!strict
local PartsGroupConverter = {}
local Root = script.Parent
local Parallelizer = require(Root.Parallelizer)
local Types = require(Root.Types)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

function PartsGroupConverter.convert(ParsedData: ParsedData)
	local newActorFolder = Instance.new("Folder", script)
	newActorFolder.Name = "_ActorFolder"
	local PartsGroup = Instance.new("Model", newActorFolder)
	PartsGroup.Name = "MeshConvert_PartsGroup"

	local isSucceeded = false
	local threadCount = math.ceil(#ParsedData.f / 120)
	local actorCount = math.ceil(threadCount / 2)
	local Scheduler = Parallelizer.CreateJobScheduler(script.ActorFolder.Actor.parallelWorker, actorCount, newActorFolder)

	task.wait()

	local PartsGroupConvertInstruction = Parallelizer.CreateInstructionData({ actorCount, ParsedData } :: Parallelizer.InstructionTableData)

	Scheduler:DispatchEquallyAsync("PartsGroupConvert", threadCount, function(result)
		Scheduler:Destroy()

		isSucceeded = true
	end, PartsGroupConvertInstruction)

	while task.wait() do
		if isSucceeded then
			PartsGroup.Parent = script

			newActorFolder:Destroy()
			break
		end
	end

	return PartsGroup
end

return PartsGroupConverter
