local asciitable = require('../src/lib')
asciitable.round = true

print(asciitable.tree('sunwoo', { a = "apple" }))
print(asciitable.plot({ 0, 10, 20 }, { height = 4, offset = 2, }))
