--!strict
local Types = require(script.Parent.Types)

type UserEnums_Metatable = Types.UserEnums_Metatable
type UserEnums = Types.UserEnums

local UserEnums = {}

function UserEnums.new(): (UserEnums, UserEnums_Metatable)
	local newUserEnums = newproxy(true)
	local newUserEnums_Metatable: any = getmetatable(newUserEnums)
	newUserEnums_Metatable.__index = function(self: UserEnums, index: string | Types.UserEnum): Types.UserEnum
		local value = rawget(newUserEnums_Metatable, tostring(index)) :: Types.UserEnum

		if value then
			return value
		else
			error(tostring(index) .. " is not a valid member of " .. '"Enums"', 0)
		end
	end
	newUserEnums_Metatable.__tostring = function(): string
		return "UserEnums"
	end
	newUserEnums_Metatable.__metatable = "The metatable is locked"

	newUserEnums_Metatable.GetEnums = function(self: UserEnums): { Types.UserEnum }
		local Enums = {}

		for _, value: Types.UserEnum in pairs(newUserEnums_Metatable) do
			if typeof(value) == "userdata" then
				table.insert(Enums, value :: Types.UserEnum)
			end
		end

		return Enums
	end

	return newUserEnums, newUserEnums_Metatable
end

return UserEnums
