--!strict
local asciitable = require('../init')


local my_fruit = {
    apple = 4,
    banana = 6,
    orange = 1,
}

asciitable.round = true

print(asciitable.table(my_fruit))
print(asciitable.tree('orange', my_fruit))
