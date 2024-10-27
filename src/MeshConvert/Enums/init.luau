--!strict
local UserEnums_Class = require(script.UserEnums)
local UserEnum_Class = require(script.UserEnum)
local UserEnumItem_Class = require(script.UserEnumItem)
local EnumList = require(script.EnumList)
local Types = require(script.Types)

assert(EnumList, "Please write a module script for 'EnumList'")

export type UserEnums = Types.UserEnums
export type UserEnum = Types.UserEnum
export type UserEnumItem = Types.UserEnumItem

local Enums, Enums_Metatable = UserEnums_Class.new()

for enumName: string, enumItemNames in pairs(EnumList :: any) do
	local newUserEnum: UserEnum, newUserEnum_Metatable: Types.UserEnum_Metatable = UserEnum_Class.new(Enums_Metatable)
	local order = 0

	for name: string, _ in pairs(enumItemNames :: any) do
		local newUserEnumItem: UserEnumItem, newUserEnumItem_Metatable = UserEnumItem_Class.new()

		rawset(newUserEnumItem_Metatable :: any, "Name", name)
		rawset(newUserEnumItem_Metatable :: any, "Value", order)
		rawset(newUserEnumItem_Metatable :: any, "EnumType", newUserEnum)

		rawset(newUserEnum_Metatable, name, newUserEnumItem)

		order += 1
	end

	rawset(Enums_Metatable, enumName, newUserEnum)
end

return Enums :: UserEnums & typeof(EnumList)
