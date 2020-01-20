# 用于Solidity的String＆Slice实用程序库

## 总览

该库中的功能主要使用称为“切片”的抽象来实现。切片代表字符串的一部分-从整个字符串到单个字符，甚至根本没有任何字符（长度为0的切片）。由于切片只需指定偏移量和长度，因此复制和处理切片比复制和处理它们引用的字符串要便宜得多。

为了进一步降低天然气成本，切片上需要返回切片的大多数函数都修改了原来的函数，而不是分配新的函数。例如，`s.split(".")`将返回直到第一个“。”的文本，将s修改为仅包含“。”之后的字符串的其余部分。如果您不想修改原始切片，则可以使用进行复制`.copy()`，例如：`s.copy().split(".")`。尝试避免在循环中使用此惯用法；由于Solidity没有内存管理，因此将导致分配许多短命的切片，这些切片随后将被丢弃。

返回两个切片的函数有两种版本：非分配版本，它以第二个切片为参数，对其进行修改；以及分配版本，它分配并返回第二个切片；参见`nextRune`例如。

必须复制字符串数据的函数将返回字符串而不是切片。如果需要，可以将它们转换回切片以进行进一步处理。

## 例子

### 基本用法

```
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract Contract {
    using strings for *;

    // ...
}
```

### 获取字符串的字符长度

```
var len = "Unicode snowman ☃".toSlice().len(); // 17
```

### 在定界符周围分割字符串

```
var s = "foo bar baz".toSlice();
var foo = s.split(" ".toSlice());
```

上面的代码执行后，`s`现在是“ bar baz”，`foo`现在是“ foo”。

### 将字符串拆分为数组

```
var s = "www.google.com".toSlice();
var delim = ".".toSlice();
var parts = new string[](s.count(delim) + 1);
for(uint i = 0; i < parts.length; i++) {
    parts[i] = s.split(delim).toString();
}
```

### 提取字符串的中间部分

```
var s = "www.google.com".toSlice();
strings.slice memory part;
s.split(".".toSlice(), part); // part and return value is "www"
s.split(".".toSlice(), part); // part and return value is "google"
```

通过`part`为提取的字符串的每个部分重用切片，此方法使用的内存少于上述方法。

### 将切片转换回字符串

```
var myString = mySlice.toString();
```

### 查找并返回第一次出现的子字符串

```
var s = "A B C B D".toSlice();
s.find("B".toSlice()); // "B C B D"
```

`find`修改`s`以包含从第一个匹配开始的字符串部分。

### 查找并返回子字符串的最后一次出现

```
var s = "A B C B D".toSlice();
s.rfind("B".toSlice()); // "A B C B"
```

`rfind`修改`s`以包含从最后一次匹配到开始的字符串部分。

### 查找而不修改原始切片。

```
var s = "A B C B D".toSlice();
var substring = s.copy().rfind("B".toSlice()); // "A B C B"
```

`copy` 可让您廉价地复制切片，而无需修改原始切片。

### 前缀和后缀匹配

```
var s = "A B C B D".toSlice();
s.startsWith("A".toSlice()); // True
s.endsWith("D".toSlice()); // True
s.startsWith("B".toSlice()); // False
```

### 删除前缀或后缀

```
var s = "A B C B D".toSlice();
s.beyond("A ".toSlice()).until(" D".toSlice()); // "B C B"
```

`beyond`修改`s`以在其参数后包含文本；`until`修改`s`以包含其参数为止的文本。如果找不到该参数，`s`则未修改。

### 查找并返回字符串直到第一个匹配项

```
var s = "A B C B D".toSlice();
var needle = "B".toSlice();
var substring = s.until(s.copy().find(needle).beyond(needle));
```

调用return `find`的副本会`s`从头`needle`开始返回字符串的一部分；调用`.beyond(needle)`removes `needle`作为前缀，最后调用`s.until()`removes删除字符串的整个结尾，保留所有内容，包括第一个匹配项。

### 连接字符串

```
var s = "abc".toSlice().concat("def".toSlice()); // "abcdef"
```

## 参考

### toSlice（字符串自身）内部返回（slice）

返回包含整个字符串的切片。

参数：

- self从中进行切片的字符串。

返回一个包含整个字符串的新分配的片。

### 复制（切片自身）内部收益（切片）

返回一个包含与当前切片相同数据的新切片。

参数：

- self要复制的切片。

返回包含与相同数据的新切片`self`。

### toString（slice self）内部返回（字符串）

将切片复制到新字符串。

参数：

- self要复制的切片。

返回一个新分配的包含切片文本的字符串。

### len（slice self）内部返回值（uint）

返回切片的符文长度。请注意，此操作花费的时间与切片的长度成比例；避免循环使用它，`slice.empty()`如果只需要知道切片是否为空，则调用。

参数：

- self对其进行操作的切片。

返回值切片的长度，以符文表示。

### 空（切片自身）内部返回（布尔）

如果切片为空（长度为0），则返回true。

参数：

- self对其进行操作的切片。

如果切片为空，则返回True，否则返回False。

### 比较（切片自身，切片其他）内部返回值（整数）

如果按`other`字典顺序在后面`self`，则返回一个正数；如果在字典之前，则返回一个负数；如果两个切片的内容相等，则返回零。比较是在unicode代码点上按符文进行的。

参数：

