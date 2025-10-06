local asciitable = require('../src/lib')
asciitable.round = true

print(asciitable.tree('tree', { adir = { "bfile", "cfile" }, bdir = { "cfile", "dfile" } }))
print(asciitable.plot({ 0, 10, 20, 30, 40, 30, 20, 10, 0 }, { height = 4, offset = 2, gap = 2, xaxis = true }))
