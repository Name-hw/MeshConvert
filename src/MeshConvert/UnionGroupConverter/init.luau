--!native
--!strict
local PartsGroupConverter = {}
local Root = script.Parent
local Parallelizer = require(Root.Parallelizer)
local Types = require(Root.Types)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData
type Options = Types.Options

function PartsGroupConverter.convert(ParsedData: ParsedData, options: Options?)
	local Folder = Instance.new("Folder", script)
	Folder.Name = "_Folder"

	local ActorFolder = Instance.new("Folder", Folder)
	ActorFolder.Name = "_ActorFolder"
	local PartsFolder = Instance.new("Folder", Folder)
	PartsFolder.Name = "_PartsFolder"

	local UnionGroup = Instance.new("Model", Folder)
	UnionGroup.Name = "MeshConvert_UnionGroup"

	local partAmountInUnion = 30
	local isSucceeded = false

	if options then
		if options.partAmountInUnion then
			partAmountInUnion = options.partAmountInUnion
		end
	end

	local threadCount = math.ceil(#ParsedData.f / 120)
	local actorCount = math.ceil(threadCount / 2)
	local Scheduler = Parallelizer.CreateJobScheduler(script.Folder.ActorFolder.Actor.parallelWorker, actorCount, ActorFolder)

	task.wait()

	local UnionGroupConvertInstruction = Parallelizer.CreateInstructionData({ actorCount, ParsedData :: any, partAmountInUnion })

	Scheduler:DispatchEquallyAsync("UnionGroupConvert", threadCount, function(result)
		Scheduler:Destroy()
		ActorFolder:Destroy()

		isSucceeded = true
	end, UnionGroupConvertInstruction)

	while task.wait() do
		if isSucceeded then
			UnionGroup.Parent = script

			Folder:Destroy()
			break
		end
	end

	return UnionGroup
end

return PartsGroupConverter
