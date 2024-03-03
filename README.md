## Example: read a large file line by line (Golang vs. Zig)

[inspired by Karl Seguin](https://www.openmymind.net/Performance-of-reading-a-file-line-by-line-in-Zig/)

#### libs
```
wget wget https://raw.githubusercontent.com/karlseguin/zul/master/src/benchmark.zig
```
#### input file
```
wget https://raw.githubusercontent.com/json-iterator/test-data/master/large-file.json
```
#### buffer lib

[zul.fs.readlines](https://www.goblgobl.com/zul/fs/readlines/)
