--!native
--!strict
local PartsGroupConverter = {}
local Root = script.Parent
local Types = require(Root.Types)
local drawFace = require(Root.drawFace)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

function PartsGroupConverter.convert(ParsedData: ParsedData)
	local PartsGroup = Instance.new("Model", workspace)
	PartsGroup.Name = "MeshConvert_PartsGroup"

	for index: number, FaceData: FaceData in ParsedData.f :: { FaceData } do
		if #FaceData.vIndices == 3 then
			drawFace({
				ParsedData.v[FaceData.vIndices[1]],
				ParsedData.v[FaceData.vIndices[2]],
				ParsedData.v[FaceData.vIndices[3]],
			}, PartsGroup)
		elseif #FaceData.vIndices == 4 then
			drawFace({
				ParsedData.v[FaceData.vIndices[1]],
				ParsedData.v[FaceData.vIndices[2]],
				ParsedData.v[FaceData.vIndices[3]],
				ParsedData.v[FaceData.vIndices[4]],
			}, PartsGroup)
		end

		if index % 60 == 0 then
			task.wait()
		end
	end

	return PartsGroup
end

return PartsGroupConverter
