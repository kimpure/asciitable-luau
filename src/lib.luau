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
	tree: (top: any, child: { [any]: any }, cfg: TreeConfig?) -> string,

	--[=[
		@within ArsciiTable
		
		Draw a chart
		
		```luau
		print(asciitable.plot({ 1, 2, 3, 4 }))
		```

		```luau
		print(asciitable.plot({ 1, 2, 3, 4 }, { height = 4, offset = 2 }))
		```

		@param series Number array to be drawn
		@param config Draw options
		@return string
	]=]
	plot: (series: { number }, cfg: PlotConfig?) -> string,
}

local asciitable = {} :: ArsciiTable
asciitable.round = false

--[=[
	@class TreeConfig
]=]
type TreeConfig = {
	--[=[
		@within TreeConfig

		Whether to apply the custom formatter to node values

		Default = true
	]=]
	format: boolean?,
}

function asciitable.tree(top, children, cfg)
	assert(typeof(children) == "table", `invalid argument #2 to 'tree' (table expected, got {typeof(children)})`)

	local function mixedtable_len(tab: { [any]: any })
		local result = 0

		for k, v in tab do
			result += 1
		end

		return result
	end

	local function format_print_value(value: any): string
		local value_type = typeof(value)

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

	local cfg: TreeConfig = cfg or {}
	local use_format = cfg.format == nil and true or cfg.format
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

		for i = 1, #key_hashmap do
			local k = key_hashmap[i]
			local v = value[k]

			local is_last = mixedtable_len(value) == i

			for i = 1, #lt do
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
				result ..= ": " .. (use_format and format_print_value(v) or v) .. "\n"
			end
		end
	end

	make_table_tree(0, children, {})

	return result
end

--[=[
	@class PlotConfig
]=]
type PlotConfig = {
	--[=[
		@within PlotConfig

		Vertical offset (number of rows to shift downward)
	]=]
	offset: number?,

	--[=[
		@within PlotConfig

		Height of the chart in rows
	]=]
	height: number?,

	--[=[
		@within PlotConfig

		Horizontal gap between data points
	]=]
	gap: number?,

	--[=[
		@within PlotConfig
		
		Whether to display the x-axis (true = show, false = hide)
	]=]
	xaxis: boolean?,
}

function asciitable.plot(series, cfg)
	assert(typeof(series) == "table", `invalid argument #1 to 'plot' (table expected, got {typeof(series)})`)
	assert(cfg == nil or typeof(cfg) == "table", `invalid argument #2 to 'plot' (table expected, got {typeof(cfg)})`)

	local cfg: PlotConfig = cfg or {}
	local symbols = asciitable.round and round_symbols or normal_symbols

	local minimum, maximum = math.huge, -math.huge

	for i = 1, #series do
		minimum = math.min(minimum, series[i])
		maximum = math.max(maximum, series[i])
	end

	if minimum > maximum then
		return ""
	end

	local offset = cfg.offset or 1
	local height = cfg.height or (maximum - minimum)
	local gap = cfg.gap or 0

	local ratio = (maximum - minimum) > 0 and height / (maximum - minimum) or 1

	local min2 = math.floor(minimum * ratio)
	local max2 = math.ceil(maximum * ratio)
	local rows = max2 - min2

	local width = #series * (gap + 1) + (offset + 1)
	local result = {}

	for i = 1, rows + 1 do
		result[i] = {}
		for j = 1, width do
			result[i][j] = " "
		end
	end

	local max_val_len = 8

	for i = 0, max2 - min2, 1 do
		local val = maximum - (i * (maximum - minimum) / (rows ~= 0 and rows or 1))
		local label = string.format("%8.2f", val)

		result[i + 1][1] = label
		result[i + 1][offset + 1] = symbols.rightMiddle

		max_val_len = math.max(max_val_len, #label)
	end

	for i = 0, max2 - min2, 1 do
		local val = maximum - (i * (maximum - minimum) / (rows ~= 0 and rows or 1))
		local label = string.format("%8.2f", val)

		result[i + 1][1] = string.rep(" ", max_val_len - #label) .. label
	end

	for x = 1, #series do
		local d0 = series[x]
		local d1 = series[x + 1]

		local y0 = math.round(math.clamp(d0, minimum, maximum) * ratio) - min2
		local y1 = d1 and math.round(math.clamp(d1, minimum, maximum) * ratio) - min2 or nil

		local row0 = rows - y0 + 1
		local col = x * (gap + 1) + (offset + 1)

		result[row0][col] = symbols.middleMiddle

		for i = 1, gap do
			result[row0][col - i] = symbols.middleMiddle
		end

		if not y1 then
			continue
		end

		local row1 = rows - y1 + 1
		result[row1][col] = y0 > y1 and symbols.bottomLeft or symbols.topLeft
		result[row0][col] = y0 > y1 and symbols.topRight or symbols.bottomRight

		for i = math.min(row0, row1) + 1, math.max(row0, row1) - 1, 1 do
			result[i][col] = symbols.middle
		end
	end

	local con = ""

	for i = 1, #result do
		con ..= table.concat(result[i]) .. "\n"
	end

	con ..= string.rep(symbols.middleMiddle, max_val_len + offset - 1)
	con ..= symbols.bottomMiddle
	con ..= string.rep(symbols.middleMiddle, #series * (gap + 1))

	if cfg.xaxis then
		con ..= "\n"
		con ..= string.rep(" ", max_val_len + offset)

		for i = 1, #series do
			con ..= string.rep(" ", gap) .. i
		end
	end

	return con
end

return asciitable
