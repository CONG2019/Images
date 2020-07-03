# 概述

- ***makefile关系到了整个工程的编译规则。***

- ***makefile定义了一系列的规则来指定，哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译，甚至于进行更复杂的功能操作，因为makefile就像一个Shell脚本一样，其中也可以执行操作系统的命令。***

- ***在此，我想多说关于程序编译的一些规范和方法。一般来说，无论是C还是C++，首先要把源文件编译成中间代码文件，在Windows下也就是 `.obj` 文件，UNIX下是 `.o` 文件，即Object File，这个动作叫做编译（compile）。然后再把大量的Object File合成执行文件，这个动作叫作链接（link）。***

- 链接时，主要是链接函数和全局变量。所以，我们可以使用这些中间目标文件（ `.o` 文件或 `.obj` 文件）来链接我们的应用程序。链接器并不管函数所在的源文件，只管函数的中间目标文件（Object  File），在大多数时候，由于源文件太多，编译生成的中间目标文件太多，而在链接时需要明显地指出中间目标文件名，这对于编译很不方便。所以，我们要给中间目标文件打个包，在Windows下这种包叫“库文件”（Library File），也就是 `.lib` 文件，在UNIX下，是Archive File，也就是 `.a` 文件。
- makefile中各赋值语句
   - = 是最基本的赋值
   - := 是覆盖之前的值
   - ?= 是如果没有被赋值过就赋予等号后面的值
   - += 是添加等号后面的值

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

# make的运行

## 指定Makefile

***GNU make找寻默认的Makefile的规则是在当前目录下依次找三个文件——“GNUmakefile”、“makefile”和“Makefile”。***

```makefile
#指定文件执行make
#如果在make的命令行是，你不只一次地使用了 -f 参数，那么，所有指定的makefile将会被连在一起传递给make执行。
make –f hchen.mk
```

## 指定目标

