local asciitable = require('../src')

asciitable.mergeIndexLabels = true

asciitable.round = true

asciitable.table_main_index = 'main index'

asciitable.table_main_value = 'main values'

local test_table = {
    apple = 'apple',
    banana = {
        yello = 'yello',
        green = 'green',
    },
}

print(asciitable.table(test_table))

print(asciitable.tree('sunwoo', test_table))