- 自我比较的第一个切片。
- 其他要比较的第二片。

返回值比较的结果。

### 等于（切片自身，切片其他）内部收益（布尔）

如果两个切片包含相同的文本，则返回true。

参数：

- 自我比较的第一个切片。
- self要比较的第二个片段。

如果切片相等，则返回True，否则返回false。

### nextRune（切片自身，切片符文）内部返回（切片）

将切片中的第一个符文提取到其中`rune`，前进切片以指向下一个符文并返回`self`。

参数：

- self对其进行操作的切片。
- 符文将包含第一个符文的切片。

返回`rune`。

### nextRune（slice self）内部返回（slice ret）

返回切片中的第一个符文，使切片前进以指向下一个符文。

参数：

- self对其进行操作的切片。

返回一个切片，该切片仅包含中的第一个符文`self`。

### ord（切片自身）内部返回（uint ret）

返回切片中第一个代码点的编号。

参数：

- self对其进行操作的切片。

返回值片中第一个代码点的编号。

### keccak（切片自身）内部返回（bytes32 ret）

返回切片的keccak-256哈希值。

参数：

- self要散列的切片。

返回值切片的哈希。

### startsWith（切片自我，切片针）内部返回（布尔）

如果`self`以开头，则返回true `needle`。

参数：

- self对其进行操作的切片。
- 针要搜索的切片。

如果切片以提供的文本开头，则返回True，否则返回false。

### 超出（切片自身，切片针）内部返回（切片）

如果`self`以开头`needle`，`needle`则从的开头删除`self`。否则，`self`未修改。

参数：

- self对其进行操作的切片。
- 针要搜索的切片。

退货 `self`

### endsWith（切片自身，切片针）内部返回（布尔）

如果切片以结尾，则返回true `needle`。

参数：

- self对其进行操作的切片。
- 针要搜索的切片。

如果切片以提供的文本开头，则返回True，否则返回false。

### 直到（切片自身，切片针）内部返回（切片）

如果`self`以结尾`needle`，`needle`则从中删除`self`。否则，`self`未修改。

参数：

- self对其进行操作的切片。
- 针要搜索的切片。

退货 `self`

### 查找（切片自身，切片针）内部返回（切片）

修改`self`以包含从第一次出现`needle`到切片末尾的所有内容。`self`如果`needle`找不到，则将其设置为空片。

参数：

- self要搜索和修改的切片。
- 针要搜索的文本。

返回`self`。

### rfind（切片自身，切片针）内部返回（切片）

修改`self`以包含从开始`self`到的字符串的一部分`needle`。如果`needle`未找到，`self`则设置为空切片。

参数：

- self要搜索和修改的切片。
- 针要搜索的文本。

返回`self`。

### 分割（切片自身，切片针，切片令牌）内部返回（切片）

分割切片，将其设置`self`为第一次出现之后的所有内容`needle`，以及`token`之前的所有内容。如果`needle`未在中出现`self`，`self`则设置为空切片，并`token`设置为的整体`self`。

参数：

- 自我切片。
- 针在中搜索的文本`self`。
- 令牌一个写入第一个令牌的输出参数。

返回`token`。

### 分割（切片自身，切片针）内部返回（切片令牌）

分割切片，将设置`self`为第一次出现`needle`后的所有内容，并返回它之前的所有内容。如果`needle`未在中发生`self`，`self`则将其设置为空片，并`self`返回的全部。

参数：

- 自我切片。
- 针在中搜索的文本`self`。

返回值`self`直到第一次出现的的部分`delim`。

### rsplit（切片自身，切片针，切片令牌）内部返回（切片）

分割切片，设置`self`为最后一次出现之前的所有内容`needle`，以及`token`之后的所有内容。如果`needle`未在中出现`self`，`self`则设置为空切片，并`token`设置为的整体`self`。

参数：

- 自我切片。
- 针在中搜索的文本`self`。
- 令牌一个写入第一个令牌的输出参数。

返回`token`。

### rsplit（切片自身，切片针）内部返回（切片令牌）

分割切片，将其设置`self`为最后一次出现之前的所有内容`needle`，然后返回其之后的所有内容。如果`needle`未在中发生`self`，`self`则将其设置为空片，并`self`返回的全部。

参数：

- 自我切片。
- 针在中搜索的文本`self`。

返回`self`最后一次出现时的的部分`delim`。

### 计数（切片自身，切片针）内部返回（单位计数）

计算`needle`in 中不重叠出现的次数`self`。

参数：

- self要搜索的切片。
- 针在中搜索的文本`self`。

返回值在中`needle`发现的次数`self`。

### 包含（切片自身，切片针）内部返回（布尔）

如果`self`包含，则返回True `needle`。

参数：

- self要搜索的切片。
- 针在中搜索的文本`self`。

如果`needle`在中找到`self`，则返回True ，否则返回false。

### concat（切片自身，切片其他）内部返回值（字符串）

返回包含的串联一个新分配的字符串`self`和`other`。

参数：

- self要连接的第一个切片。
- 其他要连接的第二个切片。

返回值两个字符串的串联。

### join（切片自身，slice []部分）内部返回（字符串）

连接切片的数组，`self`用作分隔符，返回新分配的字符串。

参数：

- self要使用的分隔符。
- 零件要加入的切片列表。

返回一个新分配的字符串，其中包含所有切片`parts`，并与相连`self`。