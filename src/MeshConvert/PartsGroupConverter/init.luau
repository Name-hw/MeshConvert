--!strict
local PartsGroupConverter = {}
local Root = script.Parent
local Parallelizer = require(Root.Parallelizer)
local Types = require(Root.Types)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

function PartsGroupConverter.convert(ParsedData: ParsedData)
	local newActorFolder = Instance.new("Folder", script)
	local PartsGroup = Instance.new("Model", newActorFolder)
	PartsGroup.Name = "MeshConvert_PartsGroup"

	local threadCount = math.ceil(#ParsedData.f / 120)
	local Scheduler = Parallelizer.CreateJobScheduler(
		script.ActorFolder.Actor.parallelWorker,
		math.ceil(threadCount / 2),
		newActorFolder
	)
	local PartsGroupConvertInstruction = Parallelizer.CreateInstructionData(ParsedData)

	Scheduler:DispatchEquallyAsync("PartsGroupConvert", threadCount, function(result)
		Scheduler:Destroy()
	end, PartsGroupConvertInstruction)

	return PartsGroup
end

return PartsGroupConverter
