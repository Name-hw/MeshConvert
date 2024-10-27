--!strict
local Types = require(script.Parent.Types)

type UserEnum_Metatable = Types.UserEnum_Metatable
type UserEnum = Types.UserEnum

local UserEnum = {}

function UserEnum.new(Enums_Metatable: Types.UserEnums_Metatable): (UserEnum, UserEnum_Metatable)
	local newUserEnum = newproxy(true)
	local newUserEnum_Metatable: any = getmetatable(newUserEnum)
	newUserEnum_Metatable.__index = function(self: UserEnum, index: string)
		local Property = rawget(newUserEnum_Metatable, index)

		if Property then
			return Property
		else
			error(index .. " is not a valid member of " .. '"' .. "Enum." .. tostring(self) .. '"', 2)
		end
	end
	newUserEnum_Metatable.__tostring = function(self: UserEnum): string
		local EnumName: string

		for name: string, enum: UserEnum in pairs(Enums_Metatable) do
			if enum == self then
				EnumName = tostring(name)
			end
		end

		return EnumName
	end
	newUserEnum_Metatable.__metatable = "The metatable is locked"

	newUserEnum_Metatable.GetEnumItems = function(self: UserEnum): { Types.UserEnumItem }
		local EnumItems = {}

		for _, value: Types.UserEnumItem in pairs(newUserEnum_Metatable) do
			if typeof(value) == "userdata" then
				table.insert(EnumItems, value :: Types.UserEnumItem)
			end
		end

		return EnumItems
	end

	return newUserEnum, newUserEnum_Metatable
end

return UserEnum
