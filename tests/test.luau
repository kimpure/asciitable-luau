local asciitable = require('../src/lib')
asciitable.round = true

print(asciitable.tree('sunwoo', { a = "apple" }))
print(asciitable.plot({ 0, 0.1, 0.2, 0.3, 0.2, 0.1, 0 }, { height = 4, offset = 2, gap = 2, xaxis = true }))
