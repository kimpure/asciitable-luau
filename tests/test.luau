local asciitable = require('../src/lib')
asciitable.round = true

print(asciitable.tree('sunwoo', { a = "apple" }))
print(asciitable.chart({ 2, 4, 6 }, 3))
