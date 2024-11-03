--!strict
local Actor = script:GetActor() :: Actor

if not Actor then
	return
end

local Root = script.Parent.Parent.Parent.Parent
local Parallelizer = require(Root.Parallelizer)
local Types = require(Root.Types)
local drawFace = require(Root.drawFace)
local PartsGroup = Actor:FindFirstChild("MeshConvert_PartsGroup")

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

Parallelizer.CreateThread(Actor, "PartsGroupConvert", function(id: number, ParsedData: SharedTable)
	local i = math.min(id * 120, SharedTable.size(ParsedData.f))

	for index = id + (id - 1) * 120, i, 1 do
		local FaceData: FaceData | SharedTable = ParsedData.f[index]

		if SharedTable.size(FaceData.vIndices) == 3 then
			drawFace({
				ParsedData.v[FaceData.vIndices[1]],
				ParsedData.v[FaceData.vIndices[2]],
				ParsedData.v[FaceData.vIndices[3]],
			}, PartsGroup)
		elseif SharedTable.size(FaceData.vIndices) == 4 then
			drawFace({
				ParsedData.v[FaceData.vIndices[1]],
				ParsedData.v[FaceData.vIndices[2]],
				ParsedData.v[FaceData.vIndices[3]],
				ParsedData.v[FaceData.vIndices[4]],
			}, PartsGroup)
		end
	end

	return true
end)
