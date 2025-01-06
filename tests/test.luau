--!strict
local asciitable = require('../init')


local my_fruit = {
    apple = 4,
    banana = 6,
    orange = 1,
}

print(asciitable.table(my_fruit))