--!native
--!strict
local PartsGroupConverter = {}
local Root = script.Parent
local Types = require(Root.Types)
local drawFace = require(Root.drawFace)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData
type Options = Types.Options

function PartsGroupConverter.convert(ParsedData: ParsedData, options: Options?)
	local UnionGroup = Instance.new("Model")
	UnionGroup.Name = "UnionGroup"

	local PartsFolder = Instance.new("Folder", workspace)
	PartsFolder.Name = "MeshConvert_PartsFolder"
	local Parts: { BasePart? } = {}
	local PartAmountInUnion = 120
	local UnionGroupIndex = 0

	if options then
		if options.PartAmountInUnion then
			PartAmountInUnion = options.PartAmountInUnion
		end
	end

	for index: number, FaceData: FaceData in ParsedData.f :: { FaceData } do
		if #FaceData.vIndices == 3 then
			local FaceParts = drawFace({
				ParsedData.v[FaceData.vIndices[1]],
				ParsedData.v[FaceData.vIndices[2]],
				ParsedData.v[FaceData.vIndices[3]],
			}, PartsFolder)

			for _, FacePart in ipairs(FaceParts) do
				if (FacePart.Position - Vector3.zero).Magnitude <= 131072 then
					table.insert(Parts :: { BasePart? }, FacePart)
				end
			end
		elseif #FaceData.vIndices == 4 then
			local FaceParts = drawFace({
				ParsedData.v[FaceData.vIndices[1]],
				ParsedData.v[FaceData.vIndices[2]],
				ParsedData.v[FaceData.vIndices[3]],
				ParsedData.v[FaceData.vIndices[4]],
			}, PartsFolder)

			for _, FacePart in ipairs(FaceParts) do
				if (FacePart.Position - Vector3.zero).Magnitude <= 131072 then
					table.insert(Parts :: { BasePart? }, FacePart)
				end
			end
		end

		if #(Parts :: { BasePart }) >= PartAmountInUnion then
			UnionGroupIndex += 1
			local firstPart: BasePart = (Parts :: { BasePart })[1]
			local PartGroup = {}

			table.move(Parts :: { BasePart }, 2, PartAmountInUnion, 1, PartGroup)

			firstPart:UnionAsync(PartGroup).Parent = UnionGroup

			if #(Parts :: { Part }) > PartAmountInUnion then
				local t = {}
				table.move(Parts, PartAmountInUnion + 1, #Parts, 1, t)
				Parts = t
			else
				Parts = {}
			end

			task.wait()
		end

		if index % PartAmountInUnion == 0 then
			task.wait()
		end
	end

	if #(Parts :: { BasePart }) ~= 0 then
		local firstPart: BasePart = (Parts :: { BasePart })[1]
		local PartGroup = {}

		table.move(Parts, 2, #Parts, 1, PartGroup)

		firstPart:UnionAsync(PartGroup).Parent = UnionGroup

		Parts = {}
	end

	PartsFolder:Destroy()

	return UnionGroup
end

return PartsGroupConverter
