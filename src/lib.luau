local green_tea = require("../luau_packages/greentea_luau")

local table_type = green_tea.build(green_tea.table({
	[green_tea.any()] = green_tea.any(),
}))

local chars = {
    table_chars = {
        middleMiddle = '─',
        rowMiddle = '┼',
        topRight = '┐',
        topLeft = '┌',  
        leftMiddle = '├',
        topMiddle = '┬',
        bottomRight = '┘',
        bottomLeft = '└',
        bottomMiddle = '┴',
        rightMiddle = '┤',
        left = '│ ',
        right = ' │',
        middle = '│'
    },
    
    tree_chars = {
        middleMiddle = '─',
        rowMiddle = '┼',
        topRight = '┐',
        topLeft = '┌',
        leftMiddle = '├',
        topMiddle = '┬',
        bottomRight = '┘',
        bottomLeft = '└',
        bottomMiddle = '┴',
        rightMiddle = '┤',
        left = '│ ',
        right = ' │',
        middle = '│'
    },

    table_round_chars = {
        middleMiddle = '─',
        rowMiddle = '┼',
        topRight = '╮',
        topLeft = '╭',
        leftMiddle = '├',
        topMiddle = '┬',
        bottomRight = '╯',
        bottomLeft = '╰',
        bottomMiddle = '┴',
        rightMiddle = '┤',
        left = '│ ',
        right = ' │',
        middle = '│'
    },

    tree_round_chars = {
        middleMiddle = '─',
        rowMiddle = '┼',
        topRight = '╮',
        topLeft = '╭',
        leftMiddle = '├',
        topMiddle = '┬',
        bottomRight = '╯',
        bottomLeft = '╰',
        bottomMiddle = '┴',
        rightMiddle = '┤',
        left = '│ ',
        right = ' │',
        middle = '│'
    },
}

local table_chars = chars.table_chars
local tree_chars = chars.tree_chars

export type TableType = typeof(table_type:type())

--[=[
	@class ArsciiTable

    ArsciiTable
]=]
export type Arscii = typeof(setmetatable(
	{} :: {
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
			asciitable.mergeIndexLabels = true
			```
		]=]
		mergeIndexLabels: boolean,

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
	},
	{}
))

local utf8_len = utf8.len :: (string, number?, number?) -> (number)

local function get_object_or_array_len(arrOrObj)
    local result = 0
    for k, v in arrOrObj do
        result += 1
    end
    return result
end

local function string_prototype_repeat(str: string, num: number)
    local result = ''
    for i=1, num do
        result ..= str
    end
    return result
end

local function is_array(arr: { [any]: any })
    for k, v in arr do
        if typeof(k) == 'number' then
            continue
        end
        return false
    end
    return true
end

local function table_to_string(tab: { [any]: any }): string
    local function format_print_value(value: any)
        local value_type = typeof(value)
        if value_type == 'string' then
            return `'{value}'`
        end
        return tostring(value)
    end    

    if typeof(tab) ~= 'table' then
        return tab
    end

    local res = '{ '
    local rep = 0
    local len = get_object_or_array_len(tab)

    if is_array(tab) then
        return "[Array]"
    end

    for k, v in tab do
        rep = rep + 1
        local pt = if len == rep then '' else ', '

        if typeof(v) ~= 'table' then
            v = format_print_value(v)
            if typeof(k) ~= 'number' then
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

        if typeof(k) ~= 'number' then
            res ..= `[{format_print_value(k)}] = [Array]{pt}`
            continue
        end

        res ..= `[Array]{pt}`
    end

    return res ..' }'
end

local function format_print_value(value: any): string
    local value_type = typeof(value)
    if value_type == 'table' then
        return table_to_string(value)
    end
    if value_type == 'string' then
        if (value::string):find('\n') then
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
        return `{string_prototype_repeat(' ', space / 2)}{str}{string_prototype_repeat(' ', space / 2)} `
    end

    return `{string_prototype_repeat(' ', space / 2)}{str}{string_prototype_repeat(' ', space / 2)}`
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
        if typeof(k) == 'number' then
            mix_t[k] = nil
        end
    end
    return mix_t
end

local function get_objectlen(arrOrObj)
    local result = 0
    for k, v in arrOrObj do
        if typeof(v) ~= 'number' then
            result += 1
        end
    end
    return result
end

local function arscii_change_setting(arscii: Arscii)
	if arscii.round then
		table_chars = chars.table_round_chars
		tree_chars = chars.tree_round_chars
		return
	end

	table_chars = chars.table_chars
	tree_chars = chars.tree_chars
end

local function arscii_table(value: TableType, arscii: Arscii): string
	table_type:assert(value)

	local table_main_index = arscii.table_main_index
	local table_main_value = arscii.table_main_value

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
			result ..= `{get_string_with_space(values_value[value_key[i]], get_max_len(table_main_value, values_value) + 2)}`
		else
			result ..= `{string_prototype_repeat(" ", get_max_len(table_main_value, values_value) + 2)}`
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

		children = mix_table_to_object(children)

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

			child = mix_table_to_object(child)
			
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
arscii_struct.table_main_index = "(index)"
arscii_struct.table_main_value = "Values"

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
