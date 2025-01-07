local method = require('./method')

local format_print_value = method.format_print_value
local get_argument_codepoint_order = method.get_argument_codepoint_order
local get_object_or_array_len = method.get_object_or_array_len
local get_vk_max_len = method.get_vk_max_len
local string_prototype_repeat = method.string_prototype_repeat
local utf8_len = utf8.len :: (string, number?, number?) -> (number)

local config = require('./config')

local table_chars = config.table_chars
local tree_chars = config.tree_chars

local table_main_index = config.table_main_index
local table_main_value = config.table_main_value

export type arscii = typeof(setmetatable({} :: {
    round: boolean,
    tree: (top: string, child: { [any]: any }) -> (string),
    table: (value: { [any]: any }) -> (string),
}, {}))

local function arscii_change_setting(arscii: arscii)
    if arscii.round then
        table_chars = config.table_round_chars
        tree_chars = config.tree_round_chars
        return
    end

    table_chars = config.table_chars
    tree_chars = config.tree_chars
end

local function arscii_table(value: { [any]: any }): string
    if typeof(value) ~= 'table' then
        return tostring(value)
    end

    local result = ''

    local value_key = {}

    local index_key = {}
    local index_value = {}

    local values_key = {}
    local values_value = {}

    for k, v in value do
        value_key[#value_key + 1] = k
        if typeof(k) == 'number' and typeof(v) ~= 'table' then
            values_value[#values_value + 1] = format_print_value(v)
            values_key[#values_key + 1] = k
            continue
        end
        index_value[#index_value + 1] = format_print_value(v)
        index_key[#index_key + 1] = k
    end

    value_key = get_argument_codepoint_order(value_key)

    index_key = get_argument_codepoint_order(index_key)
    for i=1, #index_key do
        index_value[i] = format_print_value(value[index_key[i]])
    end
    
    values_key = get_argument_codepoint_order(values_key)
    for i=1, #values_key do
        values_value[i] = format_print_value(value[values_key[i]])
    end

    local index_max_len = get_vk_max_len(table_main_index, index_key)

    local values_max_len = get_vk_max_len(table_main_value, values_value)

    result ..= table_chars.topLeft

    result ..= string_prototype_repeat(table_chars.middleMiddle, index_max_len + 2)

    for i=1, #index_key do
        local max_len = utf8_len(tostring(index_key[i]))
        if utf8_len(index_value[i]) > max_len then
            max_len = utf8_len(index_value[i])
        end

        result ..= table_chars.topMiddle

        result ..= string_prototype_repeat(table_chars.middleMiddle, max_len + 2)
    end

    result ..= table_chars.topMiddle

    result ..= string_prototype_repeat(table_chars.middleMiddle, values_max_len + 2)

    result ..= table_chars.topRight

    result ..= '\n'

    result ..= table_chars.middle

    result ..= ` {table_main_index}{string_prototype_repeat(' ', index_max_len - utf8_len(table_main_index))} `

    result ..= table_chars.middle

    for i=1, #index_key do
        local max_len = utf8_len(tostring(index_key[i]))
        if utf8_len(index_value[i]) > max_len then
            max_len = utf8_len(index_value[i])
        end

        local v = index_key[i]

        result ..= ` {v}{string_prototype_repeat(' ', max_len - utf8_len(tostring(v)))} `

        result ..= table_chars.middle
    end

    result ..=  ` {table_main_value}{string_prototype_repeat(' ', values_max_len - utf8_len(table_main_value))} `

    result ..= table_chars.middle

    result ..= '\n'

    for j=1, #value_key do
        result ..= table_chars.middle

        result ..= string_prototype_repeat(table_chars.middleMiddle, index_max_len + 2)
    
        for i=1, #index_key do
            local max_len = utf8_len(tostring(index_key[i]))
            if utf8_len(index_value[i]) > max_len then
                max_len = utf8_len(index_value[i])
            end
    
            result ..= table_chars.rowMiddle
    
            result ..= string_prototype_repeat(table_chars.middleMiddle, max_len + 2)
        end
    
        result ..= table_chars.rowMiddle
    
        result ..= string_prototype_repeat(table_chars.middleMiddle, values_max_len + 2)
    
        result ..= table_chars.rightMiddle
    
        result ..= '\n'

        result ..= table_chars.middle

        result ..= ` {value_key[j]}{string_prototype_repeat(' ', index_max_len - utf8_len(value_key[j]))} `
    
        result ..= table_chars.middle
    
        for i=1, #index_key do
            local max_len = utf8_len(tostring(index_key[i]))
            if utf8_len(index_value[i]) > max_len then
                max_len = utf8_len(index_value[i])
            end
            if index_key[i] ~= value_key[j] then
                result ..= ` {string_prototype_repeat(' ', max_len) } `
                result ..= table_chars.middle
                continue
            end

            local v = index_value[i]

            result ..= ` {v}{string_prototype_repeat(' ', max_len - utf8_len(v))} `
    
            result ..= table_chars.middle
        end
        
        result ..=  ` {values_value[j] or ''}{string_prototype_repeat(' ', values_max_len - utf8_len(values_value[j] or ''))} `

        result ..= table_chars.middle

        result ..= '\n'
    end
    
    result ..= table_chars.bottomLeft

    result ..= string_prototype_repeat(table_chars.middleMiddle, index_max_len + 2)
    
    for i=1, #index_key do
        local max_len = utf8_len(tostring(index_key[i]))
        if utf8_len(index_value[i]) > max_len then
            max_len = utf8_len(index_value[i])
        end
    
        result ..= table_chars.bottomMiddle
    
        result ..= string_prototype_repeat(table_chars.middleMiddle, max_len + 2)
    end
    
    result ..= table_chars.bottomMiddle
    
    result ..= string_prototype_repeat(table_chars.middleMiddle, values_max_len + 2)
    
    result ..= table_chars.bottomRight

    return result
end

local function arscii_tree(top: any, child: { [any]: any }): string
    local result = tostring(top)
    local voidDefultSize = ' '
    local defultMiddleVoidSize = ' '
    local defultHightMiddle = tree_chars.middle
    local defultWightMiddle = tree_chars.middleMiddle
    
    local function child_result(argument: { [any]: any }, voidSize: number)
        local childMaxLoopCound = get_object_or_array_len(argument)
        local childCount = 0 

        local ak = {}
        local avalue = {}

        for k, v in argument do
            ak[#ak + 1] = k
        end

        ak = get_argument_codepoint_order(ak)

        for k, v in ak do
            avalue[k] = argument[v]
        end

        for i=1, #ak do
            local k = ak[i]
            local v = avalue[i]
            k = tostring(k)
            childCount += 1
            
            local hightMiddle = tree_chars.leftMiddle
            local argumentIsTable = typeof(v) == 'table' and not v.TREE_INSTANCE
            local widthMiddle = if argumentIsTable then tree_chars.topMiddle else defultWightMiddle
            
            if childCount == childMaxLoopCound then 
                hightMiddle = tree_chars.bottomLeft 
            end
            if argumentIsTable and get_object_or_array_len(v) == 0 then 
                widthMiddle = defultWightMiddle 
            end
            
            result ..= `\n{defultMiddleVoidSize}{string_prototype_repeat(`{defultHightMiddle}{voidDefultSize}`, voidSize)}{hightMiddle}{defultWightMiddle}{widthMiddle} {k}`
            if argumentIsTable then
                if childCount == childMaxLoopCound then
                    defultMiddleVoidSize = '   '
                    child_result(v, voidSize)
                else
                    child_result(v, voidSize+1)
                end
            else
                if typeof(v) == 'table' then
                    result ..= `: {v.TREE_INSTANCE}`
                    v.TREE_INSTANCE = nil
                    child_result(v, voidSize+1)
                else
                    result ..= `: {v}`
                end    
            end
        end
    end
    
    child_result(child :: any, 0)

    return result
end

local arscii_struct = {}
arscii_struct.round = false

local arscii_impl = {}
arscii_impl.__index = arscii_impl

local arscii = setmetatable(arscii_struct, arscii_impl)

function arscii.table(value: { [any]: any }) 
    arscii_change_setting(arscii)
    return arscii_table(value)
end

function arscii.tree(top: any, child: { [any]: any }) 
    arscii_change_setting(arscii)
    return arscii_tree(top, child)
end

return arscii :: arscii