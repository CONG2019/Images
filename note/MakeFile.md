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

### makefile中使用变量

***makefile的变量也就是一个字符串，理解成C语言中的宏可能会更好。***

我们在makefile一开始就这样定义：

```makefile
objects = main.o kbd.o command.o display.o \
     insert.o search.o files.o utils.o
#于是，我们就可以很方便地在我们的makefile中以 $(objects) 的方式来使用这个变量了
edit : $(objects)
    cc -o edit $(objects)
```

### 让make自动推导

只要make看到一个 `.o` 文件，它就会自动的把 `.c` 文件加在依赖关系中，如果make找到一个 `whatever.o` ，那么 `whatever.c` 就会是 `whatever.o` 的依赖文件。并且 `cc -c whatever.c` 也会被推导出来，于是，我们的makefile再也不用写得这么复杂。我们的新makefile又出炉了。

```makefile
objects = main.o kbd.o command.o display.o \
    insert.o search.o files.o utils.o

edit : $(objects)
    cc -o edit $(objects)

main.o : defs.h
kbd.o : defs.h command.h
command.o : defs.h command.h
display.o : defs.h buffer.h
insert.o : defs.h buffer.h
search.o : defs.h buffer.h
files.o : defs.h buffer.h command.h
utils.o : defs.h

.PHONY : clean
clean :
    rm edit $(objects)
```

### makefile包含什么？

Makefile里主要包含了五个东西：显式规则、隐晦规则、变量定义、文件指示和注释。

1. 显式规则。显式规则说明了如何生成一个或多个目标文件。这是由Makefile的书写者明显指出要生成的文件、文件的依赖文件和生成的命令。
2. 隐晦规则。由于我们的make有自动推导的功能，所以隐晦的规则可以让我们比较简略地书写 Makefile，这是由make所支持的。
3. 变量的定义。在Makefile中我们要定义一系列的变量，变量一般都是字符串，这个有点像你C语言中的宏，当Makefile被执行时，其中的变量都会被扩展到相应的引用位置上。
4. 文件指示。其包括了三个部分，一个是在一个Makefile中引用另一个Makefile，就像C语言中的include一样；另一个是指根据某些情况指定Makefile中的有效部分，就像C语言中的预编译#if一样；还有就是定义一个多行的命令。有关这一部分的内容，我会在后续的部分中讲述。
5. 注释。Makefile中只有行注释，和UNIX的Shell脚本一样，其注释是用 `#` 字符，这个就像C/C++中的 `//` 一样。如果你要在你的Makefile中使用 `#` 字符，可以用反斜杠进行转义，如： `\#`  。
6. **最后，还值得一提的是，在Makefile中的命令，必须要以 `Tab` 键开始。**

### 引用其它的Makefile

在Makefile使用 `include` 关键字可以把别的Makefile包含进来，这很像C语言的 `#include` ，被包含的文件会原模原样的放在当前文件的包含位置。 `include` 的语法是：

```makefile
include <filename>

include foo.make *.mk $(bar)
include foo.make a.mk b.mk c.mk e.mk f.mk
```

如果你想让make不理那些无法读取的文件，而继续执行，你可以在include前加一个减号“-”。如：

```makefile
-include <filename>
```

### make的工作方式

GNU的make工作时的执行步骤如下：

1.  读入所有的Makefile。
2.  读入被include的其它Makefile。
3.  初始化文件中的变量。
4.  推导隐晦规则，并分析所有规则。
5.  为所有的目标文件创建依赖关系链。
6.  根据依赖关系，决定哪些目标要重新生成。
7.  执行生成命令。

# 书写规则

***一般来说，定义在Makefile中的目标可能会有很多，但是第一条规则中的目标将被确立为最终的目标。如果第一条规则中的目标有很多个，那么，第一个目标会成为最终的目标。***

```makefile
foo.o: foo.c defs.h       # foo模块
    cc -c -g foo.c
    
targets : prerequisites
    command
    ...
#如果命令太长，你可以使用反斜杠（ \ ）作为换行符。
```

1.  文件的依赖关系， `foo.o` 依赖于 `foo.c` 和 `defs.h` 的文件，如果 `foo.c` 和 `defs.h` 的文件日期要比 `foo.o` 文件日期要新，或是 `foo.o` 不存在，那么依赖关系发生。
2.  生成或更新 `foo.o` 文件，就是那个cc命令。它说明了如何生成 `foo.o` 这个文件。（当然，foo.c文件include了defs.h文件）

## 在规则中使用通配符

***make支持三个通配符： `*` ， `?` 和 `~` 。***

1. 列出一确定文件夹中的所有 `.c` 文件。

   ```makefile
   objects := $(wildcard *.c)
   ```

2. 列出(1)中所有文件对应的 `.o` 文件，在（3）中我们可以看到它是由make自动编译出的:

   ```makefile
   $(patsubst %.c,%.o,$(wildcard *.c))
   ```

