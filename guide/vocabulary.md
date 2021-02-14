+ **IFU**

  Instruction Fetch Unit, 取指令单元。将程序计数器PC(Program Counter)、NPC、指令存储器IM(Instruction Memory)集成为一个单元。这种做法减少了需要处理和命名的变量和接口数量。尽管MARS(*An IDE for MIPS Assembly Language Programming*)给出了指令和数据的统一存储视图，但请不要将指令存储器和数据存储器合并实现，后续工程中指令区和数据区的地址将出现重叠。

+ **DM**

  Data Memory, 数据存储器。现在可以简单地把它理解为内存或者RAM，但在真正的CPU中，它是 L1 cache 的一部分(另一部分是IM)。尽管MARS(*An IDE for MIPS Assembly Language Programming*)给出了指令和数据的统一存储视图，但请不要将IM和DM合并实现，后续工程中指令区和数据区的地址将出现重叠。

+ **GRF**

  General Register File, also known as GPR(General Purpose Registers), 通用寄存器堆。不同于绝大多数文献，本项目中，GRF将以特殊寄存器的形式集成位扩展器EXT和IFU的PC4/PC8(统称为PCE, E for extend)，以简化控制器设计。同时，本项目取消了GRF的写使能，由写0寄存器代替关闭写使能。

+ **EXT**

  Bit Extender, 位扩展器。本项目中被集成到GRF，因此减少了一个控制信号和两个多路选择器。

+ **PCE**

  Extended PC, JAL和JALR指令写回的PC，不知道该取什么名字所以姑且这样称呼吧。它在单周期CPU中是PC4，在流水线CPU中是PC8(因为引入了延迟槽DB)。它在本项目中被集成到GRF，因此减少了一路流水。

+ **ALU**

  Arithmetic Logic Unit, 算术逻辑单元。P4/P5阶段最不可能出bug的模块，没有之一，只需实现加减法，只有组合逻辑。但P6加入乘法器(乘除器)后就是另一番景象了，本项目把ALU的控制信号位宽开至6位，以便让乘法器与之共享控制信号。

+ **CMP**

  Comparator, 比较器。由于实在太短，被集成到通路管理器PM(Path Manager)中，因此没有抢走ALU的头衔。它接受两个32位操作数x, y，比较二者是否相等以及x是否<0，用于实现BEQ, BLTZ等分支指令。将CMP集成到ALU中会降低流水线的效率，可能在课上测试中出现超时。

+ **CTRL**

  Controller, 控制器。本项目中，CTRL需要生成的信号包括且仅包括GRF的四个地址(三读一写)、ALU、DM、IFU的操作码以及DM的写使能。本项目中CTRL生成的信号交由通路管理器PM(Path Manager)完成流水，它本身只包含组合逻辑。

+ **PM**

  Path Manager, 通路管理器。本项目的核心部件，代码量大幅降低的原因所在。它接管几乎所有的接口，以构建数据通路。引入PM的直接结果是流水线的实现只跟这一个部件有关，修改PM的内部结构即可完成从单周期到流水线的转变。这也是本项目超高代码复用率的原因所在。

+ **位拼接运算符**

  位拼接运算符十分有助于简化代码、使代码更直观。强烈推荐。