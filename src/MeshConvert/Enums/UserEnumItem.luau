--!strict
local Types = require(script.Parent.Types)

type UserEnumItem_Metatable = Types.UserEnumItem_Metatable
type UserEnumItem = Types.UserEnumItem

local UserEnumItem = {}

function UserEnumItem.new(): (UserEnumItem, UserEnumItem_Metatable)
	local newUserEnumItem = newproxy(true)
	local newUserEnumItem_Metatable: any = getmetatable(newUserEnumItem)
	newUserEnumItem_Metatable.__index = function(self: UserEnumItem, index: string)
		local Property = rawget(newUserEnumItem_Metatable :: { [string]: any }, index)

		if Property then
			return Property
		else
			error(index .. "is not a valid member of" .. '"' .. tostring(newUserEnumItem) .. '"')
		end
	end
	newUserEnumItem_Metatable.__tostring = function(self): string
		return "Enum." .. tostring(newUserEnumItem_Metatable.EnumType) .. "." .. tostring(newUserEnumItem_Metatable.Name)
	end
	newUserEnumItem_Metatable.__metatable = "The metatable is locked"

	return newUserEnumItem, newUserEnumItem_Metatable
end

return UserEnumItem