3. 由(1)(2)两步，可写出编译并链接所有 `.c` 和 `.o` 文件

   ```makefile
   objects := $(patsubst %.c,%.o,$(wildcard *.c))
   foo : $(objects)
       cc -o foo $(objects)
   ```

## 文件搜寻

***Makefile文件中的特殊变量 `VPATH` 就是完成这个功能的，如果没有指明这个变量，make只会在当前的目录中去找寻依赖文件和目标文件。如果定义了这个变量，那么，make就会在当前目录找不到的情况下，到所指定的目录中去找寻文件了。***

```makefile
VPATH = src:../headers
#上面的定义指定两个目录，“src”和“../headers”，make会按照这个顺序进行搜索。目录由“冒号”分隔。
```

另一个设置文件搜索路径的方法是使用make的“vpath”关键字（注意，它是全小写的），这不是变量，这是一个make的关键字，这和上面提到的那个VPATH变量很类似，但是它更为灵活。它可以指定不同的文件在不同的搜索目录中。这是一个很灵活的功能。

- `vpath <pattern> <directories>`

  为符合模式<pattern>的文件指定搜索目录<directories>。

- `vpath <pattern>`

  清除符合模式<pattern>的文件的搜索目录。

- `vpath`

  清除所有已被设置好了的文件搜索目录。

vapth使用方法中的<pattern>需要包含 `%` 字符。 `%` 的意思是匹配零或若干字符，（需引用 `%` ，使用 `\` ）例如， `%.h` 表示所有以 `.h` 结尾的文件。<pattern>指定了要搜索的文件集，而<directories>则指定了< pattern>的文件集的搜索的目录。例如：

```makefile
vpath %.h ../headers
```

我们可以连续地使用vpath语句，以指定不同搜索策略。如果连续的vpath语句中出现了相同的<pattern> ，或是被重复了的<pattern>，那么，make会按照vpath语句的先后顺序来执行搜索。如：

```
vpath %.c foo
vpath %   blish
vpath %.c bar
```

## 伪目标

当然，为了避免和文件重名的这种情况，我们可以使用一个特殊的标记“.PHONY”来显式地指明一个目标是“伪目标”，向make说明，不管是否有这个文件，这个目标就是“伪目标”。

```makefile
.PHONY : clean
```

只要有这个声明，不管是否有“clean”文件，要运行“clean”这个目标，只有“make clean”这样。于是整个过程可以这样写：

```
.PHONY : clean
clean :
    rm *.o temp
```

伪目标一般没有依赖的文件。但是，我们也可以为伪目标指定所依赖的文件。伪目标同样可以作为“默认目标”，只要将其放在第一个。一个示例就是，如果你的Makefile需要一口气生成若干个可执行文件，但你只想简单地敲一个make完事，并且，所有的目标文件都写在一个Makefile中，那么你可以使用“伪目标”这个特性：

```makefile
all : prog1 prog2 prog3
.PHONY : all

prog1 : prog1.o utils.o
    cc -o prog1 prog1.o utils.o

prog2 : prog2.o
    cc -o prog2 prog2.o

prog3 : prog3.o sort.o utils.o
    cc -o prog3 prog3.o sort.o utils.o
```

伪目标同样也可成为依赖。看下面的例子：

```makefile
.PHONY : cleanall cleanobj cleandiff

cleanall : cleanobj cleandiff
    rm program

cleanobj :
    rm *.o

cleandiff :
    rm *.diff
```

## 静态模式

静态模式可以更加容易地定义多目标的规则，可以让我们的规则变得更加的有弹性和灵活。我们还是先来看一下语法：

```makefile
<targets ...> : <target-pattern> : <prereq-patterns ...>
    <commands>
    ...
```

- targets定义了一系列的目标文件，可以有通配符。是目标的一个集合。

- target-pattern是指明了targets的模式，也就是的目标集模式。

- prereq-patterns是目标的依赖模式，它对target-pattern形成的模式再进行一次依赖目标的定义。

```makefile
objects = foo.o bar.o

all: $(objects)

$(objects): %.o: %.c
    $(CC) -c $(CFLAGS) $< -o $@
```

上面的例子中，指明了我们的目标从$object中获取， `%.o` 表明要所有以 `.o` 结尾的目标，也就是 `foo.o bar.o` ，也就是变量 `$object` 集合的模式，而依赖模式 `%.c` 则取模式 `%.o` 的 `%` ，也就是 `foo bar` ，并为其加下 `.c` 的后缀，于是，我们的依赖目标就是 `foo.c bar.c` 。而命令中的 `$<` 和 `$@` 则是自动化变量， `$<` 表示第一个依赖文件， `$@` 表示目标集（也就是“foo.o bar.o”）。于是，上面的规则展开后等价于下面的规则：

```makefile
foo.o : foo.c
    $(CC) -c $(CFLAGS) foo.c -o foo.o
bar.o : bar.c
    $(CC) -c $(CFLAGS) bar.c -o bar.o
```

```makefile
iles = foo.elc bar.o lose.o

