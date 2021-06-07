## 呕心沥血的 CO-LAB

别骂了别骂了，人家放的是重构代码所以只有P4跟P5

orz

---

This project attempts to simplify CPU structure with no performance decline. It achieved a 30%+ code decrease formulating a basic MIPS Pipeline CPU compared to the recommended method in BUAA CO Lab 2020 at the very first version.

The main idea is to accomplish everything with address instead of explicitly defined multiplexers. 

- Bit extender, IFU(instruction fetch unit) instruction, and write-back PC(program counter) are merged into GRF(general register file) for approaches using address.
- The data path is assembled by an additional unit PM(path manager), which takes over almost every plugin of the other components. The memory-like inside makes simplicity and high efficiency.
- More details available in the source code and design note of every sub project.

---

这个项目旨在不损失性能的前提下简化CPU结构。相比于BUAA计组2020秋课程推荐方法，本项目的第一个版本在P5阶段减少了30%+的代码量。

核心思想在于尽量通过寻址而不是显式定义的多路选择器解决所有事情。

- 位扩展器、32位指令、PC4/PC8被以特殊寄存器的形式集成到GRF(通用寄存器堆)中。
- 数据通路由一个额外的模块——PM(Path Manager)完成整合。这个模块接管几乎所有其他部件的数据端口，内部以类似存储器的形式实现，效率与简洁兼得。
- 更多细节请查阅源代码和设计文档。
- P4、P5已通过ch大佬的测试，请放心食用。
