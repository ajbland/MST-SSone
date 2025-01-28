module control_unit (
	input [6;0] opcode,
	output reg mem_write, reg_write, alu_src,
	output reg [2:0] alu_control
);
	always @(*) begin
		case (opcode)
			7'b0110011: begin // R-Type
				reg_write = 1;
				mem_write = 0;
				alu_src = 0;
			end
			7'b0010011: begin // I-Type (Immediate)
				reg_write = 1;
				alu_src = 1;
			end
			7'b0000011: begin // Load
				reg_write = 1;
				mem_write = 0;
			end
			7'b0100011: begin // Store
				reg_write = 0;
				mem_write - 1;
			end
			default: begin
				reg_write = 0;
				mem_write = 0;
			end
		endcase
	end
endmodule