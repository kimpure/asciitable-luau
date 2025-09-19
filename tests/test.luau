local asciitable = require('../src/lib')

asciitable.merge_index_labels = true

-- asciitable.round = true

asciitable.table_main_index = 'main index'

asciitable.table_main_value = 'main values'

local test_table = {
    apple = 'apple',
    bana12na = {
        'yello',
        'green',
        banana = {
        'yello',
        'green',
    },
    ban2ana = {
        'yello',
        'green',
    },
    bana1n3a = {
        'yello',
        'green',
    },
    bana4n3a = {
        'yello',
        'green',
    },

    },
    bana1na = {
        'yello',
        'green',
    },
    banan2a = {
        'yello',
        'green',
        banana = {
        'yello',
        'green',
    },
    },
    c = "asd",

}

-- print(asciitable.table(test_table))

print(asciitable.tree('sunwoo', test_table))