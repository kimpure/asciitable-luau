local asciitable = require('../src')

local my_favorite_fruit = {
    apple = 4,
    banana = 6,
    orange = 1,
}

local my_favorite_virtuber = {
    viichan = "VIichan",
    mawang = "MaWang0216",
}

local my_favorite = {
    fruit = my_favorite_fruit,
    virtuber = my_favorite_virtuber,
    'sunwoo',
    'kimpure',
    name = {
        main = 'sunwoo',
        github = 'kimpure'
    },
    test = {},
}

asciitable.round = true

print(asciitable.table(my_favorite))
-- print(asciitable.tree('a', {
--     ["/"] = {
--         dir1 = { },
--         dir2 = { },
--         ["file0.txt"] = {
--             attributes = 2175008768,
--             content = "File at the root.\n this is test only",
--             size = 18,
--         },
--     },
-- }))