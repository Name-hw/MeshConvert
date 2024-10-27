--UserEnums
export type UserEnums_Metatable = { [string | UserEnum]: UserEnum, GetEnums: (self: UserEnums) -> { UserEnum } }
export type UserEnums = typeof(newproxy(true)) & UserEnums_Metatable

--UserEnum
export type UserEnum_Metatable = { [string]: UserEnumItem, GetEnumItems: (self: UserEnum) -> { UserEnumItem } }
export type UserEnum = typeof(newproxy(true)) & UserEnum_Metatable

--UserEnumItem
export type UserEnumItem_Metatable = {
	Name: string,
	Value: number,
	EnumType: UserEnum,
}
export type UserEnumItem = typeof(newproxy(true)) & UserEnumItem_Metatable

return nil
