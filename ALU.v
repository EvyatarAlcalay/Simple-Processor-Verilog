module ALU(
	input wire [8:0] ALUin1,	// a
	input wire [8:0] ALUin2,	// b
	input wire [1:0] sel,		// selector
	output reg [8:0] ALUout);	// output 
	
	//operations of ALU
	parameter ADD = 2'b01;
	parameter SUB = 2'b00;
	parameter ONES = 2'b10;
	
	//different parameters
	parameter ALU_DEFAULT = 9'b000000000;
	reg[3:0] i; //for ones loop
	
	//blocking assignment because of combinotoricol logic
	always @(*)
		begin
			ALUout = ALU_DEFAULT;
			case (sel)
				ADD:
				begin 
					ALUout = ALUin1 + ALUin2;
				end 
				SUB:
				begin 
					ALUout = ALUin1 - ALUin2;
				end
				ONES:
				begin
					for (i=0;i<9;i=i+1) begin
						ALUout = ALUout + ALUin2[i];
					end
				end
			endcase
		end
		
endmodule