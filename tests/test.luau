local asciitable = require('../src')

-- asciitable.mergeIndexLabels = true

-- asciitable.round = true

local test_table = {
    apple = 'apple',
    banana = {
        yello = 'yello',
        green = 'green',
    },
}

print(asciitable.table(test_table))

print(asciitable.tree('sunwoo', test_table))