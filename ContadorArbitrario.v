module BiestableJK(output reg Q, output wire nQ, input wire J, input wire K, input wire C);
  not(nQ,Q);
  initial
  begin
    Q=0;
  end
  always @(posedge C)
    case ({J,K})
      2'b10: Q=1;
      2'b01: Q=0;
      2'b11: Q=~Q;
    endcase
endmodule

module ContadorArbitrario(output wire [3:0]Q, input wire C);
  wire[3:0]nQ;
  wire J3, J3a, J3b, J2, J2a;

	// Puertas logicas para J3
  and (J3a, nQ[1], nQ[2]);
  and (J3b, nQ[2], Q[0]);
  or (J3, J3a, J3b);

	// Puertas logicas para J2
  and(J2a, nQ[3], nQ[0]);
  or(J2, J2a, Q[1]);
	
	// Puertas logicas para K2
  and(K2a, Q[3], nQ[1]);
  and(K2b, Q[1], nQ[3]);
  or(K2, K2a, K2b, Q[0]);

	// Puertas logicas para J1
  and(J1a, nQ[0], Q[2]);
  or(J1, J1a, Q[3]);

	// Puertas logicas para J0
  and(J0a, nQ[1], Q[2], Q[3]);
  and(J0b, nQ[3], Q[1]);
  or(J0, J0a, J0b);

  BiestableJK JK3(Q[3], nQ[3], J3, 1'b1, C); //Aquí introducimos un 1 en K3
  BiestableJK JK2(Q[2], nQ[2], J2, K2, C);
  BiestableJK JK1(Q[1], nQ[1], J1, nQ[0], C); //Aquí introducimos nQ[0] para K1
  BiestableJK JK0(Q[0], nQ[0], J0, 1'b1, C); //Aquí introducimos un 1 en K0

endmodule

module Transformador(input wire [3:0]Q, output wire [3:0] O);
	
	wire nq3, nq2, nq1, nq0;	
	wire a1s,a2s,a3s,a4s,a5s,a6s,a7s;
	wire O2, O1, O0;	

	// Aquí declaramos puertas not para obtener entradas negadas en el conversor
	not(nq3,Q[3]);
	not(nq2,Q[2]);
	not(nq1,Q[1]);
	not(nq0,Q[0]);
	
	// A cada entrada O le asignamos su salida con distintas puertas que hemos implementado

	assign O[3] = Q[3];

	and(a1s,Q[1],nq0,nq3);
	or(O[2], Q[2], a1s);

	and(a2s,Q[1],nq3);
	and(a3s,Q[1],nq2);
	and(a4s,Q[1],Q[0]);
	or(O[1], a2s, a3s, a4s);

	and(a5s,Q[0],nq2);
	and(a6s,Q[0],Q[3]); 
	and(a7s,Q[1],Q[0]);
	or(O[0], a5s, a6s, a7s);
	
endmodule

module Test;
	reg C;
	wire [3:0]Q;
	wire[3:0]O;

	ContadorArbitrario CA(Q,C);
	Transformador Transf(Q,O);

	always #10 C=~C;
	initial
	 begin
		$dumpfile("salida.dmp");
		$dumpvars(2, CA, Transf);
		$dumpon;
		$monitor($time," C: %b , Q: %b (%d) || O: %b (%d)" ,C, Q, Q, O,O);
		C=1;
		#250;

		$dumpoff;
		$finish;
	end

endmodule
