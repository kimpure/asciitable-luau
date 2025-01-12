local utf8_len = utf8.len :: (string, number?, number?) -> (number)

local function get_object_or_array_len(arrOrObj)
    local result = 0
    for k, v in arrOrObj do
        result += 1
    end
    return result
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

return {
    format_print_value=format_print_value,
    get_argument_codepoint_order=get_argument_codepoint_order,
    get_object_or_array_len=get_object_or_array_len,
    get_objectlen=get_objectlen,
    get_string_with_space=get_string_with_space,
    get_max_len=get_max_len,
    string_prototype_repeat=string_prototype_repeat,
    object_to_key_array=object_to_key_array,
    table_to_string=table_to_string,
}