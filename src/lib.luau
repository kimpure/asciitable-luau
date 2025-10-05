local green_tea = require("../luau_packages/greentea_luau")

local table_type = green_tea.build(green_tea.table({ [green_tea.any()] = green_tea.any() }))

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
		
		Display in tree format
		
		```luau
		print(asciitable.tree('sunwoo', table))
		```

		@param top -- The string to be located at the top
		@param child -- Child to be included in tree
	]=]
	tree: (top: any, child: { [any]: any }) -> string,
}

local asciitable = {} :: ArsciiTable
asciitable.round = false

local function get_object_or_array_len(arrOrObj)
	local result = 0
	for k, v in arrOrObj do
		result += 1
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

local function mix_table_to_object<T>(mix_t: { [any]: T }): { [string]: T }
	for k, v in mix_t do
		if typeof(k) == "number" then
			mix_t[k] = nil
			mix_t[tostring(k)] = v
		end
	end
	return mix_t
end

function asciitable.tree(top, children)
	table_type:assert(children)

	local chars = asciitable.round and round_chars or normal_chars
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
			local is_last = get_object_or_array_len(value) == loop_index

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
	
			if typeof(v) == "table" and get_object_or_array_len(v) ~= 0 then
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
	
	make_table_tree(0, children, get_object_or_array_len(children) == 1 and { true } or {})

	return result
end

return asciitable
