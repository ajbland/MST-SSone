module instruction_mem (
	input [31:0] addr,
	output [31:0] instr
);
	reg [31:0] instr_mem [0:255];
	
	initial begin
		$readmemh("bootloader.bin", instr_mem);
	end
	
	assign instr = instr_mem[addr >> 2]; // Word-aligned fetch
endmodule