local asciitable = require('../src')

-- asciitable.mergeIndexLabels = true

-- asciitable.round = true

print(asciitable.table{
    apple = 'apple',
    banana = {
        'yello',
        'green',
    },
})