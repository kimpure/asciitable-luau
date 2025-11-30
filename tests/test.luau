local asciitable = require('../src/lib')

local sinf = {}

for x=1, 360, 10 do
    table.insert(sinf, math.sin(math.rad(x)))
end

print(asciitable.tree("sin function", sinf, {
    round = true,
}))

print(asciitable.plot(sinf, {
    height = 36,
    gap = 1,
    xaxis = true,
    round = true,
}))

print(asciitable.tostring(sinf, {
    tab_size = 2,
    format = "[%s] = %s"
}))

