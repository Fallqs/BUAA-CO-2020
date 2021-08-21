# IFU

本节的前两个宏定义为IFU的操作码，后两个则是与CPU有关的设置

+ $b = 3’d1$ : 对应b类指令的操作码
+ $j = 3'd2$ : 对应j类指令的操作码
+ $origin=32'h3000$ : PC起始位置
+ $delay=32'd8$ : 第0级PC 与 第 2 级(Ctrl所在流水级)PC的差值



# GRF

本节的宏定义均为寄存器编号

+ $ra=6'd31$ : 31号寄存器又名 $ra
+ $pce=6'd32$ :  特殊寄存器之一，实时更新写回的PC值，使得跳转时的写回任务变为一条move指令
+ $ext=6'd33$ : 特殊寄存器之二，实时更新16位立即数的符号扩展结果，使得$I$型指令变为$R$型指令
+ $extu=6'd34$ : 特殊寄存器之三，实时更新16位立即数的无符号扩展结果，作用与$ext$相似
+ $uext=6'd35$ : 特殊寄存器之四，实时更新16位立即数加载至高位的结果，使得$lui$指令变为一条move指令
+ $shmt=6'd36$ : 特殊寄存器之五，实时更新移位指令的偏移量，使得移位指令变为可变移位指令
+ $instr=6'd37$ : 特殊寄存器之六，实时更新当前指令内容，为支持一些奇怪的指令做准备



# ALU

都是各种操作的操作码，略



# DM

本节的宏定义是DM的操作码

+ $wd$ : short for $word$
+ $hf$ : short for $half$
+ $bt$ : short for $byte$
+ $uhf$ : short for $unsigned\ byte$
+ $ubt$ : short for $unsigned\ byte$
+ 0 : 操作码为 0 时，DM的行为被设计为等同于一根导线，这有助于简化设计



# PM

Path Manager(PM) 中的宏定义分别是五个数据产生点的编号

+ $rfm$ : 代表GRF的m号输出口

+ $alu$ : 代表ALU的z号(也是唯一的)输出口

+ $dmz$ : 代表DM的z号(也是唯一的)输出口

+ $dft$ : short for $default$，代表默认数据产生点，即GRF的 z,w 号输出口



# CMP

本节的宏定义是输出量的下标

+ $eql$ : short for $equal$，布尔量
+ $ltz$ : short for $less than zero$，布尔量

有了以上两个量，就可以组合出所有跳转条件，而以上两者的实现又及其简单



# CTRL

+ $zero=6'b0$ : 0 号寄存器的下标
+ $ifup$ : short for $IFU's\ opcode$

(我也不知道这俩宏有啥用，尬笑)
