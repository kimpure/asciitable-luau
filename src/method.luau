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

        if typeof(k) ~= 'number' then
            res ..= `[{format_print_value(k)}] = {table_to_string(v)}{pt}`
            continue
        end
        res ..= `{table_to_string(v)}{pt}`
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

local function get_vk_max_len(key: string, argumend): number
    local max_len = utf8_len(key)
    for _, v in argumend do
        if max_len < utf8_len(v) then
            max_len = utf8_len(v)
        end
    end
    return max_len
end

return {
    format_print_value=format_print_value,
    get_argument_codepoint_order=get_argument_codepoint_order,
    get_object_or_array_len=get_object_or_array_len,
    get_vk_max_len=get_vk_max_len,
    string_prototype_repeat=string_prototype_repeat,
    table_to_string=table_to_string,
}