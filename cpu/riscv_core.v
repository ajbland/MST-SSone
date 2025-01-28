module riscv_core (
	input clk, reset
);
	wire [31:0] instr, pc, alu_result, rd1, rd2, write_data;
	wire mem_write, reg_write, alu_src;
	wire [2:0] alu_control;
	
	// Program Counter
	reg [31:0] pc_reg;
	always @(posedge clk or posedge reset) begin
		if (reset)
			pc_reg <= 0;
		else
			pc_reg <= pc_reg + 4;
	end
	
	instruction_mem IM(.addr(pc_reg), .instr(instr));
	register_file RF(.clk(clk), .we(reg_write), .rs1(instr[19:15]),
					 .rs2(instr[24:20]), .rd(instr[11:7]),
					 .wd(alu_result), .rd1(rd1), .rd2(rd2));
	alu ALU(.a(rd1), .b(rd2), .alu_control(alu_control), .result(alu_result));
	control_unit CU(.opcode(instr[6:0]), .mem_write(mem_write), .reg_write(reg_write), .alu_src(alu_src), .alu_control(alu_control));
endmodule