local asciitable = require('../src')

local my_favorite_fruit = {
    apple = 4,
    banana = 6,
    orange = 1,
}

local my_favorite_virtuber = {
    "VIichan",
    "MaWang0216",
}

local my_favorite = {
    fruit = my_favorite_fruit,
    virtuber = my_favorite_virtuber,
    'sunwoo',
    'kimpure',
}

asciitable.round = true

print(asciitable.table(my_favorite))
print(asciitable.tree('sunwoo', my_favorite))