$(filter %.o,$(files)): %.o: %.c
    $(CC) -c $(CFLAGS) $< -o $@
$(filter %.elc,$(files)): %.elc: %.el
    emacs -f batch-byte-compile $<
```

**$(filter %.o,$(files))表示调用Makefile的filter函数，过滤“$files”集，只要其中模式为“%.o”的内容。其它的内容，我就不用多说了吧。**

## 自动生成依赖性

大多数的C/C++编译器都支持一个“-M”的选项，即自动找寻源文件中包含的头文件，并生成一个依赖关系。例如，如果我们执行下面的命令:

```makefile
cc -M main.c
```

其输出是：

```makefile
main.o : main.c defs.h
```

***需要提醒一句的是，如果你使用GNU的C/C++编译器，你得用 `-MM` 参数，不然， `-M` 参数会把一些标准库的头文件也包含进来。***

GNU组织建议把编译器为每一个源文件的自动生成的依赖关系放到一个文件中，为每一个 `name.c` 的文件都生成一个 `name.d` 的Makefile文件， `.d` 文件中就存放对应 `.c` 文件的依赖关系。

于是，我们可以写出 `.c` 文件和 `.d` 文件的依赖关系，并让make自动更新或生成 `.d` 文件，并把其包含在我们的主Makefile中，这样，我们就可以自动化地生成每个文件的依赖关系了。

这里，我们给出了一个模式规则来产生 `.d` 文件：

```makefile
%.d: %.c
    @set -e; rm -f $@; \
    $(CC) -M $(CPPFLAGS) $< > $@.$$$$; \
    sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
    rm -f $@.$$$$
```

这个规则的意思是，所有的 `.d` 文件依赖于 `.c` 文件， `rm -f $@` 的意思是删除所有的目标，也就是 `.d` 文件，第二行的意思是，为每个依赖文件 `$<` ，也就是 `.c` 文件生成依赖文件， `$@` 表示模式 `%.d` 文件，如果有一个C文件是name.c，那么 `%` 就是 `name` ， `$$$$` 意为一个随机编号，第二行生成的文件有可能是“name.d.12345”，第三行使用sed命令做了一个替换，关于sed命令的用法请参看相关的使用文档。第四行就是删除临时文件。

，接下来，我们就要把这些自动生成的规则放进我们的主Makefile中。我们可以使用Makefile的“include”命令，来引入别的Makefile文件（前面讲过），例如：

```makefile
sources = foo.c bar.c

include $(sources:.c=.d)
```

上述语句中的 `$(sources:.c=.d)` 中的 `.c=.d` 的意思是做一个替换，把变量 `$(sources)` 所有 `.c` 的字串都替换成 `.d` ，关于这个“替换”的内容，在后面我会有更为详细的讲述。当然，你得注意次序，因为include是按次序来载入文件，最先载入的 `.d` 文件中的目标会成为默认目标。

# 书写命令

## 显示命令

通常，make会把其要执行的命令行在命令执行前输出到屏幕上。当我们用 `@` 字符在命令行前，那么，这个命令将不被make显示出来，最具代表性的例子是，我们用这个功能来向屏幕显示一些信息。如:

```makefile
@echo 正在编译XXX模块......
```

- ***如果make执行时，带入make参数 `-n` 或 `--just-print` ，那么其只是显示命令，但不会执行命令，这个功能很有利于我们调试我们的Makefile，看看我们书写的命令是执行起来是什么样子的或是什么顺序的。***
- 而make参数 `-s` 或 `--silent` 或 `--quiet` 则是全面禁止命令的显示。

## 命令执行

比如你的第一条命令是cd命令，你希望第二条命令得在cd之后的基础上运行，那么你就不能把这两条命令写在两行上，而应该把这两条命令写在一行上，用分号分隔。

```makefile
exec:
    cd /home/hchen; pwd
```

## 命令出错

忽略命令的出错，我们可以在Makefile的命令行前加一个减号 `-` （在Tab键之后），标记为不管命令出不出错都认为是成功的。如：

```makefile
clean:
    -rm -f *.o
```

- ***还有一个全局的办法是，给make加上 `-i` 或是 `--ignore-errors` 参数，那么，Makefile中所有命令都会忽略错误。***
- ***而如果一个规则是以 `.IGNORE` 作为目标的，那么这个规则中的所有命令将会忽略错误。***

## 嵌套执行make

我们有一个子目录叫subdir，这个目录下有个Makefile文件，来指明了这个目录下文件的编译规则。那么我们总控的Makefile可以这样书写：

```makefile
subsystem:
    cd subdir && $(MAKE)
```

其等价于：

```makefile
subsystem:
    $(MAKE) -C subdir
