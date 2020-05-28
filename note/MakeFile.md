# 概述

- ***makefile关系到了整个工程的编译规则。***

- ***makefile定义了一系列的规则来指定，哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译，甚至于进行更复杂的功能操作，因为makefile就像一个Shell脚本一样，其中也可以执行操作系统的命令。***

- ***在此，我想多说关于程序编译的一些规范和方法。一般来说，无论是C还是C++，首先要把源文件编译成中间代码文件，在Windows下也就是 `.obj` 文件，UNIX下是 `.o` 文件，即Object File，这个动作叫做编译（compile）。然后再把大量的Object File合成执行文件，这个动作叫作链接（link）。***

- 链接时，主要是链接函数和全局变量。所以，我们可以使用这些中间目标文件（ `.o` 文件或 `.obj` 文件）来链接我们的应用程序。链接器并不管函数所在的源文件，只管函数的中间目标文件（Object  File），在大多数时候，由于源文件太多，编译生成的中间目标文件太多，而在链接时需要明显地指出中间目标文件名，这对于编译很不方便。所以，我们要给中间目标文件打个包，在Windows下这种包叫“库文件”（Library File），也就是 `.lib` 文件，在UNIX下，是Archive File，也就是 `.a` 文件。

## makefile介绍

### makefile规则

```makefile
target ... : prerequisites ...
    command
    ...
    ...
#prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。
```

- ，如果讨论范围在Unix和Linux之间，那么cc和gcc不是同一个东西。cc来自于Unix的c语言编译器，是 c compiler  的缩写。gcc来自Linux世界，是GNU compiler collection 的缩写，注意这是一个编译器集合，不仅仅是c或c++。

- 果讨论范围仅限于Linux，我们可以认为它们是一样的，在Linux下调用cc时，其实际上并不指向unix的cc编译器，而是指向了gcc，也就是说cc是gcc的一个链接（快捷方式）

  ![cc](https://media.githubusercontent.com/media/CONG2019/Images/master/makefile/Screenshot from 2020-05-28 12-48-39.jpg "linux上用gcc代替cc")

### make是如何工作的

1.  make会在当前目录下找名字叫“Makefile”或“makefile”的文件。
2.  如果找到，它会找文件中的第一个目标文件（target），在上面的例子中，他会找到“edit”这个文件，并把这个文件作为最终的目标文件。
3.  如果edit文件不存在，或是edit所依赖的后面的 `.o` 文件的文件修改时间要比 `edit` 这个文件新，那么，他就会执行后面所定义的命令来生成 `edit` 这个文件。
4.  如果 `edit` 所依赖的 `.o` 文件也不存在，那么make会在当前文件中找目标为 `.o` 文件的依赖性，如果找到则再根据那一个规则生成 `.o` 文件。（这有点像一个堆栈的过程）
5.  当然，你的C文件和H文件是存在的啦，于是make会生成 `.o` 文件，然后再用 `.o` 文件生成make的终极任务，也就是执行文件 `edit` 了。
6. 