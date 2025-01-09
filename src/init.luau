local green_tea = require('../lune_packages/greentea')

local table_type = green_tea.build(green_tea.table{ 
    [green_tea.any()] = green_tea.any()
})

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

export type TableType = typeof(table_type:type())

export type Arscii = typeof(setmetatable({} :: {
    round: boolean,
    mergeIndexLabels: boolean,
    tree: (top: any, child: TableType) -> (string),
    table: (value: TableType) -> (string),
}, {}))

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
        if arscii.mergeIndexLabels then
            result ..= table_chars.leftMiddle

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
        elseif j == 1 then
            result ..= table_chars.leftMiddle

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
        end

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

local function arscii_tree(top: any, children: TableType, arscii: Arscii): string
    table_type:assert(children)
    
    local result = tostring(top)

    local function add_tree(loop_num: number, children, last_child)
        local children_key = {}
        local children_value = {}

        for k, v in children do
            if typeof(k) == 'number' then
                continue
            end
            children_key[#children_key + 1] = k
        end

        children_key = get_argument_codepoint_order(children_key)
        
        for i=1, #children_key do
            children_value[i] = children[children_key[i]]
        end
        
        for i=1, #children_key do
            result ..= '\n'

            if last_child then
                result ..= string_prototype_repeat(' ', loop_num)
            else
                result ..= string_prototype_repeat(tree_chars.middle, loop_num)
            end

            if #children_key == i then
                result ..= tree_chars.bottomLeft
            else
                result ..= tree_chars.leftMiddle
            end

            local child = children_value[i]

            if typeof(child) ~= 'table' then
                result ..= tree_chars.middleMiddle

                result ..= ` {children_key[i]}: {format_print_value(child)}`

                continue
            end

            if get_object_or_array_len(child) == 0 then
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