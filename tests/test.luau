local asciitable = require('../src/lib')

local sinf = {}

for x=1, 360, 10 do
    table.insert(sinf, math.sin(math.rad(x)))
end

print(asciitable.plot(sinf, {
    height = 36,
    gap = 1,
    xaxis = true,
    round = true,
}))

