local UserEnums_Class = require(script.Parent.UserEnums)
local UserEnum_Class = require(script.Parent.UserEnum)
local UserEnumItem_Class = require(script.Parent.UserEnumItem)

type UserEnums = UserEnums_Class.UserEnums
type UserEnum = UserEnum_Class.UserEnum
type UserEnumItem = UserEnumItem_Class.UserEnumItem

local EnumList = {
	--Please write the Enum you want to add here.

	InputType = {
		OBJ = {},
		MeshPart = {},
	},

	OutputType = {
		OBJ = {},
		MeshPart = {},
		PartsGroup = {},
		UnionGroup = {},
	},
}

return EnumList
