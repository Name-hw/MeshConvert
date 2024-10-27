--!native
--!strict
local MeshPartConverter = {}
local AssetService = game:GetService("AssetService")
local Root = script.Parent
local Types = require(Root.Types)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

local function addSharpQuad(EM: EditableMesh, vid0: number, vid1: number, vid2: number, vid3: number)
	local nid = EM:AddNormal()

	local fid1 = EM:AddTriangle(vid0, vid1, vid2)
	EM:SetFaceNormals(fid1, { nid, nid, nid })

	local fid2 = EM:AddTriangle(vid0, vid2, vid3)
	EM:SetFaceNormals(fid2, { nid, nid, nid })
end

local function computeExtents(em: EditableMesh): Vector3
	local verts = em:GetVertices()
	if #verts == 0 then
		return Vector3.zero
	end
	local inf = math.huge
	local min: Vector3 = Vector3.new(inf, inf, inf)
	local max: Vector3 = Vector3.new(-inf, -inf, -inf)
	for index, id in verts do
		local v = em:GetPosition(id)
		min = min:Min(v) :: Vector3
		max = max:Max(v) :: Vector3

		if index % 6000 == 0 then
			task.wait()
		end
	end
	return max - min
end

function MeshPartConverter.parse(MeshPart: MeshPart)
	local ParsedData = {
		v = {},
		vn = {},
		vt = {},
		f = {} :: FaceData,
	} :: ParsedData
	local EM: EditableMesh
	local sizeRatio

	if MeshPart:FindFirstChildWhichIsA("EditableMesh") then
		EM = MeshPart:FindFirstChildWhichIsA("EditableMesh") :: EditableMesh

		sizeRatio = MeshPart.Size / MeshPart.MeshSize
	elseif MeshPart.MeshId ~= "" then
		local succeeded: boolean, errorMsg: string? = pcall(function()
			EM = AssetService:CreateEditableMeshFromPartAsync(MeshPart)

			return nil
		end)

		assert(succeeded, errorMsg)

		sizeRatio = MeshPart.Size / MeshPart.MeshSize
	else
		local succeeded: boolean, errorMsg: string? = pcall(function()
			EM = AssetService:CreateEditableMesh()

			return nil
		end)

		assert(succeeded, errorMsg)

		local v1 = EM:AddVertex(Vector3.new(-1, -1, -1))
		local v2 = EM:AddVertex(Vector3.new(1, -1, -1))
		local v3 = EM:AddVertex(Vector3.new(-1, 1, -1))
		local v4 = EM:AddVertex(Vector3.new(1, 1, -1))
		local v5 = EM:AddVertex(Vector3.new(-1, -1, 1))
		local v6 = EM:AddVertex(Vector3.new(1, -1, 1))
		local v7 = EM:AddVertex(Vector3.new(-1, 1, 1))
		local v8 = EM:AddVertex(Vector3.new(1, 1, 1))

		addSharpQuad(EM, v5, v6, v8, v7) -- front
		addSharpQuad(EM, v1, v3, v4, v2) -- back
		addSharpQuad(EM, v1, v5, v7, v3) -- left
		addSharpQuad(EM, v2, v4, v8, v6) -- right
		addSharpQuad(EM, v1, v2, v6, v5) -- bottom
		addSharpQuad(EM, v3, v7, v8, v4) -- top

		EM:RemoveUnused()

		sizeRatio = MeshPart.Size / 2
	end

	local EMpositionBuffer = {}
	local EMnormalBuffer = {}
	local EMtextureBuffer = {}

	for index, EMvIndex: number in ipairs(EM:GetVertices() :: { number }) do
		ParsedData.v[index] = EM:GetPosition(EMvIndex) * sizeRatio
		EMpositionBuffer[EMvIndex] = index

		if index % 6000 == 0 then
			task.wait()
		end
	end

	for index, EMvnIndex: number in ipairs(EM:GetNormals() :: { number }) do
		ParsedData.vn[index] = EM:GetNormal(EMvnIndex) :: Vector3
		EMnormalBuffer[EMvnIndex] = index

		if index % 6000 == 0 then
			task.wait()
		end
	end

	for index, EMvtIndex: number in ipairs(EM:GetUVs() :: { number }) do
		ParsedData.vt[index] = EM:GetUV(EMvtIndex) :: Vector2
		EMtextureBuffer[EMvtIndex] = index

		if index % 6000 == 0 then
			task.wait()
		end
	end

	for index, EMfIndex: number in EM:GetFaces() do
		local f = {
			vIndices = {},
			vtIndices = {},
			vnIndices = {},
		} :: FaceData

		for _, EMvIndex: number in EM:GetFaceVertices(EMfIndex) do
			table.insert(f.vIndices, EMpositionBuffer[EMvIndex])
		end

		for _, EMvnIndex: number in EM:GetFaceNormals(EMfIndex) do
			table.insert(f.vnIndices, EMnormalBuffer[EMvnIndex])
		end

		for _, EMvtIndex: number in EM:GetFaceUVs(EMfIndex) do
			table.insert(f.vtIndices, EMtextureBuffer[EMvtIndex])
		end

		table.insert(ParsedData.f, f)

		if index % 6000 == 0 then
			task.wait()
		end
	end

	return ParsedData
