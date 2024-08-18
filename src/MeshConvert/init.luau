--!strict
local Enums = require(script.Enums)
local MeshConvert = {}
MeshConvert.Enums = Enums

function MeshConvert.Import(Format: Enums.UserEnumItem, data: string, OutputType: Enums.UserEnumItem): EditableMesh?
	local Formatter = require(script:FindFirstChild(Format.Name)) :: any
	local splitedData: { string } = data:split("\n")
	local ParsedData = Formatter.parse(splitedData)
	local Output: EditableMesh? = Formatter.Import(ParsedData, OutputType)

	return Output
end

function MeshConvert.Export(Format: Enums.UserEnumItem, Instance: Instance)
	local Formatter = require(script:FindFirstChild(Format.Name)) :: any

	Formatter.Export(Instance)
end

return MeshConvert
