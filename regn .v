module regn(R, Rin, Clock, Resetn, Q);

	//decleration on input and output
	input [n-1:0] R;      //wire. the date which enter to the register
	input Rin;            //enable bit which come from the multiplexer
	input Clock;          //clock of the system
	input Resetn;         //reset (Active Low)
	output reg [n-1:0] Q; //the content of the register
	
	//decleration on parameterss
	parameter n = 9;
	
	//logic
	always @(posedge Clock)
		if (~Resetn)
			Q <= 0;
		else if (Rin)
			Q <= R;
			
endmodule
