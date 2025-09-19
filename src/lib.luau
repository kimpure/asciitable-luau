local green_tea = require("../luau_packages/greentea_luau")

local table_type = green_tea.build(green_tea.table({
	[green_tea.any()] = green_tea.any(),
}))

local normal_chars = {
	middleMiddle = "─",
	rowMiddle = "┼",
	topRight = "┐",
	topLeft = "┌",
	leftMiddle = "├",
	topMiddle = "┬",
	bottomRight = "┘",
	bottomLeft = "└",
	bottomMiddle = "┴",
	rightMiddle = "┤",
	left = "│ ",
	right = " │",
	middle = "│",
}

local round_chars = {
	middleMiddle = "─",
	rowMiddle = "┼",
	topRight = "╮",
	topLeft = "╭",
	leftMiddle = "├",
	topMiddle = "┬",
	bottomRight = "╯",
	bottomLeft = "╰",
	bottomMiddle = "┴",
	rightMiddle = "┤",
	left = "│ ",
	right = " │",
	middle = "│",
}

export type TableType = typeof(table_type:type())

--[=[
	@class ArsciiTable

    ArsciiTable
]=]
export type ArsciiTable = {
	--[=[
		@within ArsciiTable

		Whether to use round

		```luau
		asciitable.round = true
		```
	]=]
	round: boolean,

	--[=[
		@within ArsciiTable

		Whether to divide the cells in the table method

		```luau
		asciitable.merge_index_labels = true
		```
	]=]
	merge_index_labels: boolean,

	--[=[
		@within ArsciiTable
		
		A string to display the index in the table
	
		```luau
		asciitable.table_main_index = 'main index'
		```
	]=]
	table_main_index: string,

	--[=[
		@within ArsciiTable
		
		A string to display the value in the table
	
		```luau
		asciitable.table_main_value = 'main values'
		```
	]=]
	table_main_value: string,

	--[=[
		@within ArsciiTable
		
		Display in tree format
		
		```luau
		print(asciitable.tree('sunwoo', test_table))
		```

		@param top -- The string to be located at the top
		@param child -- Child to be included in tree
	]=]
	tree: (top: any, child: TableType) -> string,

	--[=[
		@within ArsciiTable
		
		Display in table format
		
		```luau
		print(asciitable.table(test_table))
		```

		@param value -- Value to display
	]=]
	table: (value: TableType) -> string,
}

local asciitable = {} :: ArsciiTable

local utf8_len = utf8.len :: (string, number?, number?) -> number

local function get_object_or_array_len(arrOrObj)
	local result = 0
	for k, v in arrOrObj do
		result += 1
	end
	return result
end

local function string_prototype_repeat(str: string, num: number)
	local result = ""
	for i = 1, num do
		result ..= str
	end
	return result
end

local function is_array(arr: { [any]: any })
	for k, v in arr do
		if typeof(k) == "number" then
			continue
		end
		return false
	end
	return true
end

local function table_to_string(tab: { [any]: any }): string
	local function format_print_value(value: any)
		local value_type = typeof(value)
		if value_type == "string" then
			return `'{value}'`
		end
		return tostring(value)
	end

	if typeof(tab) ~= "table" then
		return tab
	end

	local res = "{ "
	local rep = 0
	local len = get_object_or_array_len(tab)

	if is_array(tab) then
		return "[Array]"
	end

	for k, v in tab do
		rep = rep + 1
		local pt = if len == rep then "" else ", "

		if typeof(v) ~= "table" then
			v = format_print_value(v)
			if typeof(k) ~= "number" then
				res ..= `[{format_print_value(k)}] = {v}{pt}`
				continue
			end
			res ..= `{v}{pt}`
			continue
		end

		if not is_array(v) then
			res ..= `[{format_print_value(k)}] = {table_to_string(v)}{pt}`
			continue
		end

		if typeof(k) ~= "number" then
			res ..= `[{format_print_value(k)}] = [Array]{pt}`
			continue
		end

		res ..= `[Array]{pt}`
	end

	return res .. " }"
end

