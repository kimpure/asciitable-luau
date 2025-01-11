local green_tea = require("../lune_packages/greentea")

local table_type = green_tea.build(green_tea.table({
	[green_tea.any()] = green_tea.any(),
}))

local method = require("./method")

local format_print_value = method.format_print_value
local get_argument_codepoint_order = method.get_argument_codepoint_order
local get_objectlen = method.get_objectlen
local get_string_with_space = method.get_string_with_space
local get_max_len = method.get_max_len
local string_prototype_repeat = method.string_prototype_repeat
local object_to_key_array = method.object_to_key_array

local config = require("./config")

local table_chars = config.table_chars
local tree_chars = config.tree_chars

local table_main_index = config.table_main_index
local table_main_value = config.table_main_value

export type TableType = typeof(table_type:type())

export type Arscii = typeof(setmetatable(
	{} :: {
		round: boolean,
		mergeIndexLabels: boolean,
		tree: (top: any, child: TableType) -> string,
		table: (value: TableType) -> string,
	},
	{}
))

local function arscii_change_setting(arscii: Arscii)
	if arscii.round then
		table_chars = config.table_round_chars
		tree_chars = config.tree_round_chars
		return
	end

	table_chars = config.table_chars
	tree_chars = config.tree_chars
end

local function arscii_table(value: TableType, arscii: Arscii): string
	table_type:assert(value)

	local result = ""

	local value_key = {}

	local index_key = {}
	local index_value = {}

	local values_key = {}
	local values_value = {}

	for k, v in value do
		value_key[#value_key + 1] = k

		if typeof(v) ~= "table" then
			values_value[k] = format_print_value(v)
			continue
		end

		for index_k, v in v do
			index_value[index_k] = index_value[index_k] or {}
			index_value[index_k][k] = format_print_value(v)
		end
	end

	value_key = get_argument_codepoint_order(value_key)

	index_key = object_to_key_array(index_value)
	index_key = get_argument_codepoint_order(index_key)

	values_key = object_to_key_array(values_value)
	values_key = get_argument_codepoint_order(values_key)

	result ..= `{table_chars.topLeft}{string_prototype_repeat(
		table_chars.middleMiddle,
		get_max_len(table_main_index, value_key) + 2
	)}`

	for i = 1, #index_key do
		result ..= `{table_chars.topMiddle}{string_prototype_repeat(
			table_chars.middleMiddle,
			get_max_len(index_key[i], index_value[index_key[i]]) + 2
		)}`
	end

	if values_key[1] then
		result ..= `{table_chars.topMiddle}{string_prototype_repeat(
			table_chars.middleMiddle,
			get_max_len(table_main_value, values_value) + 2
		)}`
	end

	result ..= `{table_chars.topRight}\n`

	result ..= `{table_chars.middle}{get_string_with_space(
		table_main_index,
		get_max_len(table_main_index, value_key) + 2
	)}`

	for i = 1, #index_key do
		result ..= `{table_chars.middle}{get_string_with_space(
			index_key[i],
			get_max_len(index_key[i], index_value[index_key[i]]) + 2
		)}`
	end

	if values_key[1] then
		result ..= `{table_chars.middle}{get_string_with_space(
			table_main_value,
			get_max_len(table_main_value, values_value) + 2
		)}`
	end

	result ..= `{table_chars.middle}`

	for i = 1, #value_key do
		if arscii.mergeIndexLabels or i == 1 then
			result ..= `\n{table_chars.leftMiddle}{string_prototype_repeat(
				table_chars.middleMiddle,
				get_max_len(table_main_index, value_key) + 2
			)}`

			for i = 1, #index_key do
				result ..= `{table_chars.rowMiddle}{string_prototype_repeat(
					table_chars.middleMiddle,
					get_max_len(index_key[i], index_value[index_key[i]]) + 2
				)}`
			end

			if values_key[1] then
				result ..= `{table_chars.rowMiddle}{string_prototype_repeat(
					table_chars.middleMiddle,
					get_max_len(table_main_value, values_value) + 2
				)}`
			end

			result ..= table_chars.rightMiddle
		end

		result ..= `\n{table_chars.middle}{get_string_with_space(
			value_key[i],
			get_max_len(table_main_index, value_key) + 2
		)}`

		for j = 1, #index_key do
			if index_value[index_key[j]][value_key[i]] then
				result ..= `{table_chars.middle}{get_string_with_space(
					index_value[index_key[j]][value_key[i]],
					get_max_len(index_key[j], index_value[index_key[j]]) + 2
				)}`
				continue
			end

			result ..= `{table_chars.middle}{string_prototype_repeat(
				" ",
				get_max_len(index_key[j], index_value[index_key[j]]) + 2
			)}`
		end

		result ..= table_chars.middle

		if values_value[value_key[i]] then
			result ..= `{get_string_with_space(values_value[value_key[i]], get_max_len(index_key[i], values_value) + 2)}`
		else
			result ..= `{string_prototype_repeat(" ", get_max_len(index_key[i], values_value) + 2)}`
		end

		result ..= table_chars.middle
	end

	result ..= `\n{table_chars.bottomLeft}{string_prototype_repeat(
		table_chars.middleMiddle,
		get_max_len(table_main_index, value_key) + 2
	)}`

	for i = 1, #index_key do
		result ..= `{table_chars.bottomMiddle}{string_prototype_repeat(
			table_chars.middleMiddle,
			get_max_len(index_key[i], index_value[index_key[i]]) + 2
		)}`
	end

	if values_key[1] then
		result ..= `{table_chars.bottomMiddle}{string_prototype_repeat(
			table_chars.middleMiddle,
			get_max_len(table_main_value, values_value) + 2
		)}`
	end

	result ..= table_chars.bottomRight

	return result
end

local function arscii_tree(top: any, children: TableType, arscii: Arscii): string
	table_type:assert(children)

	local result = tostring(top)

	local function add_tree(loop_num: number, children, last_child)
		local children_key = {}
		local children_value = {}

		for k, v in children do
			if typeof(k) == "number" then
				continue
			end
			children_key[#children_key + 1] = k
		end

		children_key = get_argument_codepoint_order(children_key)

		for i = 1, #children_key do
			children_value[i] = children[children_key[i]]
		end

		for i = 1, #children_key do
			result ..= "\n"

			if last_child then
				result ..= string_prototype_repeat(" ", loop_num)
			else
				result ..= string_prototype_repeat(tree_chars.middle, loop_num)
			end

			if #children_key == i then
				result ..= tree_chars.bottomLeft
			else
				result ..= tree_chars.leftMiddle
			end

			local child = children_value[i]

			if typeof(child) ~= "table" then
				result ..= tree_chars.middleMiddle

				result ..= ` {children_key[i]}: {format_print_value(child)}`

				continue
			end

			if get_objectlen(child) == 0 then
				result ..= tree_chars.middleMiddle

				result ..= ` {children_key[i]}`

				continue
			end

			result ..= tree_chars.topMiddle

			result ..= ` {children_key[i]}`

			add_tree(loop_num + 1, child, #children_key == i)
		end
	end

	add_tree(0, children, false)

	return result
end

local arscii_struct = {}
arscii_struct.round = false
arscii_struct.mergeIndexLabels = false

local arscii_impl = {}
arscii_impl.__index = arscii_impl

local arscii = setmetatable(arscii_struct, arscii_impl)

function arscii.table(value)
	arscii_change_setting(arscii)
	return arscii_table(value, arscii)
end

function arscii.tree(top, child)
	arscii_change_setting(arscii)
	return arscii_tree(top, child, arscii)
end

return arscii :: Arscii