```

- 定义$(MAKE)宏变量的意思是，也许我们的make需要一些参数，所以定义成一个变量比较利于维护。这两个例子的意思都是先进入“subdir”目录，然后执行make命令。

- 我们把这个Makefile叫做“总控Makefile”，总控Makefile的变量可以传递到下级的Makefile中（如果你显示的声明），但是不会覆盖下层的Makefile中所定义的变量，除非指定了 `-e` 参数。

如果你要传递变量到下级Makefile中，那么你可以使用这样的声明:

```makefile
export <variable ...>;
```

如果你不想让某些变量传递到下级Makefile中，那么你可以这样声明:

```makefile
unexport <variable ...>;
```

- **如果你要传递所有的变量，那么，只要一个export就行了。后面什么也不用跟，表示传递所有的变量。**

## 定义命令包

如果Makefile中出现一些相同命令序列，那么我们可以为这些相同的命令序列定义一个变量。定义这种命令序列的语法以 `define` 开始，以 `endef` 结束，如:

```makefile
define run-yacc
yacc $(firstword $^)
mv y.tab.c $@
endef
```

- 这里，“run-yacc”是这个命令包的名字，其不要和Makefile中的变量重名。

```makefile
foo.c : foo.y
    $(run-yacc)
```

我们可以看见，要使用这个命令包，我们就好像使用变量一样。在这个命令包的使用中，命令包“run-yacc”中的 `$^` 就是 `foo.y` ，  `$@` 就是 `foo.c` 

# 使用变量

***变量的命名字可以包含字符、数字，下划线（可以是数字开头），但不应该含有 `:` 、 `#` 、 `=`  或是空字符（空格、回车等）。变量是大小写敏感的，“foo”、“Foo”和“FOO”是三个不同的变量名。传统的Makefile的变量名是全大写的命名方式，但我推荐使用大小写搭配的变量名，如：MakeFlags。这样可以避免和系统的变量冲突，而发生意外的事情。***

## 变量的基础

**变量在声明时需要给予初值，而在使用时，需要给在变量名前加上 `$` 符号，但最好用小括号 `()` 或是大括号 `{}` 把变量给包括起来。如果你要使用真实的 `$` 字符，那么你需要用 `$$` 来表示。**

## 变量中的变量

```makefile
foo = $(bar)
bar = $(ugh)
ugh = Huh?

all:
    echo $(foo)
```

```makefile
ifeq (0,${MAKELEVEL})
cur-dir   := $(shell pwd)
whoami    := $(shell whoami)
host-type := $(shell arch)
MAKE := ${MAKE} host-type=${host-type} whoami=${whoami}
endif
```

关于条件表达式和函数，我们在后面再说，对于系统变量“MAKELEVEL”，其意思是，如果我们的make有一个嵌套执行的动作（参见前面的“嵌套使用make”），那么，这个变量会记录了我们的当前Makefile的调用层数。

有一个比较有用的操作符是 `?=` ，先看示例：

```
FOO ?= bar
```

其含义是，如果FOO没有被定义过，那么变量FOO的值就是“bar”，如果FOO先前被定义过，那么这条语将什么也不做，其等价于：

```makefile
ifeq ($(origin FOO), undefined)
    FOO = bar
endif
```

## 变量高级用法

- 我们可以替换变量中的共有的部分，其格式是 `$(var:a=b)` 或是 `${var:a=b}` ，其意思是，把变量“var”中所有以“a”字串“结尾”的“a”替换成“b”字串。这里的“结尾”意思是“空格”或是“结束符”。

```makefile
foo := a.o b.o c.o
bar := $(foo:.o=.c)
```

- 第二种高级用法是——“把变量的值再当成变量”。先看一个例子：

  ```makefile
  x = y
  y = z
  a := $($(x))
  ```

## 追加变量值

我们可以使用 `+=` 操作符给变量追加值，如：

```makefile
objects = main.o foo.o bar.o utils.o
objects += another.o
```

## override 指示符

如果有变量是通常make的命令行参数设置的，那么Makefile中对这个变量的赋值会被忽略。如果你想在Makefile中设置这类参数的值，那么，你可以使用“override”指示符。其语法是:

```makefile
override <variable>; = <value>;

override <variable>; := <value>;
```

当然，你还可以追加:

```makefile
override <variable>; += <more text>;
```

对于多行的变量定义，我们用define指示符，在define指示符前，也同样可以使用override指示符，如:

```makefile
override define foo
bar
endef
```

## 多行变量

define指示符后面跟的是变量的名字，而重起一行定义变量的值，定义是以endef 关键字结束。其工作方式和“=”操作符一样。变量的值可以包含函数、命令、文字，或是其它变量。因为命令需要以[Tab]键开头，所以如果你用define定义的命令变量中没有以 `Tab` 键开头，那么make 就不会把其认为是命令。

```makefile
define two-lines
echo foo
echo $(bar)
endef
```

## 环境变量

make运行时的系统环境变量可以在make开始运行时被载入到Makefile文件中，但是如果Makefile中已定义了这个变量，或是这个变量由make命令行带入，那么系统的环境变量的值将被覆盖。（如果make指定了“-e”参数，那么，系统环境变量将覆盖Makefile中定义的变量）

