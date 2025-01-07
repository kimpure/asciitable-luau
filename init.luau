--!strict

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

local function format_print_value(value: any)
    local value_type = typeof(value)
    if value_type == 'string' then
        return `'{value}'`
    end
    return tostring(value)
end

local function table_to_string(tab)
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

local table_chars = {
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
}

local tree_chars = {
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
}

local function arscii_change_setting(arscii: typeof(setmetatable({} :: { round: boolean }, {} :: any)))
    if arscii.round then
        table_chars = {
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
        }
        tree_chars = {
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
        }
        return
    end

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
    }

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
    } 
end

local table_main_index = "(index)"
local table_main_value = "Values"

local function arscii_table(value: { [any]: any }): string
    if typeof(value) ~= 'table' then
        return tostring(value)
    end

    local result = table_chars.topLeft .. string_prototype_repeat(table_chars.middleMiddle, utf8.len(table_main_index) :: number + 2)
    
    local index = {}
    local values = {}
    
    for k, v in value do
        index[k] = table_to_string(v)
        if typeof(v) ~= 'table' then
            index[k] = format_print_value(index[k])
        end
        if typeof(v) == 'table' or typeof(k) ~= 'number' then
            continue
        end
        index[k] = nil
        values[k] = v
    end

    for k, v in index do
        if utf8.len(v) < utf8.len(k) then
            result ..= table_chars.topMiddle .. string_prototype_repeat(table_chars.middleMiddle, utf8.len(k) :: number + 2)
            continue
        end
        result ..= table_chars.topMiddle .. string_prototype_repeat(table_chars.middleMiddle, utf8.len(v) :: number + 2)
    end
    
    result ..= table_chars.topMiddle .. string_prototype_repeat(table_chars.middleMiddle, utf8.len(table_main_value) :: number + 2)
    
    result ..= table_chars.topRight .. '\n' .. table_chars.left

    result ..= table_main_index .. table_chars.right

    for k, v in index do
        result ..= ' ' .. k .. string_prototype_repeat(' ', utf8.len(v) :: number - 1) .. table_chars.right
    end

    
    result ..= ' ' .. table_main_value .. table_chars.right .. '\n' 
    
    
    for j, _ in value do
        result ..= table_chars.leftMiddle .. string_prototype_repeat(table_chars.middleMiddle, utf8.len(table_main_index) :: number + 2) .. table_chars.rowMiddle
        for k, v in index do
            if utf8.len(v) < utf8.len(k) then
                result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(k) :: number + 2) .. table_chars.rowMiddle
                continue
            end
            result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(v) :: number + 2) .. table_chars.rowMiddle
        end
    
        result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(table_main_value) :: number + 2) .. table_chars.rightMiddle .. '\n'
        result ..= table_chars.left .. `{j}` .. string_prototype_repeat(' ', utf8.len(table_main_index) :: number - (utf8.len(j :: any) :: number - 1)) .. table_chars.left
        local is_values = ''
        for k, _ in value do
            if j == k and values[j] then
                local v = values[j]
                is_values = v
                continue
            end
            local v = index[k]
            if not v then
                continue
            end
            if k == j then
                if utf8.len(v) < utf8.len(k) then
                    result ..= v .. string_prototype_repeat(' ', utf8.len(k) :: number - utf8.len(v) :: number + 1) .. table_chars.left
                    continue
                end
                result ..= v .. ' ' .. table_chars.left
                continue
            end
            if utf8.len(v) < utf8.len(k) then
                result ..= string_prototype_repeat(' ', utf8.len(k) :: number - utf8.len(v) :: number + 2) .. table_chars.left
                continue
            end
            result ..= string_prototype_repeat(' ', utf8.len(v) :: number + 1) .. table_chars.left
        end
        result ..= is_values .. string_prototype_repeat(' ', utf8.len(table_main_value) :: number - utf8.len(is_values) :: number) .. table_chars.right .. '\n'
    end 

    result ..= table_chars.bottomLeft

    result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(table_main_index) :: number + 2) .. table_chars.bottomMiddle
    
    for k, v in index do
        if utf8.len(v) < utf8.len(k) then
            result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(k) :: number + 2) .. table_chars.bottomMiddle
            continue
        end
        result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(v) :: number + 2) .. table_chars.bottomMiddle
    end

    result ..= string_prototype_repeat(table_chars.middleMiddle, utf8.len(table_main_value) :: number + 2) .. table_chars.bottomRight

    return result
end

local function arscii_tree(top: any, child: { [any]: any }): string
    local result = tostring(top)
    local voidDefultSize = ' '
    local defultMiddleVoidSize = ' '
    local defultHightMiddle = tree_chars.middle
    local defultWightMiddle = tree_chars.middleMiddle
    
    local function childResult(argument: { [any]: any }, voidSize: number)
        local childMaxLoopCound = get_object_or_array_len(argument)
        local childCount = 0 
        for k, v in argument do
            if typeof(k) ~= 'string' then 
                k = tostring(k) 
            end
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
                    childResult(v, voidSize)
                else
                    childResult(v, voidSize+1)
                end
            else
                if typeof(v) == 'table' then
                    result ..= `: {v.TREE_INSTANCE}`
                    v.TREE_INSTANCE = nil
                    childResult(v, voidSize+1)
                else
                    result ..= `: {v}`
                end    
            end
        end
    end
    
    childResult(child :: any, 0)

    return result
end

local arscii_struct = {}
arscii_struct.round = false

local arscii_impl = {}
arscii_impl.__index = arscii_impl
arscii_impl.tree = arscii_tree

local arscii = setmetatable(arscii_struct, arscii_impl)

arscii.table = function(value: { [any]: any }) 
    arscii_change_setting(arscii)
    return arscii_table(value)
end

arscii.tree = function(top: any, child: { [any]: any }) 
    arscii_change_setting(arscii)
    return arscii_tree(top, child)
end

return arscii