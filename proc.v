module proc (DIN, Resetn, Clock, Run, Done, BusWires); 


	//Declerations on input and outputs
	input wire [8:0] DIN;
	input wire Resetn, Clock, Run;
	output reg Done;
	output wire [8:0] BusWires;

	//Declerations on the time steps
	parameter T0 = 2'b00;
	parameter T1 = 2'b01;
	parameter T2 = 2'b10;
	parameter T3 = 2'b11;

	// opcode parameters
	parameter MV = 3'b000;
	parameter MVI = 3'b001;
	parameter ADD = 3'b010;
	parameter SUB = 3'b011;
	parameter ONES = 3'b100;
				
	// necessary wires
	wire [2:0] I;	                               //3-bit instruction
	wire [8:0] IR;	                               //IR input
	wire [7:0] Xreg;	                            //the content which enter to the Xreg
	wire [7:0] Yreg;	                            //the content which enter to the Yreg
	wire [8:0] Aout_bus;	                         // output of reg A
	wire [8:0] Gout_bus;	                         // output of reg G
	wire [8:0] R0, R1, R2, R3, R4, R5, R6, R7;	 // the content of R0-R7 
	wire [8:0] ALUout;	                         // add/subtract output 

	// necessary regs
	reg [1:0] Tstep_Q;	// cs
	reg [1:0] Tstep_D;	// ns 
	reg IRin, Gin, Ain;  //control for regs IR, G, A
	reg [1:0] AddSub;	   // ALU Selector
	reg Gout, DINout;		// enable regs G, Din 
	reg [7:0] Rin;		   // R0-R7 input enable
	reg [7:0] Rout;	   // R0-R7 output enable 

	// decode input to IR
	assign I = IR[8:6];
	dec3to8 decX (IR[5:3], 1'b1, Xreg); 
	dec3to8 decY (IR[2:0], 1'b1, Yreg);

	// Control FSM state table
	always @(*)
		begin 
			case (Tstep_Q)
				T0: begin 
					if (!Run)
						Tstep_D <= T0;
					else
						Tstep_D <= T1;
				end 
				T1: begin 
					if (Done)
						Tstep_D <= T0; 
					else
						Tstep_D <= T2;
				end
				T2: begin
					if (Done)
						Tstep_D <= T0; 
					else
						Tstep_D <= T3;
				end 
				T3: begin 
					Tstep_D <= T0;
				end 
				default: Tstep_D <= T0;
			endcase
		end

		
	// Control FSM outputs
	always @(*)
		begin 
		//specify initial values 
		IRin <= 1'b0;	
		Gin <= 1'b0;
		Ain <= 1'b0;
		Done <= 1'b0;
		Rin <= 8'b0;
		Gout <= 1'b0;
		DINout <= 1'b0;
		Rout <= 8'b0;
			case (Tstep_Q) 	// caase cs
				T0: // store DIN in IR in time step 0 
					begin  
						IRin <= 1'b1;	// enable reg IR 
					end
				T1: //define signals in time step 1
					case(I)
						MV:
							begin
								Rin <= Xreg;	// read reg X
								Rout <= Yreg;	// write reg Y
								Done <= 1'b1;	// enable Done
							end 
						MVI:
							begin
								Rin <= Xreg;	// write reg X
								DINout <= 1'b1;// enable DINout
								Done <= 1'b1;	// enable Done 
							end
						ADD:
							begin 
								Rout <= Xreg;	// read reg X
								Ain <= 1'b1;	// enable reg A
							end 
						SUB:
							begin 
								Rout <= Xreg;	// read reg X
								Ain <= 1'b1;	// enable reg A
							end 
						ONES:
							begin 
								Rout <= Xreg;	// read reg X
								Gin <= 1'b1;	// enable reg A
								AddSub <= 2'b10; //enable smult operation in alu
							end 
					endcase		
				T2:	// second cycle
					case(I)
						ADD:
							begin 
								Rout <= Yreg;	// read from reg Y
								Gin <= 1'b1;	// enable reg G
								AddSub <= 2'b01;	// selector for add
							end 
						SUB:
							begin 
								Rout <= Yreg;	// read from reg Y
								Gin <= 1'b1;	// enable reg G in
								AddSub <= 2'b00;	// selector for subtract
							end 
						ONES:
							begin 
								Gout <= 1'b1;
								Rin <= Yreg;	// enable selector
								Done <= 1'b1;
							end 
					endcase				
				T3: 
					case(I)
						ADD:
							begin 
								Gout <= 1'b1;	// enable reg G out 
								Rin <= Xreg;	// write to reg X
								Done <= 1'b1;	// enable Done
							end 
						SUB:
							begin 
								Gout <= 1'b1;
								Rin <= Xreg;
								Done <= 1'b1;
							end 
					endcase		
			endcase
		end

		
	// Control FSM flip-flops 
	always @(posedge Clock, negedge Resetn)
		begin 
			if (!Resetn)
				Tstep_Q <= T0;
			else	
				Tstep_Q <= Tstep_D;
		end

	//instantiate other registers and the adder/subtractor unit
	regn reg_0 (BusWires, Rin[0], Clock, Resetn,  R0);
	regn reg_1 (BusWires, Rin[1], Clock, Resetn,  R1);
	regn reg_2 (BusWires, Rin[2], Clock, Resetn,  R2);
	regn reg_3 (BusWires, Rin[3], Clock, Resetn,  R3);
	regn reg_4 (BusWires, Rin[4], Clock, Resetn,  R4);
	regn reg_5 (BusWires, Rin[5], Clock, Resetn,  R5);
	regn reg_6 (BusWires, Rin[6], Clock, Resetn,  R6);
	regn reg_7 (BusWires, Rin[7], Clock, Resetn,  R7);

	//instantiate registers for ALU
	regn reg_A (BusWires, Ain, Clock, Resetn, Aout_bus);
	regn reg_G (ALUout, Gin, Clock, Resetn, Gout_bus);
	
	////the IR Register
	regn reg_IR (DIN, IRin, Clock, Resetn, IR);

	////added for debug:
	//output wire [1:0] Tstep_Q_debug;	// cs
	//output wire [8:0] reg_0_debug, reg_1_debug, reg_2_debug;
	//assign Tstep_Q_debug = Tstep_Q;
	//assign reg_0_debug = R0;
	//assign reg_1_debug = R1;
	//assign reg_2_debug = R2;

	// mux instantiation 
	mux mux_inst(.R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7), .DIN(DIN), .Gout_bus(Gout_bus),
	.Rout(Rout), .Gout(Gout), .DINout(DINout), .mux_reg(BusWires));	

	// ALU for Add Sub and SMULT
	ALU ALU_inst(.ALUin1(Aout_bus), .ALUin2(BusWires), .sel(AddSub), .ALUout(ALUout));
 
endmodule