因此，如果我们在环境变量中设置了 `CFLAGS`  环境变量，那么我们就可以在所有的Makefile中使用这个变量了。这对于我们使用统一的编译参数有比较大的好处。如果Makefile中定义了CFLAGS，那么则会使用Makefile中的这个变量，如果没有定义则使用系统环境变量的值，一个共性和个性的统一，很像“全局变量”和“局部变量”的特性。

当make嵌套调用时（参见前面的“嵌套调用”章节），上层Makefile中定义的变量会以系统环境变量的方式传递到下层的Makefile  中。当然，默认情况下，只有通过命令行设置的变量会被传递。而定义在文件中的变量，如果要向下层Makefile传递，则需要使用exprot关键字来声明。（参见前面章节）

## 目标变量

**我也同样可以为某个目标设置局部变量，这种变量被称为“Target-specific Variable”，它可以和“全局变量”同名，因为它的作用范围只在这条规则以及连带规则中，所以其值也只在作用范围内有效。而不会影响规则链以外的全局变量的值。**

其语法是：

```makefile
<target ...> : <variable-assignment>;

<target ...> : overide <variable-assignment>

prog : CFLAGS = -g
prog : prog.o foo.o bar.o
    $(CC) $(CFLAGS) prog.o foo.o bar.o

prog.o : prog.c
    $(CC) $(CFLAGS) prog.c

foo.o : foo.c
    $(CC) $(CFLAGS) foo.c

bar.o : bar.c
    $(CC) $(CFLAGS) bar.c
    
#在这个示例中，不管全局的 $(CFLAGS) 的值是什么，在prog目标，以及其所引发的所有规则中（prog.o foo.o bar.o的规则）， $(CFLAGS) 的值都是 -g
```

## 模式变量

**在GNU的make中，还支持模式变量（Pattern-specific Variable），通过上面的目标变量中，我们知道，变量可以定义在某个目标上。模式变量的好处就是，我们可以给定一种“模式”，可以把变量定义在符合这种模式的所有目标上。**

我们知道，make的“模式”一般是至少含有一个 `%` 的，所以，我们可以以如下方式给所有以 `.o` 结尾的目标定义目标变量：

```makefile
%.o : CFLAGS = -O
```

同样，模式变量的语法和“目标变量”一样：

```makefile
<pattern ...>; : <variable-assignment>;

<pattern ...>; : override <variable-assignment>;
```

# 使用条件判断

下面的例子，判断 `$(CC)` 变量是否 `gcc` ，如果是的话，则使用GNU函数编译目标。

```makefile
libs_for_gcc = -lgnu
normal_libs =

foo: $(objects)
ifeq ($(CC),gcc)
    $(CC) -o foo $(objects) $(libs_for_gcc)
else
    $(CC) -o foo $(objects) $(normal_libs)
endif
```

## 语法

条件表达式的语法为:

```makefile
<conditional-directive>
<text-if-true>
endif
```

以及:

```makefile
<conditional-directive>
<text-if-true>
else
<text-if-false>
endif
```

其中 `<conditional-directive>` 表示条件关键字，如 `ifeq` 。这个关键字有四个。

- 第一个是我们前面所见过的 `ifeq`

```makefile
ifeq (<arg1>, <arg2>)
ifeq '<arg1>' '<arg2>'
ifeq "<arg1>" "<arg2>"
ifeq "<arg1>" '<arg2>'
ifeq '<arg1>' "<arg2>"
```

- 第二个条件关键字是 `ifneq` 。语法是：

```makefile
ifneq (<arg1>, <arg2>)
ifneq '<arg1>' '<arg2>'
ifneq "<arg1>" "<arg2>"
ifneq "<arg1>" '<arg2>'
ifneq '<arg1>' "<arg2>"
```

- 第三个条件关键字是 `ifdef` 。语法是：

```makefile
ifdef <variable-name>
#注意， ifdef 只是测试一个变量是否有值，其并不会把变量扩展到当前位置。
```

- 第四个条件关键字是 `ifndef` 。其语法是：

```
ifndef <variable-name>
```

***特别注意的是，make是在读取Makefile时就计算条件表达式的值，并根据条件表达式的值来选择语句，所以，你最好不要把自动化变量（如 `$@` 等）放入条件表达式中，因为自动化变量是在运行时才有的。***

# 使用函数

**函数调用后，函数的返回值可以当做变量来使用。**

## 函数的调用语法

函数调用，很像变量的使用，也是以 `$` 来标识的，其语法如下：

```makefile
$(<function> <arguments>)
```

或是:

```makefile
${<function> <arguments>}
```

**`<function>` 就是函数名，make支持的函数不多。 `<arguments>` 为函数的参数，参数间以逗号 `,` 分隔，而函数名和参数之间以“空格”分隔。函数调用以 `$` 开头，以圆括号或花括号把函数名和参数括起。**

还是来看一个示例：

```makefile
comma:= ,
empty:=
space:= $(empty) $(empty)
foo:= a b c
bar:= $(subst $(space),$(comma),$(foo))
```

