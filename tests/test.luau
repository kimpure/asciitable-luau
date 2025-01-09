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

asciitable.round = false
asciitable.mergeIndexLabels = false

-- print(asciitable.table(my_favorite))
-- print(asciitable.tree('sunwoo', my_favorite))

print(asciitable.table{
    apple = 'apple',
    tree = {
        'banana',
        'appleddddddd',
        { 'a', 'b' },
    } :: { [any]: any }
})