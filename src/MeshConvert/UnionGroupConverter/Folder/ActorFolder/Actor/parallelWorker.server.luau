--!strict
local Actor = script:GetActor() :: Actor

if not Actor then
	return
end

local Root = script.Parent.Parent.Parent.Parent.Parent
local Parallelizer = require(Root.Parallelizer)
local Types = require(Root.Types)
local drawFace = require(Root.drawFace)
local UnionGroup = script.Parent.Parent.Parent:FindFirstChild("MeshConvert_UnionGroup")
local PartsFolder = script.Parent.Parent.Parent:FindFirstChild("_PartsFolder")

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

Parallelizer.CreateThread(Actor, "UnionGroupConvert", function(id: number, instruction: SharedTable)
	local actorCount: number = instruction[1]
	local ParsedData: ParsedData | SharedTable = instruction[2]
	local partAmountInUnion: number = instruction[3]
	local endIndex = math.min(id * 120, SharedTable.size(ParsedData.f))
	local Parts: { BasePart } = {}

	for index = 1 + (id - 1) * 120, endIndex, 1 do
		task.spawn(function()
			local FaceData: FaceData | SharedTable = ParsedData.f[index]

			if SharedTable.size(FaceData.vIndices) == 3 then
				local faceParts = drawFace({
					ParsedData.v[FaceData.vIndices[1]],
					ParsedData.v[FaceData.vIndices[2]],
					ParsedData.v[FaceData.vIndices[3]],
				}, PartsFolder)

				for _, FacePart in ipairs(faceParts) do
					if (FacePart.Position - Vector3.zero).Magnitude <= 131072 then
						table.insert(Parts :: { BasePart? }, FacePart)
					end
				end
			elseif SharedTable.size(FaceData.vIndices) == 4 then
				local faceParts = drawFace({
					ParsedData.v[FaceData.vIndices[1]],
					ParsedData.v[FaceData.vIndices[2]],
					ParsedData.v[FaceData.vIndices[3]],
					ParsedData.v[FaceData.vIndices[4]],
				}, PartsFolder)

				for _, FacePart in ipairs(faceParts) do
					if (FacePart.Position - Vector3.zero).Magnitude <= 131072 then
						table.insert(Parts :: { BasePart? }, FacePart)
					end
				end
			end
		end)

		if (index * actorCount) % 120 == 0 then
			task.wait()
		end
	end

	task.wait()

	for i = 1, math.ceil(#Parts / partAmountInUnion), 1 do
		task.desynchronize()

		local i2 = math.min(i * partAmountInUnion, #Parts)
		local firstPartIndex = 1 + (i - 1) * partAmountInUnion
		local firstPart: BasePart = Parts[firstPartIndex]
		local UnionParts = {}

		table.move(Parts, firstPartIndex + 1, i2, 1, UnionParts)

		task.synchronize()

		firstPart:UnionAsync(UnionParts).Parent = UnionGroup
	end

	return false
end)