在这个示例中， `$(comma)` 的值是一个逗号。 `$(space)` 使用了 `$(empty)` 定义了一个空格， `$(foo)` 的值是 `a b c` ， `$(bar)` 的定义用，调用了函数 `subst` ，这是一个替换函数，这个函数有三个参数，第一个参数是被替换字串，第二个参数是替换字串，第三个参数是替换操作作用的字串。这个函数也就是把 `$(foo)` 中的空格替换成逗号，所以 `$(bar)` 的值是 `a,b,c` 。

## 字符串处理函数

### subst

```makefile
$(subst <from>,<to>,<text>)
```

- 名称：字符串替换函数
- 功能：把字串 `<text>` 中的 `<from>` 字符串替换成 `<to>` 。
- 返回：函数返回被替换过后的字符串。

### patsubst

```makefile
$(patsubst <pattern>,<replacement>,<text>)
```

- 名称：模式字符串替换函数。
- 功能：查找 `<text>` 中的单词（单词以“空格”、“Tab”或“回车”“换行”分隔）是否符合模式 `<pattern>` ，如果匹配的话，则以 `<replacement>` 替换。这里， `<pattern>` 可以包括通配符 `%` ，表示任意长度的字串。如果 `<replacement>` 中也包含 `%` ，那么， `<replacement>` 中的这个 `%` 将是 `<pattern>` 中的那个 `%` 所代表的字串。（可以用 `\` 来转义，以 `\%` 来表示真实含义的 `%` 字符）
- 返回：函数返回被替换过后的字符串。

### strip

```makefile
$(strip <string>)
```

- 名称：去空格函数。
- 功能：去掉 `<string>` 字串中开头和结尾的空字符。
- 返回：返回被去掉空格的字符串值。

### findstring

```makefile
$(findstring <find>,<in>)
```

- 名称：查找字符串函数
- 功能：在字串 `<in>` 中查找 `<find>` 字串。
- 返回：如果找到，那么返回 `<find>` ，否则返回空字符串。

### filter

```makefile
$(filter <pattern...>,<text>)
```

- 名称：过滤函数
- 功能：以 `<pattern>` 模式过滤 `<text>` 字符串中的单词，保留符合模式 `<pattern>` 的单词。可以有多个模式。
- 返回：返回符合模式 `<pattern>` 的字串。

示例：

> ```makefile
> sources := foo.c bar.c baz.s ugh.h
> foo: $(sources)
>     cc $(filter %.c %.s,$(sources)) -o foo
> #$(filter %.c %.s,$(sources)) 返回的值是 foo.c bar.c baz.s 。
> ```

### filter-out

```makefile
$(filter-out <pattern...>,<text>)
```

- 名称：反过滤函数
- 功能：以 `<pattern>` 模式过滤 `<text>` 字符串中的单词，去除符合模式 `<pattern>` 的单词。可以有多个模式。
- 返回：返回不符合模式 `<pattern>` 的字串。

### sort

```makefile
$(sort <list>)
```

- 名称：排序函数
- 功能：给字符串 `<list>` 中的单词排序（升序）。
- 返回：返回排序后的字符串。
- 示例： `$(sort foo bar lose)` 返回 `bar foo lose` 。
- 备注： `sort` 函数会去掉 `<list>` 中相同的单词。

### word

```makefile
$(word <n>,<text>)
```

- 名称：取单词函数
- 功能：取字符串 `<text>` 中第 `<n>` 个单词。（从一开始）
- 返回：返回字符串 `<text>` 中第 `<n>` 个单词。如果 `<n>` 比 `<text>` 中的单词数要大，那么返回空字符串。
- 示例： `$(word 2, foo bar baz)` 返回值是 `bar` 。

### wordlist

```makefile
$(wordlist <ss>,<e>,<text>)
```

- 名称：取单词串函数
- 功能：从字符串 `<text>` 中取从 `<ss>` 开始到 `<e>` 的单词串。 `<ss>` 和 `<e>` 是一个数字。
- 返回：返回字符串 `<text>` 中从 `<ss>` 到 `<e>` 的单词字串。如果 `<ss>` 比 `<text>` 中的单词数要大，那么返回空字符串。如果 `<e>` 大于 `<text>` 的单词数，那么返回从 `<ss>` 开始，到 `<text>` 结束的单词串。
- 示例： `$(wordlist 2, 3, foo bar baz)` 返回值是 `bar baz` 。

### words

```makefile
$(words <text>)
```

- 名称：单词个数统计函数
- 功能：统计 `<text>` 中字符串中的单词个数。
- 返回：返回 `<text>` 中的单词数。
- 示例： `$(words, foo bar baz)` 返回值是 `3` 。
- 备注：如果我们要取 `<text>` 中最后的一个单词，我们可以这样： `$(word $(words <text>),<text>)` 。

### firstword

```makefile
$(firstword <text>)
```

- 名称：首单词函数——firstword。
- 功能：取字符串 `<text>` 中的第一个单词。
- 返回：返回字符串 `<text>` 的第一个单词。
- 示例： `$(firstword foo bar)` 返回值是 `foo`。
- 备注：这个函数可以用 `word` 函数来实现： `$(word 1,<text>)` 。

**实用例子**

```makefile
override CFLAGS += $(patsubst %,-I%,$(subst :, ,$(VPATH)))
```

如果我们的 `$(VPATH)` 值是 `src:../headers` ，那么 `$(patsubst %,-I%,$(subst :, ,$(VPATH)))` 将返回 `-Isrc -I../headers` ，这正是cc或gcc搜索头文件路径的参数。

## 文件名操作函数

### dir

```makefile
$(dir <names...>)
```

- 名称：取目录函数——dir。
- 功能：从文件名序列 `<names>` 中取出目录部分。目录部分是指最后一个反斜杠（ `/` ）之前的部分。如果没有反斜杠，那么返回 `./` 。
- 返回：返回文件名序列 `<names>` 的目录部分。
- 示例： `$(dir src/foo.c hacks)` 返回值是 `src/ ./` 。

### notdir

```makefile
$(notdir <names...>)
```

- 名称：取文件函数——notdir。
- 功能：从文件名序列 `<names>` 中取出非目录部分。非目录部分是指最後一个反斜杠（ `/` ）之后的部分。
- 返回：返回文件名序列 `<names>` 的非目录部分。
- 示例:  `$(notdir src/foo.c hacks)` 返回值是 `foo.c hacks` 。

### suffix

```makefile
$(suffix <names...>)
```

- 名称：取後缀函数——suffix。
- 功能：从文件名序列 `<names>` 中取出各个文件名的后缀。
- 返回：返回文件名序列 `<names>` 的后缀序列，如果文件没有后缀，则返回空字串。
- 示例： `$(suffix src/foo.c src-1.0/bar.c hacks)` 返回值是 `.c .c`。

### basename

```makefile
$(basename <names...>)
```

- 名称：取前缀函数——basename。
- 功能：从文件名序列 `<names>` 中取出各个文件名的前缀部分。
- 返回：返回文件名序列 `<names>` 的前缀序列，如果文件没有前缀，则返回空字串。
- 示例： `$(basename src/foo.c src-1.0/bar.c hacks)` 返回值是 `src/foo src-1.0/bar hacks` 。

### addsuffix

```makefile
$(addsuffix <suffix>,<names...>)
```

- 名称：加后缀函数——addsuffix。
- 功能：把后缀 `<suffix>` 加到 `<names>` 中的每个单词后面。
- 返回：返回加过后缀的文件名序列。
- 示例： `$(addsuffix .c,foo bar)` 返回值是 `foo.c bar.c` 。

### addprefix

```makefile
$(addprefix <prefix>,<names...>)
```

- 名称：加前缀函数——addprefix。
- 功能：把前缀 `<prefix>` 加到 `<names>` 中的每个单词后面。
- 返回：返回加过前缀的文件名序列。
- 示例： `$(addprefix src/,foo bar)` 返回值是 `src/foo src/bar` 。

### join

```makefile
$(join <list1>,<list2>)
```

- 名称：连接函数——join。
- 功能：把 `<list2>` 中的单词对应地加到 `<list1>` 的单词后面。如果 `<list1>` 的单词个数要比 `<list2>` 的多，那么， `<list1>` 中的多出来的单词将保持原样。如果 `<list2>` 的单词个数要比 `<list1>` 多，那么， `<list2>` 多出来的单词将被复制到 `<list1>` 中。
- 返回：返回连接过后的字符串。
- 示例： `$(join aaa bbb , 111 222 333)` 返回值是 `aaa111 bbb222 333` 。

## foreach 函数

```makefile
$(foreach <var>,<list>,<text>)
```

这个函数的意思是，把参数 `<list>` 中的单词逐一取出放到参数 `<var>` 所指定的变量中，然后再执行 `<text>` 所包含的表达式。每一次 `<text>` 会返回一个字符串，循环过程中， `<text>` 的所返回的每个字符串会以空格分隔，最后当整个循环结束时， `<text>` 所返回的每个字符串所组成的整个字符串（以空格分隔）将会是foreach函数的返回值。

所以， `<var>` 最好是一个变量名， `<list>` 可以是一个表达式，而 `<text>` 中一般会使用 `<var>` 这个参数来依次枚举 `<list>` 中的单词。举个例子：

```makefile
names := a b c d

