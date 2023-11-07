### 架构

**CPU的运行过程如同参加一场考试。**

考试：读题 -> 思考 -> 计算 -> 写答题纸

CPU：取指令 -> 解析 -> 执行 -> 写回

CPU既可以读写内存，也可以读写寄存器堆。寄存器的速度大约比内存快10倍，但与L1cache速度相近。

**寄存器堆与内存正如同短期记忆和草稿纸。**

寄存器是十分有限的，内存空间是十分充裕的。编写汇编代码时，把频繁使用的数据存入寄存器，把其他数据放在内存，可使CPU效率最高。

**MIPS架构**

单周期CPU每周期只能执行一条指令，单条流水线每周期也只能新放入一条指令。仔细思考，这必然导致所有指令共用同一个数据通路，因此必须保证数据通路中

取出指令 -> 解析指令 -> 取操作数 -> 执行计算 -> 访问内存 -> 写回寄存器堆

\*需要指出的是，尽管跳转和分支操作发生在IFU中，但在执行时序上，显然处于执行计算这一阶段。

### 寻址 vs 多选器

我们的CPU中，常常用寻址的概念替代多选器的概念。

尽管寻址的实际实现就是多选器，然而两个概念所对应的设计理念有明显差异：

1. 寻址：用统一的寻址操作实现多样化的功能；多选器：试图为每个单一功能都设计一个多选器

2. 考虑寻址时我们希望为每个功能安排一个地址；考虑多选器时我们希望为每个可选位置安排一个多选器

3. 用多选器搭建CPU在概念上非常简单直观，但会使顶层模块变复杂、数据通路封装性变差，在流水线CPU中这会显著提高设计和调试难度。基于寻址的设计则更抽象，但它通过将大量零散的多选器合并为少量大多选器，能显著提高封装性，减少代码量，也使CPU更易于调试。

4. 以寻址方式搭建的数据通路时延更短，效率更高，因为总有$\log (\sum x_i)<\sum\log x_i$，其中$x$是多选器的输入数量。

5. 得益于寻址方式带来的超低耦合，我们的课程可以设计相互独立的6个单元以及合理的进度检查点，可以组织器件级互测，同时，我们的CPU也可以简单的从单周期过渡到流水线。

#### 用寄存器搞定一切

在通常的设计中，立即数位扩展、链接操作中写回PC等操作都是分别通过额外的专用控制信号实现的。直接结果是控制器变得复杂、数据通路中产生大量零散多路选择器，这对设计和调试都不友好。

我们选择将这些功能统一抽象成寄存器取数，消去了这些纷繁冗杂的结构，于是产生了简洁和美。

### 数据通路器件化

人们常常认为数据通路就是CPU的顶层模块，但从功能来看，数据通路提供了各个器件之间的端口映射，特别是在流水线、超标量CPU中，数据通路提供的功能并不简单。应当为数据通路做封装，使得它可以单独开发、单独测试。封装后以器件形式存在的数据通路也更容易单独升级改造。

数据通路被器件化后，CPU的顶层模块就只剩下I/O和简单的接线，结构更加合理。