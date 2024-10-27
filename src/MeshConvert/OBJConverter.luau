--!native
--!strict
local OBJConverter = {}
local Root = script.Parent
local Types = require(Root.Types)

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

local function splitByLetter(str: string, pattern: string): { string }
	local words: { string } = {}
	local searchPattern = "([^" .. pattern .. "]+)"

	for match: string in str:gmatch(searchPattern) do
		table.insert(words, match)
	end

	return words
end

function OBJConverter.parse(splitedData: { string })
	local ParsedData = {
		v = {},
		vn = {},
		vt = {},
		f = {},
	} :: ParsedData

	for index, line: string in ipairs(splitedData) do
		local words: { string } = splitByLetter(line, " ")
		local firstWord: string = words[1]

		if firstWord ~= "#" then
			if firstWord == "v" then
				local v: Vector3 = Vector3.new(tonumber(words[2]), tonumber(words[3]), tonumber(words[4]))

				table.insert(ParsedData.v, v)
			elseif firstWord == "vn" then
				local vn: Vector3 = Vector3.new(tonumber(words[2]), tonumber(words[3]), tonumber(words[4]))

				table.insert(ParsedData.vn, vn)
			elseif firstWord == "vt" then
				local vt: Vector2 = Vector2.new(tonumber(words[2]), tonumber(words[3]))

				table.insert(ParsedData.vt, vt)
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

						table.insert(f.vIndices, tonumber(split[1]) :: number)
						table.insert(f.vnIndices, tonumber(split[2]) :: number)
					elseif line:find("/") then
						local split: { string } = splitByLetter(words[i], "/")

						table.insert(f.vIndices, tonumber(split[1]) :: number)
						table.insert(f.vtIndices, tonumber(split[2]) :: number)

						if split[3] then
							table.insert(f.vnIndices, tonumber(split[3]) :: number)
						end
					end
				end

				table.insert(ParsedData.f, f)
			end
		end
	end

	return ParsedData
end

function OBJConverter.convert(ParsedData: ParsedData)
	local fileData: string = ""
	local vector3Format: string = "%f %f %f"
	local vector2Format: string = "%f %f"

	local function writeLine(firstWord: string, ...)
		local arguments = { ... } :: { string }
		local data: string = ""
		local line: string

		for _, argument in ipairs(arguments) do
			data = (data .. " " .. argument)
		end

		line = firstWord .. data .. "\n" :: string
		fileData = (fileData .. line) :: string
	end

	writeLine("# MeshConvert")
	writeLine("# https://github.com/Name-hw/MeshConvert")
	writeLine("g")

	for index, vertexData: Vector3 in ipairs(ParsedData.v) do
		writeLine("v", vector3Format:format(vertexData.X, vertexData.Y, vertexData.Z))

		if index % 60 == 0 then
			task.wait()
		end
	end

	for index, normalData: Vector3 in ipairs(ParsedData.vn) do
		writeLine("vn", vector3Format:format(normalData.X, normalData.Y, normalData.Z))

		if index % 60 == 0 then
			task.wait()
		end
	end

	for index, textureData: Vector2 in ipairs(ParsedData.vt) do
		writeLine("vt", vector2Format:format(textureData.X, textureData.Y))

		if index % 60 == 0 then
			task.wait()
		end
	end

	for index, faceData: Types.FaceData in ipairs(ParsedData.f) do
		local data: { string } = {}

		for index, vIndex in ipairs(faceData.vIndices) do
			data[index] = tostring(vIndex)
		end

		for index, vtIndex in ipairs(faceData.vtIndices) do
			data[index] = data[index] .. "/" .. tostring(vtIndex) -- Vertex texture coordinate indices
		end

		if #faceData.vtIndices == 0 then
			for index, vnIndex in ipairs(faceData.vnIndices) do
				data[index] = data[index] .. "//" .. tostring(vnIndex) -- Vertex normal indices without texture coordinate indices
			end
		else
			for index, vnIndex in ipairs(faceData.vnIndices) do -- Vertex normal indices
				data[index] = data[index] .. "/" .. tostring(vnIndex)
			end
		end

		writeLine("f", data[1], data[2], data[3], data[4])

		if index % 60 == 0 then
			task.wait()
		end
	end

	return fileData
end

return OBJConverter
