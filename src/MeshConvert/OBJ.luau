--!strict
local OBJFormatter = {}
local Enums = require(script.Parent.Enums)

type FaceData = { vIndices: { number? }, vtIndices: { number? }, vnIndices: { number? } }
type ParsedData = {
	v: { Vector3 },
	vt: { Vector2 },
	vn: { Vector3 },
	f: FaceData,
}

local function splitByLetter(str: string, pattern: string): { string }
	local words: { string } = {}
	local searchPattern = "([^" .. pattern .. "]+)"

	for match: string in str:gmatch(searchPattern) do
		table.insert(words, match)
	end

	return words
end

function OBJFormatter.parse(splitedData: { string })
	local ParsedData = {
		v = {},
		vt = {},
		vn = {},
		f = {},
	} :: ParsedData

	for _, line: string in ipairs(splitedData) do
		local words: { string } = splitByLetter(line, " ")
		local firstWord: string = words[1]

		if firstWord ~= "#" then
			if firstWord == "v" then
				local v: Vector3 = Vector3.new(tonumber(words[2]), tonumber(words[3]), tonumber(words[4]))

				table.insert(ParsedData.v, v)
			elseif firstWord == "vt" then
				local vt: Vector2 = Vector2.new(tonumber(words[2]), tonumber(words[3]))

				table.insert(ParsedData.vt, vt)
			elseif firstWord == "vn" then
				local vn: Vector3 = Vector3.new(tonumber(words[2]), tonumber(words[3]), tonumber(words[4]))

				table.insert(ParsedData.vn, vn)
			--[[elseif firstWord == "vp" then
				local vp: Vector3 = Vector3.new(tonumber(words[2]), tonumber(words[3]), tonumber(words[4]))

				table.insert(obj, vp)]]
			elseif firstWord == "f" then
				local f = {
					vIndices = {},
					vtIndices = {},
					vnIndices = {},
				} :: FaceData

				for i = 2, #words do
					if line:find("//") then
						local split: { string } = splitByLetter(words[i], "//")

						table.insert(f.vIndices, tonumber(split[1]))
						table.insert(f.vnIndices, tonumber(split[2]))
					elseif line:find("/") then
						local split: { string } = splitByLetter(words[i], "/")

						table.insert(f.vIndices, tonumber(split[1]))
						table.insert(f.vtIndices, tonumber(split[2]))

						if split[3] then
							table.insert(f.vnIndices, tonumber(split[3]))
						end
					end
				end

				table.insert(ParsedData.f, f)
			end
		end
	end

	return ParsedData
end

function OBJFormatter.Import(ParsedData: ParsedData, OutputType: Enums.UserEnumItem): EditableMesh?
	if OutputType == Enums.MeshOutput.EditableMesh then
		local EM: EditableMesh = Instance.new("EditableMesh")

		for _, FaceData: FaceData in ParsedData.f :: { FaceData } do
			local addedVertexIds: { number } = {}

			for _, vIndex: number in FaceData.vIndices :: { number } do
				local addedVertexId = EM:AddVertex(ParsedData.v[vIndex])

				table.insert(addedVertexIds, addedVertexId)
			end

			for i, vnIndex: number in FaceData.vnIndices :: { number } do
				--if table.find(ParsedData.vn, )
				EM:SetVertexNormal(addedVertexIds[i], ParsedData.vn[vnIndex])
			end

			for i, vtIndex: number in FaceData.vtIndices :: { number } do
				EM:SetUV(addedVertexIds[i], ParsedData.vt[vtIndex])
			end

			if #addedVertexIds == 3 then
				EM:AddTriangle(table.unpack(addedVertexIds))
			elseif #addedVertexIds == 4 then
				EM:AddTriangle(addedVertexIds[1], addedVertexIds[2], addedVertexIds[3])
				EM:AddTriangle(addedVertexIds[3], addedVertexIds[4], addedVertexIds[1])
			end
		end

		return EM
	else
		return nil
	end
end

function OBJFormatter.Export(Instance: Instance)
	if Instance:IsA("EditableMesh") then
	end
end

return OBJFormatter
