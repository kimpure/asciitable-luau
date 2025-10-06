# AsciiTable
<img src="https://raw.githubusercontent.com/kimpure/asciitable-luau/refs/heads/master/image/normal.png">
<img src="https://raw.githubusercontent.com/kimpure/asciitable-luau/refs/heads/master/image/round.png">

## install
```
pesde add kimpure/asciitable
```

## using
```luau
local asciitable = require(path)
```

tree [config](https://github.com/kimpure/asciitable-luau/blob/f6217f50075ecdb1af30c864c0c428b42a938574/src/lib.luau#L107)
```luau
print(asciitable.tree(string, table, config))
```

plot [config](https://github.com/kimpure/asciitable-luau/blob/f6217f50075ecdb1af30c864c0c428b42a938574/src/lib.luau#L225)
```luau
print(asciitable.plot({ number }, config))
```

round
```luau
asciitable.round = true
```

## dependencies
[greentea](https://github.com/Corecii/GreenTea) <br>