local function format_print_value(value: any): string
	local value_type = typeof(value)
	if value_type == "table" then
		return table_to_string(value)
	end
	if value_type == "string" then
		if (value :: string):find("\n") then
			if value:sub(-1) == "\n" then
				value = value:sub(1, #value - 2)
			end
			return `[[{value}]]`
		end
		return `'{value}'`
	end
	return tostring(value)
end

local function get_argument_codepoint_order(tab: { [number]: any })
	table.sort(tab, function(a, b)
		if typeof(a) == "number" and typeof(b) == "number" then
			return a < b
		end
		if typeof(a) == "number" then
			return true
		end
		if typeof(b) == "number" then
			return false
		end
		return tostring(a) < tostring(b)
	end)
	return tab
end

local function get_string_with_space(str: string, space: number)
	space = space - utf8_len(str)

	if space % 2 == 1 then
		space -= 1
		return `{string_prototype_repeat(" ", space / 2)}{str}{string_prototype_repeat(" ", space / 2)} `
	end

	return `{string_prototype_repeat(" ", space / 2)}{str}{string_prototype_repeat(" ", space / 2)}`
end

local function object_to_key_array(obj: { [any]: any }): { [number]: any }
	local res = {}
	for k, v in obj do
		res[#res + 1] = k
	end
	return res
end

local function get_max_len(base_str: string, tab: { [any]: any })
	local max_len = utf8_len(base_str)
	for k, v in tab do
		if max_len < utf8_len(v) then
			max_len = utf8_len(v)
		end
	end
	return max_len
end

local function mix_table_to_object<T>(mix_t: { [any]: T }): { [string]: T }
	for k, v in mix_t do
		if typeof(k) == "number" then
			mix_t[k] = nil
		end
	end
	return mix_t
end

local function get_objectlen(arrOrObj)
	local result = 0
	for k, v in arrOrObj do
		if typeof(v) ~= "number" then
			result += 1
		end
	end
	return result
end

function asciitable.table(value)
	table_type:assert(value)

	local chars = if asciitable.round then
		round_chars
	else
		normal_chars

	local table_main_index = asciitable.table_main_index
	local table_main_value = asciitable.table_main_value

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

	result ..= `{chars.topLeft}{string_prototype_repeat(
		chars.middleMiddle,
		get_max_len(table_main_index, value_key) + 2
	)}`

	for i = 1, #index_key do
		result ..= `{chars.topMiddle}{string_prototype_repeat(
			chars.middleMiddle,
			get_max_len(index_key[i], index_value[index_key[i]]) + 2
		)}`
	end

	if values_key[1] then
		result ..= `{chars.topMiddle}{string_prototype_repeat(
			chars.middleMiddle,
			get_max_len(table_main_value, values_value) + 2
		)}`
	end

	result ..= `{chars.topRight}\n`

	result ..= `{chars.middle}{get_string_with_space(
		table_main_index,
		get_max_len(table_main_index, value_key) + 2
	)}`

	for i = 1, #index_key do
		result ..= `{chars.middle}{get_string_with_space(
			index_key[i],
			get_max_len(index_key[i], index_value[index_key[i]]) + 2
		)}`
	end

	if values_key[1] then
		result ..= `{chars.middle}{get_string_with_space(
			table_main_value,
			get_max_len(table_main_value, values_value) + 2
		)}`
	end

	result ..= `{chars.middle}`

	for i = 1, #value_key do
		if asciitable.merge_index_labels or i == 1 then
			result ..= `\n{chars.leftMiddle}{string_prototype_repeat(
				chars.middleMiddle,
				get_max_len(table_main_index, value_key) + 2
			)}`

			for i = 1, #index_key do
				result ..= `{chars.rowMiddle}{string_prototype_repeat(
					chars.middleMiddle,
					get_max_len(index_key[i], index_value[index_key[i]]) + 2
				)}`
			end

			if values_key[1] then
				result ..= `{chars.rowMiddle}{string_prototype_repeat(
					chars.middleMiddle,
					get_max_len(table_main_value, values_value) + 2
				)}`
			end

			result ..= chars.rightMiddle
		end

		result ..= `\n{chars.middle}{get_string_with_space(
			value_key[i],
			get_max_len(table_main_index, value_key) + 2
		)}`

		for j = 1, #index_key do
			if index_value[index_key[j]][value_key[i]] then
				result ..= `{chars.middle}{get_string_with_space(
					index_value[index_key[j]][value_key[i]],
					get_max_len(index_key[j], index_value[index_key[j]]) + 2
				)}`
				continue
			end

			result ..= `{chars.middle}{string_prototype_repeat(
				" ",
				get_max_len(index_key[j], index_value[index_key[j]]) + 2
			)}`
		end

		result ..= chars.middle

		if values_value[value_key[i]] then
			result ..= `{get_string_with_space(
				values_value[value_key[i]],
				get_max_len(table_main_value, values_value) + 2
			)}`
		else
			result ..= `{string_prototype_repeat(" ", get_max_len(table_main_value, values_value) + 2)}`
		end

		result ..= chars.middle
	end

	result ..= `\n{chars.bottomLeft}{string_prototype_repeat(
		chars.middleMiddle,
		get_max_len(table_main_index, value_key) + 2
	)}`

	for i = 1, #index_key do
		result ..= `{chars.bottomMiddle}{string_prototype_repeat(
			chars.middleMiddle,
			get_max_len(index_key[i], index_value[index_key[i]]) + 2
		)}`
	end

	if values_key[1] then
		result ..= `{chars.bottomMiddle}{string_prototype_repeat(
			chars.middleMiddle,
			get_max_len(table_main_value, values_value) + 2
		)}`
	end

	result ..= chars.bottomRight

	return result
end

function asciitable.tree(top, children)
	table_type:assert(children)

	local chars = if asciitable.round then
		round_chars
	else
		normal_chars
	
	local result = tostring(top) .. "\n"

	children = mix_table_to_object(children)

	local function make_table_tree(tab_size: number, value: { [any]: any }, lt: { boolean })
		local loop_index = 0

		local keys = {}

		for k, _ in value do
			keys[#keys + 1] = k
		end

		local sort_keys = get_argument_codepoint_order(keys)
		
		for i=1, #sort_keys do
			local k = sort_keys[i]
			local v = value[k]
			loop_index += 1
			local is_last = get_objectlen(value) == loop_index

			for i=1, #lt do
				if lt[i] then
					result ..= " "
				else
					result ..= chars.middle
				end
			end
			
			if is_last then
				result ..= chars.bottomLeft
			else
				result ..= chars.leftMiddle
			end
	
			if typeof(v) == "table" then
				result ..= chars.topMiddle
			else
				result ..= chars.middleMiddle
			end
	
			result ..= " " .. tostring(k)
	
			if typeof(v) == "table" then
				result ..= "\n"
				
				table.insert(lt, is_last)

				make_table_tree(tab_size + 1, v, lt)

				table.remove(lt)
			else
				result ..= ": " .. format_print_value(v) .. "\n"
			end
		end
	end

	make_table_tree(0, children, {})

	return result
end

asciitable.round = false
asciitable.merge_index_labels = false
asciitable.table_main_index = "(index)"
asciitable.table_main_value = "Values"

return asciitable
