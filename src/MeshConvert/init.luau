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
	local succeeded: boolean = pcall(function()
		ParsedData = parse(MeshData)
	end)

	if not succeeded then
		error("Please check that InputType and MeshData are correct.")
	end

	local Output = convert(ParsedData)

	return Output
end

return MeshConvert