files := $(foreach n,$(names),$(n).o)
```

上面的例子中， `$(name)` 中的单词会被挨个取出，并存到变量 `n` 中， `$(n).o` 每次根据 `$(n)` 计算出一个值，这些值以空格分隔，最后作为foreach函数的返回，所以， `$(files)` 的值是 `a.o b.o c.o d.o` 。

## if 函数

if函数很像GNU的make所支持的条件语句——ifeq（参见前面所述的章节），if函数的语法是：

```makefile
$(if <condition>,<then-part>)
```

或是

```makefile
$(if <condition>,<then-part>,<else-part>)
```

可见，if函数可以包含“else”部分，或是不含。即if函数的参数可以是两个，也可以是三个。 `<condition>` 参数是if的表达式，如果其返回的为非空字符串，那么这个表达式就相当于返回真，于是， `<then-part>` 会被计算，否则 `<else-part>` 会被计算。

## call函数

call函数是唯一一个可以用来创建新的参数化的函数。你可以写一个非常复杂的表达式，这个表达式中，你可以定义许多参数，然后你可以call函数来向这个表达式传递参数。其语法是：

```makefile
$(call <expression>,<parm1>,<parm2>,...,<parmn>)
```

当make执行这个函数时， `<expression>` 参数中的变量，如 `$(1)` 、 `$(2)` 等，会被参数 `<parm1>` 、 `<parm2>` 、 `<parm3>` 依次取代。而 `<expression>` 的返回值就是 call 函数的返回值。例如：

```makefile
reverse =  $(1) $(2)

