## IFU(Instruction Fetch Unit)

### 概览

两位同学将在本单元协作完成IFU的设计搭建与测试。

IFU是取指令单元，负责维护指令计数器PC以及取出当前指令。IFU中的存储空间与DM都是体系结构中 L1 cache(发音同cash) 的一部分。

在我们的CPU中，IFU中存储空间大小为16KB，地址空间为0x3000~0x6fff。支持PC的正常自增和按mips分支、跳转、寄存器跳转指令跳转。拥有一个32位数据输入口、一个64位数据输出口，以及控制、时钟、复位、使能信号口。其中，使能信号主要用于支持流水线的暂停操作，在单周期CPU中同学们始终将其置于高位即可。

IFU的功能分为**基础功能**和**扩展功能**两部分，只实现**基础功能**即可通过课程。

**基础功能**：支持PC的同步复位、自增，支持全部三种跳转方式，使能处于高电平时能够正确输出当前PC和当前指令.

**扩展功能**：使能处于低电平时停止PC自增、停止对跳转的响应，保持PC不变；任意情况下正确输出当前PC和当前指令.

*器件外观和测试点输出格式请与**器件外观**和**测试要求**中的模板代码保持完全一致，以免在互测阶段造成不必要的麻烦.

*关于基础功能和扩展功能的详细要求请仔细查阅**行为规范**.

### 器件外观

```verilog
module IFU(
    input wire [3:0]ctrlIn,
    input wire clk, rst, en,
    input wire [31:0]dataIn,
    output wire [63:0]dataOut
);
...
endmodule
```

IFU的输入输出信号有：

1. 来自控制器的4位控制信号`ctrlIn`。
2. 时钟信号`clk`、复位信号`rst`（高电平有效，同步复位）和使能信号`en`（高电平有效）。
3. 32位输入信号`dataIn`，用于输入分支和跳转指令中的立即数、R型跳转指令中的寄存器值。
4. 64位输出信号`dataOut`。其中高32位是当前的PC值，低32位是当前取出的指令码。

### 行为规范

除器件外观包含的信号外，IFU内部还应有一个被称为`IM(Data Memory)`的大小为16KB的存储空间用于存放指令，其基地址为0x3000。不妨约定其结构为

```verilog
(* rom_style="block" *) reg [31:0]mem[32'hc00:32'h0x1fff];
```

**下面定义行为规范：**

1. 复位方式为同步复位，复位完成时要求PC值为0x3000。

2. 除在initial块中，任何情况(包括复位)下禁止更改`IM`的内容，在仿真阶段，`IM`的内容应在initial块内从文件中完成加载。这里作一些规定：
   
   1. 指令文件名为`code.txt`，文件内每行一条指令，每条指令用16进制表示。另外，启动仿真时需要吧`code.txt`放在`工程目录/工程名.sim/sim_1/behav/xsim/`目录下，否则文件内容将无法读取。
   
   2. 在模块中使用`initial readmemh("code.txt", mem, 32'h3000);`载入指令序列。

3. 使能和复位信号均处于低电平时，保持PC值不变。

4. 使能信号高电平复位信号低电平时，每个时钟上升沿将npc的值写入pc。其中npc为组合逻辑，取值如下表：
   
   | ctrlIn | npc                             | 含义     |
   | ------ | ------------------------------- | ------ |
   | 0, >3  | pc+4                            | 顺序执行   |
   | 1      | pc+4+符号扩展(4\*dataIn低半字)         | 分支指令   |
   | 2      | {pc[31:28], dataIn[25:0], 2'b0} | 跳转指令   |
   | 3      | dataIn                          | R型跳转指令 |

5. dataOut高32位为当前PC值，低32位为`mem[pc[31:2]]`。

### 测试要求

1. 提供两个精心构造的测试点，一个仅测试基础功能，一个允许测试所有功能但须覆盖扩展功能。

2. tb文件要求在以下模板基础上修改得到：
   
   ```verilog
   module ifuTB;
       // signal definition
       reg clk, rst, en;
       reg [3:0]ctrlIn;
       reg [31:0]dataIn;
       wire[63:0]dataOut;
   
       // instantiation
       IFU uut(.clk(clk), .rst(rst), .en(en),
               .ctrlIn(ctrlIn),
               .dataIn(dataIn), .dataOut(dataOut));
   
       // excitation
       always #4 clk <= ~clk;
       initial begin
   
           {clk, rst, en} = 3'b011;
           #10 rst = 0;
           // your codes here
       end
   
       // display
       always #2 $display("%0d@ %08h::%08h",
       $time, dataOut[63:32], dataOut[31:0]);
   endmodule
   ```

3. 每个测试点额外提供`code.txt`，建议使用`MARS`编写汇编代码后导出，提前熟悉这一CPU测试阶段的重要工具软件。

4. 可以使用c/c++、python等语言编写程序生成有一定强度的测试点。

5. 如果tb中使用了verilog文件读写技巧，记得将数据文件一并提交。
   
   \*(vivado)数据文件放在`工程目录/工程名.sim/sim_1/behav/xsim/`目录下才能正常仿真

6. 每个测试点提供一个`coverage.txt`文件，写明你的测试点覆盖了哪些情况，与`tb.v`和其他文件一并提交，并将内容附在实验报告相关章节里。测试点强度将纳入总评，在`coverage.txt`中明确说明在这些情况下正确的电路将产生什么输出、不正确的电路将产生什么输出，不能在输出中体现的测试内容将被视作无效。
