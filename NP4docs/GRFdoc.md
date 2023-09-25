## GRF(General Register File)

### 概览

两位同学将在本单元协作完成GRF的设计搭建与测试。

GRF是通用寄存器堆，负责维护CPU中绝大多数寄存器并提供其访问方式，在MIPS体系结构中，GRF的地位十分重要。

在我们的CPU中，GRF集成了包括位扩展器的一些额外功能，使得控制器更加简洁高效。因此，除MIPS体系中约定的32个通用寄存器外，增加了6个特殊寄存器，编号为32~37。这些特殊寄存器的访问方式与通用寄存器无异，但内部需要通过组合逻辑实现。

GRF的全部功能均为**基础功能**。

**基础功能**：32个通用寄存器的写入读出、6个特殊寄存器的维护与访问.

*器件外观和测试点输出格式请与**器件外观**和**测试要求**中的模板代码保持完全一致，以免在互测阶段造成不必要的麻烦.

*关于基础功能的详细要求请仔细查阅**行为规范**.

### 器件外观

```verilog
module GRF(
    input wire clk, rst,
    input wire [23:0]addrIO,
    input wire [31:0]dataIn,
    output wire [31:0]dataOut0,
    output wire [31:0]dataOut1,
    output wire [31:0]dataOut2,
    input wire [31:0]instr,
    input wire [31:0]pc
);
...
endmodule
```

GRF的输入输出信号有：

1. 时钟信号`clk`和复位信号`rst`

2. 24位(4\*6)地址信号`addrIO`，其中，`addrIO[6* i +:6]`与`dataOut i`相对应、`addrIO[23:18]`与`dataIn`相对应

3. 32位输入数据信号`dataIn`

4. 3个32位输出数据信号`dataOut0~2`

5. 32位输入信号`instr`代表当前CPU正在处理的指令码

6. 32位输入信号`pc`代表当前CPU的PC值

### 行为规范

除器件外观包含的信号外，GRF内部还应有32个普通寄存器、6个特殊寄存器。不妨约定普通寄存器的结构为

```verilog
(* ram_style="registers" *) reg [31:0]mem[0:31];
```

不过，为了简单起见，我们约定整个GRF的逻辑结构为

```verilog
reg [31:0]mem[0:37];
```

后文中出现的mem按逻辑结构理解即可。

**下面定义行为规范：**

1. 复位方式为同步复位，复位完成时要求32个普通寄存器值为0

2. 读取
   
   记$a_i$为6位信号，满足$\{a_0, a_1, a_2, a_3\}=addrIO$，那么对于`dataOut0~2`要求:
   
   任意时刻满足$\forall \Psi \in\{0,1,2\},\ dataOut\Psi= mem[a_\Psi]$

3. 写入
   
   每个时钟上升沿，若复位信号处于低电平则执行写入操作。
   
   写入操作：若$a_3=0\lor a_3>31$则拒绝写入，否则将`dataIn`写入`mem[a3]`。
   
   任意时刻0号寄存器的值始终为0。

4. 特殊寄存器
   
   所有6个特殊寄存器都应使用组合逻辑实现，任意时刻它们的值与下表保持一致。
   
   | 寄存器号 | 值                     | 寄存器代号 |
   |:----:|:--------------------- |:-----:|
   | 32   | pc+3'd4               | pc4   |
   | 33   | instr[15:0]符号扩展至32位   | ext   |
   | 34   | instr[15:0]无符号扩展至32位  | extu  |
   | 35   | 高半字为instr[15:0]，低半字为0 | uext  |
   | 36   | instr                 | inst  |
   | 37   | instr[10:6]无符号扩展至32位  | shmt  |

### 测试要求

1. 提供一或两个精心构造的测试点。

2. tb文件要求在以下模板基础上修改得到：
   
   ```verilog
   module grfTB;
       // signal definition
       reg clk, rst;
       reg [23:0]addrIO;
       reg [31:0]dataIn;
       reg [31:0]instr;
       reg [31:0]pc;
       wire[31:0]dataOut0;
       wire[31:0]dataOut1;
       wire[31:0]dataOut2;
   
       // instantiation
       GRF uut(.clk(clk), .rst(rst),
               .addrIO(addrIO), .dataIn(dataIn), 
               .dataOut0(dataOut0), .dataOut1(dataOut1), .dataOut2(dataOut2),
               .instr(instr), .pc(pc));
   
       // excitation
       always #4 clk<=~clk;
       initial begin
           // reset at the very beginning
           {clk, rst} = 2'b11;
           #10 rst = 0;
           // your codes here
       end
   
       // display
       wire [5:0]a0; wire [5:0]a1; wire [5:0]a2; wire [5:0]a3;
       assign {a0, a1, a2, a3} = addrIO;
       always #2 $display("%0d[$0d,$0d,$0d,%0d]=>{%0h,%0h,%0h}",
           $time, a0, a1, a2, a3,
           dataOut0, dataOut1, dataOut2);
   endmodule
   ```

3. 可以使用c/c++、python等语言编写程序生成有一定强度的测试点。

4. 如果tb中使用了verilog文件读写技巧，记得将数据文件一并提交。
   
   \*(vivado)数据文件放在`工程目录/工程名.sim/sim_1/behav/xsim/`目录下才能正常仿真

5. 每个测试点提供一个`coverage.txt`文件，写明你的测试点覆盖了哪些情况，与`tb.v`和其他文件一并提交，并将内容附在实验报告相关章节里。测试点强度将纳入总评，在`coverage.txt`中明确说明在这些情况下正确的电路将产生什么输出、不正确的电路将产生什么输出，不能在输出中体现的测试内容将被视作无效。
