module alu (
	input [31:0] a, b,
	input [2:0] alu_control,
	output reg [31:0] result
);
	always @(*) begin
		case (alu_control)
			3'b000: result = a + b; // ADD
			3'b001: result = a - b; // SUB
			3'b010: result = a & b; // AND
			3'b011: result = a | b; // OR
			3'b100: result = a ^ b; // XOR
			3'b101: result = a << b; // SLL
			3'b110: result = a >> b; // SRL
			3'b111: result = (a < b) ? 1 : 0; // SLT
		endcase
	end
endmodule