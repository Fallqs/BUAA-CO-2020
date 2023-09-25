## HUB(Hub)

### 概览

两位同学将在本单元协作完成HUB(集线器)的设计搭建与测试。

HUB决定CPU各器件之间的连接方式，仅修改HUB的设计就可以从单周期CPU过渡到流水线CPU。HUB实现完成后，在顶层模块中例化模块，并将其他模块的对应信号连入HUB即可完成CPU搭建。禁止在HUB中实例化其他单元中实现的模块，进而把HUB魔改为顶层模块。

GRF的全部功能均为**基础功能**。

**基础功能**：接线、内置比较器.

*器件外观和测试点输出格式请与**器件外观**和**测试要求**中的模板代码保持完全一致，以免在互测阶段造成不必要的麻烦.

*关于基础功能的详细要求请仔细查阅**行为规范**.

### 器件外观

```verilog
(* keep_hierarchy = "no" *) module HUB(
    input wire [32*7-1:0]dataIn,
    output wire[32*6-1:0]dataOut,
    input wire [11:0]ctrlIn,
    output wire[12:0]ctrlOut,
    output wire[1:0]cmp,
    output wire[31:0]instrOut,
    output wire[63:0]pcOut
);
...
endmodule;
```

HUB的输入输出信号有：

1. 一对数据IO`dataIn`、`dataOut`

2. 一对控制信号IO`ctrlIn`、`ctrlOut`

3. 2位比较器输出`cmp`

4. 32位指令输出`instrOut`

5. 64位PC值输出`pcOut`

事实上，`dataIn`和`dataOut`这类超宽端口尽管能使代码简洁，却会大量消耗接线资源。所幸vivado提供了`keep_hierarchy`这一综合属性，值为`no`时综合器将进行跨端口优化，消解掉这两个端口。

### 行为规范

`assign {ifuInstr, ifuPC, grfOut0, grfOut1, grfOut2, aluOut, dmOut} = dataIn;`

`assign dataOut = {ifuIn, aluIn, dmAddr, dmIn, grfIn};`

`assign {ifuCtrl, aluCtrl, dmCtrl} = ctrlIn;`

`assign ctrlOut = {ifuEn, ifuCtrl, aluCtrl, dmCtrl};`

`assign ifuEn = 1'b1;`

### 测试要求

1. 提供一或两个精心构造的测试点。

2. tb文件要求在一下模板基础上修改得到：
   
   ```verilog
   module tb;
       // signal definition
       reg [32*7-1:0]dataIn;
       wire[32*6-1:0]dataOut;
       reg [11:0]ctrlIn;
       wire[12:0]ctrlOut;
       wire[1:0]cmp;
       wire[31:0]instrOut;
       wire[63:0]pcOut;
   
       // instantiation
       HUB uut(.dataIn(dataIn), .dataOut(dataOut),
               .ctrlIn(ctrlIn), .ctrlOut(ctrlOut),
               .cmp(cmp), .instrOut(instrOut), .pcOut(pcOut));
   
       // excitation
       initial begin
           // your codes here
       end
   
       // display
       always #1 $display("%d %h\n%h %h %h %b\n",
           $time, dataOut, ctrlOut, instrOut, pcOut, cmp);
   endmodule;
   ```

3. 可以使用c/c++、python等语言编写程序生成有一定强度的测试点。

4. 如果tb中使用了verilog文件读写技巧，记得将数据文件一并提交。
   
   *(vivado)数据文件放在`工程目录/工程名.sim/sim_1/behav/xsim/`目录下才能正常仿真

5. 每个测试点提供一个`coverage.txt`文件，写明你的测试点覆盖了哪些情况，与`tb.v`和其他文件一并提交，并将内容附在实验报告相关章节里。测试点强度将纳入总评，在`coverage.txt`中明确说明在这些情况下正确的电路将产生什么输出、不正确的电路将产生什么输出，不能在输出中体现的测试内容将被视作无效。
