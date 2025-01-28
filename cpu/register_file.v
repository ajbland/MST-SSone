module register_file (
	input clk,
	input we,
	input [4:0] rs1, rs2, rd,
	input [31:0] wd,
	output [31:0] rd1, rd2
);
	reg [31:0] regs [31:0];
	
	always @(posedge clk) begin
		if (we) regs[rd] <= wd;
	end
	
	assign rd1 = regs[rs1];
	assign rd2 = regs[rs2];
endmodule