***在make命令后直接跟目标的名字(如前面提到的“make clean”形式）***

- all:这个伪目标是所有目标的目标，其功能一般是编译所有的目标。
- clean:这个伪目标功能是删除所有被make创建的文件。
- install:这个伪目标功能是安装已编译好的程序，其实就是把目标执行文件拷贝到指定的目标中去。
- print:这个伪目标的功能是例出改变过的源文件。
- tar:这个伪目标功能是把源程序打包备份。也就是一个tar文件。
- dist:这个伪目标功能是创建一个压缩文件，一般是把tar文件压成Z文件。或是gz文件。
- TAGS:这个伪目标功能是更新所有的目标，以备完整地重编译使用。
- check和test:这两个伪目标一般用来测试makefile的流程。

***有一个make的环境变量叫 `MAKECMDGOALS` ，这个变量中会存放你所指定的终极目标的列表，如果在命令行上，你没有指定目标，那么，这个变量是空值。这个变量可以让你使用在一些比较特殊的情形下。比如下面的例子：***

```makefile
sources = foo.c bar.c
ifneq ( $(MAKECMDGOALS),clean)
    include $(sources:.c=.d)
endif
```

## 检查规则

有时候，我们不想让我们的makefile中的规则执行起来，我们只想检查一下我们的命令，或是执行的序列。于是我们可以使用make命令的下述参数：

- `-n`, `--just-print`, `--dry-run`, `--recon`

  不执行参数，这些参数只是打印命令，不管目标是否更新，把规则和连带规则下的命令打印出来，但不执行，这些参数对于我们调试makefile很有用处。

- `-t`, `--touch`

  这个参数的意思就是把目标文件的时间更新，但不更改目标文件。也就是说，make假装编译目标，但不是真正的编译目标，只是把目标变成已编译过的状态。

- `-q`, `--question`

  这个参数的行为是找目标的意思，也就是说，如果目标存在，那么其什么也不会输出，当然也不会执行编译，如果目标不存在，其会打印出一条出错信息。

- `-W <file>`, `--what-if=<file>`, `--assume-new=<file>`, `--new-file=<file>`

  这个参数需要指定一个文件。一般是源文件（或依赖文件），Make会根据规则推导来运行依赖于这个文件的命令，一般来说，可以和“-n”参数一同使用，来查看这个依赖文件所发生的规则命令。

## make的参数

下面列举了所有GNU make 3.80版的参数定义。其它版本和产商的make大同小异，不过其它产商的make的具体参数还是请参考各自的产品文档。

- `-b`, `-m`

  这两个参数的作用是忽略和其它版本make的兼容性。

- `-B`, `--always-make`

  认为所有的目标都需要更新（重编译）。

- `-C` *<dir>*, `--directory`=*<dir>*

  指定读取makefile的目录。如果有多个“-C”参数，make的解释是后面的路径以前面的作为相对路径，并以最后的目录作为被指定目录。如：“make -C ~hchen/test -C prog”等价于“make -C ~hchen/test/prog”。

- `-debug`[=*<options>*]

  输出make的调试信息。它有几种不同的级别可供选择，如果没有参数，那就是输出最简单的调试信息。下面是<options>的取值： a: 也就是all，输出所有的调试信息。（会非常的多） b: 也就是basic，只输出简单的调试信息。即输出不需要重编译的目标。 v: 也就是verbose，在b选项的级别之上。输出的信息包括哪个makefile被解析，不需要被重编译的依赖文件（或是依赖目标）等。 i: 也就是implicit，输出所以的隐含规则。 j: 也就是jobs，输出执行规则中命令的详细信息，如命令的PID、返回码等。 m: 也就是makefile，输出make读取makefile，更新makefile，执行makefile的信息。

- `-d`

  相当于“–debug=a”。

- `-e`, `--environment-overrides`

  指明环境变量的值覆盖makefile中定义的变量的值。

- `-f`=*<file>*, `--file`=*<file>*, `--makefile`=*<file>*

  指定需要执行的makefile。

- `-h`, `--help`

  显示帮助信息。

- `-i` , `--ignore-errors`

  在执行时忽略所有的错误。

- `-I` *<dir>*, `--include-dir`=*<dir>*

  指定一个被包含makefile的搜索目标。可以使用多个“-I”参数来指定多个目录。

- `-j` [*<jobsnum>*], `--jobs`[=*<jobsnum>*]

  指同时运行命令的个数。如果没有这个参数，make运行命令时能运行多少就运行多少。如果有一个以上的“-j”参数，那么仅最后一个“-j”才是有效的。（注意这个参数在MS-DOS中是无用的）

- `-k`, `--keep-going`

  出错也不停止运行。如果生成一个目标失败了，那么依赖于其上的目标就不会被执行了。

- `-l` *<load>*, `--load-average`[=*<load>*], `-max-load`[=*<load>*]

  指定make运行命令的负载。

- `-n`, `--just-print`, `--dry-run`, `--recon`

  仅输出执行过程中的命令序列，但并不执行。

- `-o` *<file>*, `--old-file`=*<file>*, `--assume-old`=*<file>*

  不重新生成的指定的<file>，即使这个目标的依赖文件新于它。

- `-p`, `--print-data-base`

  输出makefile中的所有数据，包括所有的规则和变量。这个参数会让一个简单的makefile都会输出一堆信息。如果你只是想输出信息而不想执行makefile，你可以使用“make -qp”命令。如果你想查看执行makefile前的预设变量和规则，你可以使用 “make –p –f  /dev/null”。这个参数输出的信息会包含着你的makefile文件的文件名和行号，所以，用这个参数来调试你的  makefile会是很有用的，特别是当你的环境变量很复杂的时候。

- `-q`, `--question`

  不运行命令，也不输出。仅仅是检查所指定的目标是否需要更新。如果是0则说明要更新，如果是2则说明有错误发生。

- `-r`, `--no-builtin-rules`

  禁止make使用任何隐含规则。

- `-R`, `--no-builtin-variabes`

  禁止make使用任何作用于变量上的隐含规则。

- `-s`, `--silent`, `--quiet`

  在命令运行时不输出命令的输出。

- `-S`, `--no-keep-going`, `--stop`

  取消“-k”选项的作用。因为有些时候，make的选项是从环境变量“MAKEFLAGS”中继承下来的。所以你可以在命令行中使用这个参数来让环境变量中的“-k”选项失效。

- `-t`, `--touch`

  相当于UNIX的touch命令，只是把目标的修改日期变成最新的，也就是阻止生成目标的命令运行。

- `-v`, `--version`

  输出make程序的版本、版权等关于make的信息。

- `-w`, `--print-directory`

  输出运行makefile之前和之后的信息。这个参数对于跟踪嵌套式调用make时很有用。

- `--no-print-directory`

  禁止“-w”选项。

- `-W` *<file>*, `--what-if`=*<file>*, `--new-file`=*<file>*, `--assume-file`=*<file>*

  假定目标<file>;需要更新，如果和“-n”选项使用，那么这个参数会输出该目标更新时的运行动作。如果没有“-n”那么就像运行UNIX的“touch”命令一样，使得<file>;的修改时间为当前时间。

- `--warn-undefined-variables`

  只要make发现有未定义的变量，那么就输出警告信息。

# 隐含规则

## 隐含规则一览

**这里我们将讲述所有预先设置（也就是make内建）的隐含规则，如果我们不明确地写下规则，那么，make就会在这些规则中寻找所需要规则和命令。当然，我们也可以使用make的参数 `-r` 或 `--no-builtin-rules` 选项来取消所有的预设置的隐含规则。**

1. 编译C程序的隐含规则。

   `<n>.o` 的目标的依赖目标会自动推导为 `<n>.c` ，并且其生成命令是 `$(CC) –c $(CPPFLAGS) $(CFLAGS)`

2. 编译C++程序的隐含规则。

   `<n>.o` 的目标的依赖目标会自动推导为 `<n>.cc` 或是 `<n>.C` ，并且其生成命令是 `$(CXX) –c $(CPPFLAGS) $(CFLAGS)` 。（建议使用 `.cc` 作为C++源文件的后缀，而不是 `.C` ）

3. 编译Pascal程序的隐含规则。

   `<n>.o` 的目标的依赖目标会自动推导为 `<n>.p` ，并且其生成命令是 `$(PC) –c $(PFLAGS)` 。

4. 编译Fortran/Ratfor程序的隐含规则。

   `<n>.o` 的目标的依赖目标会自动推导为 `<n>.r` 或 `<n>.F` 或 `<n>.f` ，并且其生成命令是:

   - `.f`  `$(FC) –c $(FFLAGS)`
   - `.F`  `$(FC) –c $(FFLAGS) $(CPPFLAGS)`
   - `.f`  `$(FC) –c $(FFLAGS) $(RFLAGS)`

5. 预处理Fortran/Ratfor程序的隐含规则。

   `<n>.f` 的目标的依赖目标会自动推导为 `<n>.r` 或 `<n>.F` 。这个规则只是转换Ratfor 或有预处理的Fortran程序到一个标准的Fortran程序。其使用的命令是：

   - `.F`  `$(FC) –F $(CPPFLAGS) $(FFLAGS)`
   - `.r`  `$(FC) –F $(FFLAGS) $(RFLAGS)`

6. 编译Modula-2程序的隐含规则。

   `<n>.sym` 的目标的依赖目标会自动推导为 `<n>.def` ，并且其生成命令是： `$(M2C) $(M2FLAGS) $(DEFFLAGS)` 。 `<n>.o` 的目标的依赖目标会自动推导为 `<n>.mod` ，并且其生成命令是： `$(M2C) $(M2FLAGS) $(MODFLAGS)` 。

7. 汇编和汇编预处理的隐含规则。

   `<n>.o` 的目标的依赖目标会自动推导为 `<n>.s` ，默认使用编译器 `as` ，并且其生成命令是： `$ (AS) $(ASFLAGS)` 。 `<n>.s` 的目标的依赖目标会自动推导为 `<n>.S` ，默认使用C预编译器 `cpp` ，并且其生成命令是： `$(AS) $(ASFLAGS)` 。

8. 链接Object文件的隐含规则。

   `<n>` 目标依赖于 `<n>.o` ，通过运行C的编译器来运行链接程序生成（一般是 `ld` ），其生成命令是： `$(CC) $(LDFLAGS) <n>.o $(LOADLIBES) $(LDLIBS)` 。这个规则对于只有一个源文件的工程有效，同时也对多个Object文件（由不同的源文件生成）的也有效。例如如下规则:

   ```
   x : y.o z.o
   ```

   并且 `x.c` 、 `y.c` 和 `z.c` 都存在时，隐含规则将执行如下命令:

   ```
   cc -c x.c -o x.o
   cc -c y.c -o y.o
   cc -c z.c -o z.o
   cc x.o y.o z.o -o x
   rm -f x.o
   rm -f y.o
   rm -f z.o
   ```

   如果没有一个源文件（如上例中的x.c）和你的目标名字（如上例中的x）相关联，那么，你最好写出自己的生成规则，不然，隐含规则会报错的。

9. Yacc C程序时的隐含规则。

   `<n>.c` 的依赖文件被自动推导为 `n.y` （Yacc生成的文件），其生成命令是： `$(YACC) $(YFALGS)` 。（“Yacc”是一个语法分析器，关于其细节请查看相关资料）

10. Lex C程序时的隐含规则。

    `<n>.c` 的依赖文件被自动推导为 `n.l` （Lex生成的文件），其生成命令是： `$(LEX) $(LFALGS)` 。（关于“Lex”的细节请查看相关资料）

11. Lex Ratfor程序时的隐含规则。

    `<n>.r` 的依赖文件被自动推导为 `n.l` （Lex生成的文件），其生成命令是： `$(LEX) $(LFALGS)` 。

12. 从C程序、Yacc文件或Lex文件创建Lint库的隐含规则。

    `<n>.ln`  （lint生成的文件）的依赖文件被自动推导为 `n.c` ，其生成命令是： `$(LINT) $(LINTFALGS) $(CPPFLAGS) -i` 。对于 `<n>.y` 和 `<n>.l` 也是同样的规则。

## 隐含规则使用变量

***可以利用make的 `-R` 或 `--no–builtin-variables` 参数来取消你所定义的变量对隐含规则的作用。***

### 关于命令的变量。

- `AR` : 函数库打包程序。默认命令是 `ar`
- `AS` : 汇编语言编译程序。默认命令是 `as`
- `CC` : C语言编译程序。默认命令是 `cc`
- `CXX` : C++语言编译程序。默认命令是 `g++`
- `CO` : 从 RCS文件中扩展文件程序。默认命令是 `co`
- `CPP` : C程序的预处理器（输出是标准输出设备）。默认命令是 `$(CC) –E`
- `FC` : Fortran 和 Ratfor 的编译器和预处理程序。默认命令是 `f77`
- `GET` : 从SCCS文件中扩展文件的程序。默认命令是 `get`
- `LEX` : Lex方法分析器程序（针对于C或Ratfor）。默认命令是 `lex`
- `PC` : Pascal语言编译程序。默认命令是 `pc`
- `YACC` : Yacc文法分析器（针对于C程序）。默认命令是 `yacc`
- `YACCR` : Yacc文法分析器（针对于Ratfor程序）。默认命令是 `yacc –r`
- `MAKEINFO` : 转换Texinfo源文件（.texi）到Info文件程序。默认命令是 `makeinfo`
- `TEX` : 从TeX源文件创建TeX DVI文件的程序。默认命令是 `tex`
- `TEXI2DVI` : 从Texinfo源文件创建军TeX DVI 文件的程序。默认命令是 `texi2dvi`
- `WEAVE` : 转换Web到TeX的程序。默认命令是 `weave`
- `CWEAVE` : 转换C Web 到 TeX的程序。默认命令是 `cweave`
- `TANGLE` : 转换Web到Pascal语言的程序。默认命令是 `tangle`
- `CTANGLE` : 转换C Web 到 C。默认命令是 `ctangle`
- `RM` : 删除文件命令。默认命令是 `rm –f`

### 关于命令参数的变量

下面的这些变量都是相关上面的命令的参数。如果没有指明其默认值，那么其默认值都是空。

- `ARFLAGS` : 函数库打包程序AR命令的参数。默认值是 `rv`
- `ASFLAGS` : 汇编语言编译器参数。（当明显地调用 `.s` 或 `.S` 文件时）
- `CFLAGS` : C语言编译器参数。
- `CXXFLAGS` : C++语言编译器参数。
- `COFLAGS` : RCS命令参数。
- `CPPFLAGS` : C预处理器参数。（ C 和 Fortran 编译器也会用到）。
- `FFLAGS` : Fortran语言编译器参数。
- `GFLAGS` : SCCS “get”程序参数。
- `LDFLAGS` : 链接器参数。（如： `ld` ）
- `LFLAGS` : Lex文法分析器参数。
- `PFLAGS` : Pascal语言编译器参数。
- `RFLAGS` : Ratfor 程序的Fortran 编译器参数。
- `YFLAGS` : Yacc文法分析器参数。

## 定义模式规则

### 模式规则介绍

模式规则中，至少在规则的目标定义中要包含 `%` ，否则，就是一般的规则。目标中的 `%` 定义表示对文件名的匹配， `%` 表示长度任意的非空字符串。例如： `%.c` 表示以 `.c` 结尾的文件名（文件名的长度至少为3），而 `s.%.c` 则表示以 `s.` 开头， `.c` 结尾的文件名（文件名的长度至少为5）。

如果 `%` 定义在目标中，那么，目标中的 `%` 的值决定了依赖目标中的 `%` 的值，也就是说，目标中的模式的 `%` 决定了依赖目标中 `%` 的样子。例如有一个模式规则如下：

```makefile
%.o : %.c ; <command ......>;
```

其含义是，指出了怎么从所有的 `.c` 文件生成相应的 `.o` 文件的规则。如果要生成的目标是 `a.o b.o` ，那么 `%c` 就是 `a.c b.c` 。

一旦依赖目标中的 `%`  模式被确定，那么，make会被要求去匹配当前目录下所有的文件名，一旦找到，make就会规则下的命令，所以，在模式规则中，目标可能会是多个的，如果有模式匹配出多个目标，make就会产生所有的模式目标，此时，make关心的是依赖的文件名和生成目标的命令这两件事。

### 模式规则示例

下面这个例子表示了,把所有的 `.c` 文件都编译成 `.o` 文件.

```makefile
%.o : %.c
    $(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
```

其中， `$@` 表示所有的目标的挨个值， `$<` 表示了所有依赖目标的挨个值。这些奇怪的变量我们叫“自动化变量”，后面会详细讲述。

下面的这个例子中有两个目标是模式的：

```makefile
%.tab.c %.tab.h: %.y
    bison -d $<
```

这条规则告诉make把所有的 `.y` 文件都以 `bison -d <n>.y` 执行，然后生成 `<n>.tab.c` 和 `<n>.tab.h` 文件。（其中， `<n>` 表示一个任意字符串）。如果我们的执行程序 `foo` 依赖于文件 `parse.tab.o` 和 `scan.o` ，并且文件 `scan.o` 依赖于文件 `parse.tab.h` ，如果 `parse.y` 文件被更新了，那么根据上述的规则， `bison -d parse.y` 就会被执行一次，于是， `parse.tab.o` 和 `scan.o` 的依赖文件就齐了。（假设， `parse.tab.o` 由 `parse.tab.c` 生成，和 `scan.o` 由 `scan.c` 生成，而 `foo` 由 `parse.tab.o` 和 `scan.o` 链接生成，而且 `foo` 和其 `.o` 文件的依赖关系也写好，那么，所有的目标都会得到满足）

### 自动化变量

面是所有的自动化变量及其说明：

- `$@` : 表示规则中的目标文件集。在模式规则中，如果有多个目标，那么， `$@` 就是匹配于目标中模式定义的集合。
- `$%` : 仅当目标是函数库文件中，表示规则中的目标成员名。例如，如果一个目标是 `foo.a(bar.o)` ，那么， `$%` 就是 `bar.o` ， `$@` 就是 `foo.a` 。如果目标不是函数库文件（Unix下是 `.a` ，Windows下是 `.lib` ），那么，其值为空。
- `$<` : 依赖目标中的第一个目标名字。如果依赖目标是以模式（即 `%` ）定义的，那么 `$<` 将是符合模式的一系列的文件集。注意，其是一个一个取出来的。
- `$?` : 所有比目标新的依赖目标的集合。以空格分隔。
- `$^` : 所有的依赖目标的集合。以空格分隔。如果在依赖目标中有多个重复的，那么这个变量会去除重复的依赖目标，只保留一份。
- `$+` : 这个变量很像 `$^` ，也是所有依赖目标的集合。只是它不去除重复的依赖目标。
- `$*` : 这个变量表示目标模式中 `%` 及其之前的部分。如果目标是 `dir/a.foo.b` ，并且目标的模式是 `a.%.b` ，那么， `$*` 的值就是 `dir/a.foo` 。这个变量对于构造有关联的文件名是比较有较。如果目标中没有模式的定义，那么 `$*` 也就不能被推导出，但是，如果目标文件的后缀是make所识别的，那么 `$*` 就是除了后缀的那一部分。例如：如果目标是 `foo.c` ，因为 `.c` 是make所能识别的后缀名，所以， `$*` 的值就是 `foo` 。这个特性是GNU make的，很有可能不兼容于其它版本的make，所以，你应该尽量避免使用 `$*` ，除非是在隐含规则或是静态模式中。如果目标中的后缀是make所不能识别的，那么 `$*` 就是空值。

下面是对于上面的七个变量分别加上 `D` 或是 `F` 的含义：

- `$(@D)`

  表示 `$@` 的目录部分（不以斜杠作为结尾），如果 `$@` 值是 `dir/foo.o` ，那么 `$(@D)` 就是 `dir` ，而如果 `$@` 中没有包含斜杠的话，其值就是 `.` （当前目录）。

- `$(@F)`

  表示 `$@` 的文件部分，如果 `$@` 值是 `dir/foo.o` ，那么 `$(@F)` 就是 `foo.o` ， `$(@F)` 相当于函数 `$(notdir $@)` 。

- `$(*D)`, `$(*F)`

  和上面所述的同理，也是取文件的目录部分和文件部分。对于上面的那个例子， `$(*D)` 返回 `dir` ，而 `$(*F)` 返回 `foo`

- `$(%D)`, `$(%F)`

  分别表示了函数包文件成员的目录部分和文件部分。这对于形同 `archive(member)` 形式的目标中的 `member` 中包含了不同的目录很有用。

- `$(<D)`, `$(<F)`

  分别表示依赖文件的目录部分和文件部分。

- `$(^D)`, `$(^F)`

  分别表示所有依赖文件的目录部分和文件部分。（无相同的）

- `$(+D)`, `$(+F)`

  分别表示所有依赖文件的目录部分和文件部分。（可以有相同的）

- `$(?D)`, `$(?F)`

  分别表示被更新的依赖文件的目录部分和文件部分。

**最后想提醒一下的是，对于 `$<` ，为了避免产生不必要的麻烦，我们最好给 `$` 后面的那个特定字符都加上圆括号，比如， `$(<)` 就要比 `$<` 要好一些。**

### 模式的匹配

一般来说，一个目标的模式有一个有前缀或是后缀的 `%` ，或是没有前后缀，直接就是一个 `%` 。因为 `%` 代表一个或多个字符，所以在定义好了的模式中，我们把 `%` 所匹配的内容叫做“茎”，例如 `%.c` 所匹配的文件“test.c”中“test”就是“茎”。因为在目标和依赖目标中同时有 `%` 时，依赖目标的“茎”会传给目标，当做目标中的“茎”。

当一个模式匹配包含有斜杠（实际也不经常包含）的文件时，那么在进行模式匹配时，目录部分会首先被移开，然后进行匹配，成功后，再把目录加回去。在进行“茎”的传递时，我们需要知道这个步骤。例如有一个模式 `e%t` ，文件 `src/eat` 匹配于该模式，于是 `src/a` 就是其“茎”，如果这个模式定义在依赖目标中，而被依赖于这个模式的目标中又有个模式 `c%r` ，那么，目标就是 `src/car` 。（“茎”被传递）

## 重载内建隐含规则

可以重载内建的隐含规则（或是定义一个全新的），例如你可以重新构造和内建隐含规则不同的命令，如：

```
%.o : %.c
    $(CC) -c $(CPPFLAGS) $(CFLAGS) -D$(date)
```

你可以取消内建的隐含规则，只要不在后面写命令就行。如：

```
%.o : %.s
```

同样，你也可以重新定义一个全新的隐含规则，其在隐含规则中的位置取决于你在哪里写下这个规则。朝前的位置就靠前。

## 隐含规则搜索算法

比如我们有一个目标叫 T。下面是搜索目标T的规则的算法。请注意，在下面，我们没有提到后缀规则，原因是，所有的后缀规则在Makefile被载入内存时，会被转换成模式规则。如果目标是 `archive(member)` 的函数库文件模式，那么这个算法会被运行两次，第一次是找目标T，如果没有找到的话，那么进入第二次，第二次会把 `member` 当作T来搜索。

1. 把T的目录部分分离出来。叫D，而剩余部分叫N。（如：如果T是 `src/foo.o` ，那么，D就是 `src/` ，N就是 `foo.o` ）
2. 创建所有匹配于T或是N的模式规则列表。
3. 如果在模式规则列表中有匹配所有文件的模式，如 `%` ，那么从列表中移除其它的模式。
4. 移除列表中没有命令的规则。
5. 对于第一个在列表中的模式规则：
   1. 推导其“茎”S，S应该是T或是N匹配于模式中 `%` 非空的部分。
   2. 计算依赖文件。把依赖文件中的 `%` 都替换成“茎”S。如果目标模式中没有包含斜框字符，而把D加在第一个依赖文件的开头。
   3. 测试是否所有的依赖文件都存在或是理当存在。（如果有一个文件被定义成另外一个规则的目标文件，或者是一个显式规则的依赖文件，那么这个文件就叫“理当存在”）
   4. 如果所有的依赖文件存在或是理当存在，或是就没有依赖文件。那么这条规则将被采用，退出该算法。
6. 如果经过第5步，没有模式规则被找到，那么就做更进一步的搜索。对于存在于列表中的第一个模式规则：
   1. 如果规则是终止规则，那就忽略它，继续下一条模式规则。
   2. 计算依赖文件。（同第5步）
   3. 测试所有的依赖文件是否存在或是理当存在。
   4. 对于不存在的依赖文件，递归调用这个算法查找他是否可以被隐含规则找到。
   5. 如果所有的依赖文件存在或是理当存在，或是就根本没有依赖文件。那么这条规则被采用，退出该算法。
   6. 如果没有隐含规则可以使用，查看 `.DEFAULT` 规则，如果有，采用，把 `.DEFAULT` 的命令给T使用。

一旦规则被找到，就会执行其相当的命令，而此时，我们的自动化变量的值才会生成。

# 使用make更新函数库文件

***函数库文件也就是对Object文件（程序编译的中间文件）的打包文件。在Unix下，一般是由命令 `ar` 来完成打包工作***

## 函数库文件的成员

一个函数库文件由多个文件组成。你可以用如下格式指定函数库文件及其组成:

```
archive(member)
```

这个不是一个命令，而一个目标和依赖的定义。一般来说，这种用法基本上就是为了 `ar` 命令来服务的。如:

```
foolib(hack.o) : hack.o
    ar cr foolib hack.o
```

如果要指定多个member，那就以空格分开，如:

```
foolib(hack.o kludge.o)
```

其等价于:

```
foolib(hack.o) foolib(kludge.o)
```

你还可以使用Shell的文件通配符来定义，如:

```
foolib(*.o)
```





