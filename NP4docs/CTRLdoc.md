## CTRL(Controller)

### 概览

两位同学将在本单元协作完成CTRL(控制器)的设计搭建与测试。

CTRL负责解析指令码，产生控制信号。

在我们的CPU中，除32位指令码外，CTRL还有一个来自比较器的两位输入，用于判断分支条件。于是我们的CTRL有一个32位指令输入和一个2位比较信号输入，一个12位控制信号输出和一个24位GRF地址信号输出。

CTRL的功能分为**基础功能**和**扩展功能**两部分，只实现**基础功能**即可通过课程。

**基础功能**：支持识别下列指令并生成对应的控制信号和地址信号： **{addu, subu, ori, lui, lw, sw, beq, j, jal, jr,nop}** .

**扩展功能**：支持识别下列指令并生成对应的控制信号和地址信号： **{addi, addiu, xor, sll, srl, sra, lh, lhu, lb, lbu, sh, sb, bne, bgez, bgtz, blez, bltz, jalr}**.

\*器件外观和测试点输出格式请与**器件外观**和**测试要求**中的模板代码保持完全一致，以免在互测阶段造成不必要的麻烦.

\*关于基础功能和扩展功能的详细要求请仔细查阅**行为规范**.

### 器件外观

```verilog
module CTRL(
    input wire [31:0]instr,
    input wire [1:0]cmp,
    output wire[11:0]ctrlOut,
    output wire[23:0]addrIO
);
...
endmodule
```

CTRL的输入输出信号有：

1. 32位来自IFU的指令输入信号`instr`.
2. 2位来自比较器的比较输入信号`cmp`. (比较器集成到HUB中实现)
3. 12位控制信号输出`ctrlOut`，其中`ctrlOut[11:8]`、`ctrlOut[7:4]`、`ctrlOut[3:0]`分别记作`ifuCtrl`、`aluCtrl`、`dmCtrl`.
4. 24位GRF地址信号`addrIO`，含义与GRF中同名输入口一致.

### 行为规范

**首先约定一些信号：**

32位mips R型指令码中，高位到地位依次是`code`, `rs`, `rt`, `rd`, `shamt`, `func`。注意到指令码中的`rs`, `rt`, `rd`是5位信号，但我们的GRF需要6位地址，因此需要高位补0。参考代码如下：

```verilog
wire [5:0]code; wire [5:0]func; wire [4:0]shamt;
wire [5:0]rs; wire [5:0]rt; wire [5:0]rd;

assign {code, rs[4:0], rt[4:0], rd[4:0], shamt, func} = instr;
assign {rs[5], rt[5], rd[5]} = 3'b0;
```

对于I型和J型指令，以上信号并不总有意义，但有意义信号的位置保持不变：

I型：`{code, rs[4:0], rt[4:0], imm} = instr`

J型：`{code, imm} = instr`

**关于比较器输出信号：**

`cmp[0] == ~GRF.dataOut0[31]`，即`cmp[0]`代表GRF的dataOut0是否小于0

`cmp[1] == (GRF.dataOut0 == GRF.dataOut1)`，即`cmp[1]`代表GRF的dataOut0和dataOut1是否相等。

**下面定义行为规范：**

1. 参考mips指令集文档为每条指令给出控制信号和GRF地址信号

2. 对于R型指令，满足:
   
   + `{a0, a1, a2, a3} == {rs, rt, 6'b0, rd}`

3. 对于I型指令，满足：
   
   + `{a0, a1, a2, a3} == {rs, ??, ??, rd}`
   
   + `a1 > 31 && (a2 == 0 || a2 > 31)`

4. 对于分支指令(如beq)，满足：
   
   + `{a0, a1, a2, a3} == {6'd36, rs, rt, 6'b0}`. (36号寄存器代号为inst)

5. 对于需要执行链接操作的指令，满足：
   
   + `a2 == 6'd32`. (32号寄存器代号为pc4)

6. 对于R型跳转指令，满足：
   
   + `a0 == rs`

7. 不需要的信号位输出0

### 测试要求

1. 提供两个精心构造的测试点，一个仅测试基础功能，一个允许测试所有功能。每个测试点需额外提供`isa.txt`说明测试点内含有哪些指令。

2. tb文件要求在以下模板基础上修改得到：
   
   ```verilog
   module ctrlTB;
       // signal definition
       reg [31:0] instr;
       reg [1:0] cmp;
       reg [11:0] ctrlOut;
       wire [23:0] addrIO;
   
       // instantiation
       CTRL uut(.instr(instr), .cmp(cmp),
                .ctrlOut(ctrlOut), .addrIO(addrIO));
   
       //excitaion
       initial begin
           #2;
           // your codes here
           // sample:
           // #4 {instr, cmp} = {32'h00000000, 2'b0};
       end
   
       // display
       always #4 $display("[%08h,%02b] => [%h,%h]",
       instr, cmp, ctrlOut, addrIO);
   endmodule
   ```
   
   \*注意每次输入改变之前需延时4个时间单位.

3. 可以使用c/c++、python等语言编写程序生成有一定强度的测试点。

4. 如果tb中使用了verilog文件读写技巧，记得将数据文件一并提交。
   
   *(vivado)数据文件放在`工程目录/工程名.sim/sim_1/behav/xsim/`目录下才能正常仿真

5. 每个测试点提供一个`coverage.txt`文件，写明你的测试点覆盖了哪些情况，与`tb.v`和其他文件一并提交，并将内容附在实验报告相关章节里。测试点强度将纳入总评，在`coverage.txt`中明确说明在这些情况下正确的电路将产生什么输出、不正确的电路将产生什么输出，不能在输出中体现的测试内容将被视作无效。
