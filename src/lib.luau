local gt = require("../luau_packages/greentea_luau")
local table_type = gt.build(gt.table({ [gt.any()] = gt.any() }))
local numarr_type = gt.build(
	gt.array(
		gt.union(
			gt.number(),
			gt.array(gt.number())
		)
	)
)

local normal_symbols = {
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

local round_symbols = {
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
		
		Draw a tree
		
		```luau
		print(asciitable.tree('sunwoo', table))
		```

		@param top The string to be located at the top
		@param child Child to be included in tree
		@return string
	]=]
	tree: (top: any, child: { [any]: any }) -> string,

	--[=[
		@within ArsciiTable
		
		Draw a chart
		
		```luau
		print(asciitable.chart({ 1, 2, 3, 4 }))
		```

		@param series Number array to be drawn
		@param offset Chart's offset
		@param height Chart's height
		@return string
	]=]
	chart: (series: { number } | { { number } }, offset: number?, height: number?) -> string,
}

local asciitable = {} :: ArsciiTable
asciitable.round = false

local function mixedtable_len(tab: { [any]: any })
	local result = 0
	
	for k, v in tab do
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
	local len = mixedtable_len(tab)

	if is_array(tab) then
		return "[Array]"
	end

	for k, v in tab do
		rep += 1

		local pt = len == rep and "" or ", "

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
		if string.find(value, "\n") then
			if string.sub(value, -1) == "\n" then
				value = string.sub(value, 1, #value - 2)
			end

			return `[[{value}]]`
		end

		return `'{value}'`
	end

	return tostring(value)
end

local function char_clamp(val, lower, upper)
	return math.max(lower, math.min(val, upper))
end

function asciitable.tree(top, children)
	assert(table_type(children))

	local symbols = asciitable.round and round_symbols or normal_symbols
	local result = tostring(top) .. "\n"

	local function make_table_tree(tab_size: number, value: { [any]: any }, lt: { boolean })
		local key_hashmap = {}

		for k, _ in value do
			table.insert(key_hashmap, k)
		end

		table.sort(key_hashmap, function(a, b)
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
		
		for i=1, #key_hashmap do
			local k = key_hashmap[i]
			local v = value[k]

			local is_last = mixedtable_len(value) == i

			for i=1, #lt do
				if lt[i] then
					result ..= " "
				else
					result ..= symbols.middle
				end
			end
			
			if is_last then
				result ..= symbols.bottomLeft
			else
				result ..= symbols.leftMiddle
			end
	
			if typeof(v) == "table" and mixedtable_len(v) ~= 0 then
				result ..= symbols.topMiddle
			else
				result ..= symbols.middleMiddle
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

function asciitable.chart(series, offset, height)
	assert(numarr_type(series)) 

	local len = #series

	if len == 0 then
		return ""
	end	

	local series = (type(series[1]) ~= "table" and { series :: { number } } or series) :: { { number } }

	local symbols = asciitable.round and round_symbols or normal_symbols

	local minimum, maximum = math.huge, -math.huge

	for i=1, #series do
		for j=1, #series[i] do
			local val = series[i][j]
			minimum = math.min(minimum, val)
			maximum = math.max(maximum, val)
		end
	end

	if minimum > maximum then
		return ""
	end

	local interval = maximum - minimum

	local offset = offset or 3
	local height = height or interval
 
	local ratio = interval > 0 and height / interval or 1

	local min2 = math.floor(minimum * ratio)
	local max2 = math.ceil(maximum * ratio)

	local rows = max2 - min2
	local width = 0

	for i=1, #series do
		width = math.max(width, #series[i])
	end

	width += offset

	local result = {}

	for i=1, rows + 1 do
		result[i] = {}

		for j=1, width do
			result[i][j] = " "
		end
	end

	for i=min2, max2, 1 do
		local label = string.format(maximum - ((i - min2)  * interval / (rows == 0 and 1 or rows)) :: any, "%8.2f") .. " "
		result[i - min2 + 1][math.max(offset - #label, 1)] = label
		result[i - min2 + 1][offset] = i == min2 and "┼" or "┤"
	end

	local d0: number
	local d1: number

	for i=1, #series do
		for x=1, #series[i] - 1 do
			d0 = series[i][x]
			d1 = series[i][x + 1]

			local y0 = math.round(char_clamp(d0, minimum, maximum) * ratio) - min2
			local y1 = math.round(char_clamp(d1, minimum, maximum) * ratio) - min2

			if y0 == y1 then
				result[rows - y0 + 1][x + offset] = "─"
			else
				result[rows - y1 + 1][x + offset] = y0 > y1 and symbols.bottomLeft or symbols.topLeft
				result[rows - y0 + 1][x + offset] = y0 > y1 and symbols.topRight or symbols.bottomRight

				local s = math.min(y0, y1) + 1
				local e = math.max(y0, y1) - 1

				for k=s, e, 1 do
					result[rows - k + 1][x + offset] = "│"
				end
			end
		end
	end

	local con = ""

	for i = 1, #result do
		con = con .. table.concat(result[i])
		if i ~= #result then
			con = con .. "\n"
		end
	end

	return con
end

return asciitable