end

function MeshPartConverter.convert(ParsedData: ParsedData)
	local EM: EditableMesh
	local succeeded: boolean, errorMsg: string? = pcall(function()
		EM = AssetService:CreateEditableMesh()

		return nil
	end)

	assert(succeeded, errorMsg)

	local EMvIndices: { number } = {}
	local EMvnIndices: { number } = {}
	local EMvtIndices: { number } = {}

	for index, vertexData: Vector3 in ipairs(ParsedData.v) do
		table.insert(EMvIndices, EM:AddVertex(vertexData))

		if index % 240 == 0 then
			task.wait()
		end
	end

	for index, normalData: Vector3 in ipairs(ParsedData.vn) do
		table.insert(EMvnIndices, EM:AddNormal(normalData))

		if index % 240 == 0 then
			task.wait()
		end
	end

	for index, textureData: Vector2 in ipairs(ParsedData.vt) do
		table.insert(EMvtIndices, EM:AddUV(textureData))

		if index % 240 == 0 then
			task.wait()
		end
	end

	for index, FaceData: FaceData in ipairs(ParsedData.f) do
		if #FaceData.vIndices == 3 then
			local fIndex = EM:AddTriangle(
				EMvIndices[FaceData.vIndices[1]],
				EMvIndices[FaceData.vIndices[2]],
				EMvIndices[FaceData.vIndices[3]]
			)

			if #FaceData.vnIndices ~= 0 then
				EM:SetFaceNormals(fIndex, {
					EMvnIndices[FaceData.vnIndices[1]],
					EMvnIndices[FaceData.vnIndices[2]],
					EMvnIndices[FaceData.vnIndices[3]],
				})
			end

			if #FaceData.vtIndices ~= 0 then
				EM:SetFaceUVs(fIndex, {
					EMvtIndices[FaceData.vtIndices[1]],
					EMvtIndices[FaceData.vtIndices[2]],
					EMvtIndices[FaceData.vtIndices[3]],
				})
			end
		elseif #FaceData.vIndices == 4 then
			local fIndex = EM:AddTriangle(
				EMvIndices[FaceData.vIndices[1]],
				EMvIndices[FaceData.vIndices[2]],
				EMvIndices[FaceData.vIndices[3]]
			)
			local fIndex2 = EM:AddTriangle(
				EMvIndices[FaceData.vIndices[3]],
				EMvIndices[FaceData.vIndices[4]],
				EMvIndices[FaceData.vIndices[1]]
			)

			if #FaceData.vnIndices ~= 0 then
				EM:SetFaceNormals(fIndex, {
					EMvnIndices[FaceData.vnIndices[1]],
					EMvnIndices[FaceData.vnIndices[2]],
					EMvnIndices[FaceData.vnIndices[3]],
				})

				EM:SetFaceNormals(fIndex2, {
					EMvnIndices[FaceData.vnIndices[3]],
					EMvnIndices[FaceData.vnIndices[4]],
					EMvnIndices[FaceData.vnIndices[1]],
				})
			end

			if #FaceData.vtIndices ~= 0 then
				EM:SetFaceUVs(fIndex, {
					EMvtIndices[FaceData.vtIndices[1]],
					EMvtIndices[FaceData.vtIndices[2]],
					EMvtIndices[FaceData.vtIndices[3]],
				})
				EM:SetFaceUVs(fIndex2, {
					EMvtIndices[FaceData.vtIndices[3]],
					EMvtIndices[FaceData.vtIndices[4]],
					EMvtIndices[FaceData.vtIndices[1]],
				})
			end
		end

		if index % 240 == 0 then
			task.wait()
		end
	end

	EM:RemoveUnused()

	task.wait()

	local MeshPart: MeshPart = EM:CreateMeshPartAsync(computeExtents(EM))

	return MeshPart
end

return MeshPartConverter
