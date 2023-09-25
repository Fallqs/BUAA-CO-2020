## DM(Data Memory)

### 概览

两位同学将在本单元协作完成DM的设计搭建与测试。

DM是数据存储单元，可以简单理解为CPU的运行内存。不过准确地说，DM和IFU中的指令存储单元都是整个体系结构中L1 cache (发音同cash) 的一部分。

在我们的CPU中，DM大小为12KB，地址空间为0x0000~0x2fff。支持按字、半字、字节共三种写入模式；按字、半字、字节、无符号半字、无符号字节读出共五种读取模式。拥有一个32位地址线、一个32位数据输入口、一个32位数据输出口以及控制、时钟、复位信号口。

DM的功能分为**基础功能**和**扩展功能**两部分，只实现**基础功能**即可通过课程，但总评将受影响。

**基础功能**：DM的12KB存储空间内任意位置的按字读写；测试用控制台输出.

**扩展功能**：DM的12KB存储空间内任意位置的按半字、字节读写和按无符号半字、无符号字节读.

\*器件外观和测试点输出格式请与**器件外观**和**测试要求**中的模板代码保持完全一致，以免在互测阶段造成不必要的麻烦.

\*关于基础功能和扩展功能的详细要求请仔细查阅**行为规范**.

### 器件外观

```verilog
module DM(
    input wire [3:0]ctrlIn,
    input wire clk, rst,
    input wire [31:0]addrIO,
    input wire [31:0]dataIn,
    output wire [31:0]dataOut,
    input wire [31:0]curPC  // only for test
);
...
endmodule
```

DM的输入输出信号有：

1. 来自控制器的4位控制信号`ctrlIn`。其中，`ctrl[3]`为写使能`writeEn`（高电平写低电平读），`ctrl[2:0]`为读写方式`ioType`（按字、半字、字节读写）。模块内部可使用`assign {writeEn, ioType} = ctrlIn;`获得这两个信号。
2. 时钟信号`clk`和复位信号`rst`（高电平有效，同步复位）。
3. 32位地址信号`addrIO`。其中，高30位是`addrWord`指示整字地址，低两位是`addrByte`指示字内部的字节偏移。
4. 32位写入数据信号`dataIn`和32位读出信号`dataOut`。
5. 仅供最终CPU运行测试的32位额外输入信号`curPC`。在CPU运行期间，每个时钟周期都会有一条指令的执行流经过DM，`curPC`的内容是这个指令的`PC`值。

### 行为规范

除器件外观包含的信号外，DM内部还应有一个大小为12KB的存储空间，其基地址为0，不妨约定其结构为

```verilog
(* ram_style="block" *) reg [31:0]mem[0:32'h0xbff];
```

**下面定义行为规范：**

1. 采用大端编址，可用`mem[addrWord][8*addrByte+:8]`访问一组addrWord, addrByte所唯一确定的字节。 

2. 复位方式为同步复位，复位完成时要求mem中每个二进制位均处于低电平。

3. 地址对齐
   
   在一个设计完善的CPU中访问DM时需注意地址对齐：按字访问DM时，地址必须是4的倍数(低两位为0)；按半字访问DM时，地址必须是2的倍数。否则，CPU应当发出地址异常信号。然而这在完整的异常检测和中断响应机制之下才有意义，而这对我们的课程来说过于奢侈了。考虑到这一点，同学们只需了解地址对齐的概念即可。
   
   我们的课程中，要求DM在按字访问时忽略地址后两位，不论后两位取值如何都将其看作0；要求DM在按半字访问时忽略地址末位，不论其取值如何都看作0。提出这个要求是为了便于同学们构造测试点，下面给出更精确的要求。

4. 读出
   
   `dataOut`的取值只受`ioType`控制，与`writeEn`、`clk`、`rst`无关。`dataOut`的取值按照下表计算：
   
   | ioType | dataOut                                  | 含义          |
   | ------ | ---------------------------------------- | ----------- |
   | 0, >=6 | dataIn                                   | 将dataIn原样输出 |
   | 1      | mem[addrWord]                            | 按字取数        |
   | 2      | 将mem[addrWord]中addrByte所处在的半字[符号扩展]至32位  | 取半字         |
   | 3      | 将mem[addrWord]中addrByte所指示的字节[符号扩展]至32位  | 取字节         |
   | 4      | 将mem[addrWord]中addrByte所处在的半字[无符号扩展]至32位 | 无符号取半字      |
   | 5      | 将mem[addrWord]中addrByte所指示的字节[无符号扩展]至32位 | 无符号取字节      |
   
   \*表中出现的数字均为10进制.

5. 写入
   
   当且仅当`clk`处于上升沿、`rst`处于低电平且`writeEn`处于高电平时执行写入动作。写入动作按照下表执行：
   
   | ioType | 动作                                           | 含义  |
   | ------ | -------------------------------------------- | --- |
   | 0, >=4 | mem[addrWord] <-- mem[addrWord]              | 写原值 |
   | 1      | mem[addrWord] <-- dataIn                     | 写整字 |
   | 2      | mem[addrWord]中addrByte所处在的半字 <-- dataIn的低16位 | 写半字 |
   | 3      | mem[addrWord]中addrByte所指示的字节 <-- dataIn的低8位  | 写字节 |
   
   \*表中出现的数字均为10进制.

6. 控制台输出
   
   当且仅当执行写入动作时向控制台打印信息。要求按照如下格式打印信息：
   
   ```verilog
   $display("%0d@%h: *%h <= %h", $time, curPC, {addrWord, 2'b0}, result);
   ```
   
   其中，`result`为本次写入的对象`mem[addrWord]`在写入完成时的内容。

### 测试要求

1. 提供两个精心构造的测试点，一个仅测试基础功能，一个允许测试所有功能但须覆盖扩展功能。

2. tb文件要求在以下模板基础上修改得到：
   
   ```verilog
   module dmTB;
       // signal definition
       reg [3:0]ctrlIn;
       reg clk, rst;
       reg [31:0]addrIn;
       reg [31:0]dataIn;
       wire[31:0]dataOut;
       reg [31:0]curPC;
   
       // instantiation
       DM uut(.ctrlIn(ctrlIn), .clk(clk), .rst(rst),
              .addrIn(addrIn), .dataIn(dataIn), .dataOut(dataOut),
              .curPC(curPC));
   
       // excitaion
       always #4 clk<=~clk;
       initial begin
           // reset at the very beginning
           {clk, rst} = 2'b01;
           #10 rst = 0;
           // your codes here
       end
   
       // display
       always #2 $display("%0d@%h: *%h::%h<%0d>%h", 
       $time, curPC, addrIn, dataIn, ctrlIn, dataOut);
   endmodule
   ```

3. 可以使用c/c++、python等语言编写程序生成有一定强度的测试点。

4. 如果tb中使用了verilog文件读写技巧，记得将数据文件一并提交。
   
   \*(vivado)数据文件放在`工程目录/工程名.sim/sim_1/behav/xsim/`目录下才能正常仿真

5. 每个测试点提供一个`coverage.txt`文件，写明你的测试点覆盖了哪些情况，与`tb.v`和其他文件一并提交，并将内容附在实验报告相关章节里。测试点强度将纳入总评，在`coverage.txt`中明确说明在这些情况下正确的电路将产生什么输出、不正确的电路将产生什么输出，不能在输出中体现的测试内容将被视作无效。
