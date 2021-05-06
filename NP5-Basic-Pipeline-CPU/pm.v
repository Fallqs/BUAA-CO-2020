`include "def.v"
module pm(input wire[32*7-1:0]I,output wire[32*6-1:0]O,input wire[6*4-1:0]tag,
		  output wire[32*3-1:0]Instr,output wire[32*3-1:0]PC,
		  input wire[12:0]opI,output wire[19:0]opO,output wire[1:0]b,
		  input wire clk,rst);
	//Tag
	wire[5:0]az;wire[5:0]aw;wire[5:0]am;wire[5:0]ax;
	assign {az,aw,am,ax} = tag;
	//Line&ID
	parameter [0:15]su=16'h0230; wire stall; reg[5:0]id[0:3];reg[1:0]line[0:3];
	wire[2:0]ifup;wire[5:0]alup;wire[2:0]dmp;wire dme;
	assign {ifup,alup,dmp,dme} = opI;
	always@(*) {id[0],line[0]} = {ax,stall?`rfm:(alup&&!dmp)?`alu:dmp?`dmz:`rfm};
	//Address
	reg[4:0]falux[0:1]; reg[4:0]faluy[0:1]; reg[4:0]fdmx[0:2]; reg[4:0]fcmpx; reg[4:0]fcmpy; reg[4:0]frfz;
	always@(*)begin
		falux[0] <= (!az)?{3'd1,`dft}:(az==id[1])?{3'd2,line[1]}:(az==id[2])?{3'd3,line[2]}:(az==id[3])?{3'd4,line[3]}:{3'd1,`dft};
		faluy[0] <= (!aw)?{3'd1,`dft}:(aw==id[1])?{3'd2,line[1]}:(aw==id[2])?{3'd3,line[2]}:(aw==id[3])?{3'd4,line[3]}:{3'd1,`dft};
		fdmx [0] <= (!am)?{3'd2,`rfm}:(am==id[1])?{3'd3,line[1]}:(am==id[2])?{3'd4,line[2]}:(am==id[3])?{3'd5,line[3]}:{3'd2,`rfm};
		frfz	 <= (!az)?{3'd0,`dft}:(az==id[1])?{3'd1,line[1]}:(az==id[2])?{3'd2,line[2]}:(az==id[3])?{3'd3,line[3]}:{3'd0,`dft};
		fcmpx	 <= (!aw)?{3'd0,`dft}:(aw==id[1])?{3'd1,line[1]}:(aw==id[2])?{3'd2,line[2]}:(aw==id[3])?{3'd3,line[3]}:{3'd0,`dft};
		fcmpy	 <= (!am)?{3'd0,`rfm}:(am==id[1])?{3'd1,line[1]}:(am==id[2])?{3'd2,line[2]}:(am==id[3])?{3'd3,line[3]}:{3'd0,`rfm};
	end
	always@(posedge clk)begin
		if(rst) {falux[1],faluy[1],fdmx[2],fdmx[1]}<=20'b0;
		else {falux[1],faluy[1],fdmx[2],fdmx[1]} <= {falux[0],faluy[0],fdmx[1],fdmx[0]};
	end

	assign stall = (falux[0][4:2]<su[{falux[0][1:0],2'b0}+:4]) || (faluy[0][4:2]<su[{faluy[0][1:0],2'b0}+:4])
				|| (fcmpx[4:2]<su[{fcmpx[1:0],2'b0}+:4]) || (fcmpy[4:2]<su[{fcmpy[1:0],2'b0}+:4])
				|| (fdmx[0][4:2]<su[{fdmx[0][1:0],2'b0}+:4]) || (frfz[4:2]<su[{frfz[1:0],2'b0}+:4]);

	reg[31:0]instrp; reg[31:0]instr[0:3]; reg[31:0]pcp; reg[31:0]pc[0:3];
	reg [31:0]rfz[0:1]; reg [31:0]rfw[0:1]; reg [31:0]dmz;
	reg [31:0]bus[0:1][0:7]; reg[12:0]ops[1:3];

	always@(*){instrp,pcp,rfz[0],rfw[0],bus[`rfm][0],bus[`alu][1],dmz}=I;

	initial begin {ops[3],ops[2],ops[1]}<={18'b0,18'b0,18'b0};
			{line[3],line[2],line[1]}<=6'b0; {id[3],id[2],id[1]}<=18'b0; end
	always@(posedge clk)begin
		if(rst)begin
			{ops[3],ops[2],ops[1]}<={18'b0,18'b0,18'b0};
			{line[3],line[2],line[1]}<=6'b0; {id[3],id[2],id[1]}<=18'b0;
		end
		else begin
			{instr[3],instr[2],instr[1],instr[0]} <= {instr[2],instr[1],instr[0],stall?instr[0]:instrp};
			{   pc[3],   pc[2],   pc[1],   pc[0]} <= {   pc[2],   pc[1],   pc[0],stall?   pc[0]:   pcp};
			{bus[`rfm][7],bus[`rfm][6],bus[`rfm][5],bus[`rfm][4],bus[`rfm][3],bus[`rfm][2],bus[`rfm][1]} <=
			{bus[`rfm][6],bus[`rfm][5],bus[`rfm][4],bus[`rfm][3],    dmz     ,bus[`rfm][1],stall?31'b0:bus[`rfm][0]};
			{bus[`alu][7],bus[`alu][6],bus[`alu][5],bus[`alu][4],bus[`alu][3],bus[`alu][2]} <=
			{bus[`alu][6],bus[`alu][5],bus[`alu][4],bus[`alu][3],bus[`alu][2],bus[`alu][1]};
			{rfz[1],rfw[1]}<={rfz[0],rfw[0]};
			{ops[3],ops[2],ops[1]}<={ops[2],ops[1],stall?13'b0:opI};
			{line[3],line[2],line[1]}<={line[2],line[1],line[0]};
			{id[3],id[2],id[1]}<={id[2],id[1],stall?6'b0:id[0]};
		end
	end

	wire[31:0]alux;wire[31:0]aluy;wire[31:0]cmpx;wire[31:0]cmpy;
	wire[31:0]dmax;wire[31:0]dmx; wire[31:0]rfx; wire[31:0]ifum;
	assign alux = (falux[1][1:0]==`dft)?rfz[1]:bus[falux[1][0]][falux[1][4:2]];
	assign aluy = (faluy[1][1:0]==`dft)?rfw[1]:bus[faluy[1][0]][faluy[1][4:2]];
	assign ifum = ( frfz[1:0]==`dft)?rfz[0]:bus[frfz[0]][frfz[4:2]];
	assign cmpx = (fcmpx[1:0]==`dft)?rfw[0]:bus[fcmpx[0]][fcmpx[4:2]];
	assign cmpy = bus[fcmpy[0]][fcmpy[4:2]];
	assign dmx  = bus[fdmx[2][0]][fdmx[2][4:2]];
	assign {dmax,rfx} = {bus[`alu][2],bus[line[3][0]][3]};
	
	assign {b[`eql],b[`ltz]} = {cmpx==cmpy,cmpx[31]};
	assign O = {ifum,alux,aluy,dmax,dmx,rfx};
	assign {Instr,PC} = {instr[0],instr[2],instr[3],pc[0],pc[2],pc[3]};
	assign opO = {~stall,opI[12:10],ops[1][9:4],ops[2][3:0],id[3]};

endmodule