foo = $(call reverse,a,b)
```

那么， `foo` 的值就是 `a b` 。当然，参数的次序是可以自定义的，不一定是顺序的，如：

```makefile
reverse =  $(2) $(1)

foo = $(call reverse,a,b)
```

此时的 `foo` 的值就是 `b a` 。

## origin函数

origin函数不像其它的函数，他并不操作变量的值，他只是告诉你你的这个变量是哪里来的？其语法是：

```
$(origin <variable>)
```

- 注意， `<variable>` 是变量的名字，不应该是引用。所以你最好不要在 `<variable>` 中使用

  `$` 字符。Origin函数会以其返回值来告诉你这个变量的“出生情况”，下面，是origin函数的返回值:

- `undefined`

  如果 `<variable>` 从来没有定义过，origin函数返回这个值 `undefined`

- `default`

  如果 `<variable>` 是一个默认的定义，比如“CC”这个变量，这种变量我们将在后面讲述。

- `environment`

  如果 `<variable>` 是一个环境变量，并且当Makefile被执行时， `-e` 参数没有被打开。

- `file`

  如果 `<variable>` 这个变量被定义在Makefile中。

- `command line`

  如果 `<variable>` 这个变量是被命令行定义的。

- `override`

  如果 `<variable>` 是被override指示符重新定义的。

- `automatic`

  如果 `<variable>` 是一个命令运行中的自动化变量。关于自动化变量将在后面讲述。

这些信息对于我们编写Makefile是非常有用的，例如，假设我们有一个Makefile其包了一个定义文件 Make.def，在  Make.def中定义了一个变量“bletch”，而我们的环境中也有一个环境变量“bletch”，此时，我们想判断一下，如果变量来源于环境，那么我们就把之重定义了，如果来源于Make.def或是命令行等非环境的，那么我们就不重新定义它。于是，在我们的Makefile中，我们可以这样写：

```makefile
ifdef bletch
    ifeq "$(origin bletch)" "environment"
        bletch = barf, gag, etc.
    endif
endif
```

当然，你也许会说，使用 `override` 关键字不就可以重新定义环境中的变量了吗？为什么需要使用这样的步骤？是的，我们用 `override` 是可以达到这样的效果，可是 `override` 过于粗暴，它同时会把从命令行定义的变量也覆盖了，而我们只想重新定义环境传来的，而不想重新定义命令行传来的。

## shell函数

shell函数也不像其它的函数。顾名思义，它的参数应该就是操作系统Shell的命令。它和反引号“`”是相同的功能。这就是说，shell函数把执行操作系统命令后的输出作为函数返回。于是，我们可以用操作系统命令以及字符串处理命令awk，sed等等命令来生成一个变量，如：

```makefile
contents := $(shell cat foo)
files := $(shell echo *.c)
```

注意，这个函数会新生成一个Shell程序来执行命令，所以你要注意其运行性能，如果你的Makefile中有一些比较复杂的规则，并大量使用了这个函数，那么对于你的系统性能是有害的。特别是Makefile的隐晦的规则可能会让你的shell函数执行的次数比你想像的多得多。

## 控制make的函数

make提供了一些函数来控制make的运行。通常，你需要检测一些运行Makefile时的运行时信息，并且根据这些信息来决定，你是让make继续执行，还是停止。

```makefile
$(error <text ...>)
```

产生一个致命的错误， `<text ...>` 是错误信息。注意，error函数不会在一被使用就会产生错误信息，所以如果你把其定义在某个变量中，并在后续的脚本中使用这个变量，那么也是可以的。例如：

示例一：

```makefile
ifdef ERROR_001
    $(error error is $(ERROR_001))
endif
```

示例二：

```makefile
ERR = $(error found an error!)

.PHONY: err

err: $(ERR)
```

示例一会在变量ERROR_001定义了后执行时产生error调用，而示例二则在目录err被执行时才发生error调用。

```makefile
$(warning <text ...>)
```

这个函数很像error函数，只是它并不会让make退出，只是输出一段警告信息，而make继续执行。











































