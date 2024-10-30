--!strict
local Enums = require(script.Enums)
local Types = require(script.Types)
local MeshConvert = {}
MeshConvert.Enums = Enums

type FaceData = Types.FaceData
type ParsedData = Types.ParsedData

function MeshConvert.Convert(
	InputType: Enums.UserEnumItem,
	MeshData: any,
	OutputType: Enums.UserEnumItem
): string | MeshPart | Model
	--assert(InputType.Name ~= OutputType.Name, "InputType and OutputType are the same.")

	local parse = require(script:FindFirstChild(InputType.Name .. "Converter")).parse :: any
	local convert = require(script:FindFirstChild(OutputType.Name .. "Converter")).convert :: any

	if type(MeshData) == "string" then
		MeshData = MeshData:split("\n")
	end

	local ParsedData: string
	local succeeded: boolean, errorMsg: string? = pcall(function()
		ParsedData = parse(MeshData)

		return nil
	end)

	assert(succeeded, errorMsg :: string .. "\nPlease check that InputType and MeshData are correct.")

	local Output = convert(ParsedData)

	return Output
end

return MeshConvert
