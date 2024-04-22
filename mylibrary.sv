`default_nettype none

module Decoder
    #(parameter WIDTH = 16)
    (
    input logic [$clog2(WIDTH)-1:0] I,
    input logic en,
    output logic [WIDTH-1:0] D);
      always_comb begin
        if (en == 0) begin
            D = '0;
        end
        else begin
            
            D = '0;
            D[I] = 1;
        end
      end
    endmodule: Decoder

    module BarrelShifter
    #(parameter WIDTH = 8)
    (input logic [2**WIDTH-1:0] V,
    input logic [WIDTH-1:0] by,
    output logic [2**WIDTH-1:0] S);
      always_comb begin
        
        assign S = V << by;
      end
    endmodule: BarrelShifter

    module Multiplexer
    #(parameter WIDTH = 32)
    (input logic [WIDTH-1:0] I,
    input logic [$clog2(WIDTH)-1:0] S,
    output logic Y);
      always_comb begin
        
        assign Y = '0;
        assign Y = I[S];
      end
    endmodule: Multiplexer

    module Mux2to1
        #(parameter WIDTH = 3)
    (input logic [WIDTH-1:0] I0,
    input logic [WIDTH-1:0] I1,
    input logic S,
    output logic [WIDTH-1:0] Y);
      
      assign Y = (S) ? I1 : I0;
    endmodule: Mux2to1

    module MagComp
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    output logic AltB, AeqB, AgtB);
      

      assign AeqB = (A == B);
      assign AgtB = (A > B);
      assign AltB = (A < B);
    endmodule: MagComp

    module Comparator
    #(parameter WIDTH = 8)
    (input logic [WIDTH-1:0] A,
    input logic [WIDTH-1:0] B,
    output logic AeqB);
      assign AeqB = (A == B);
    endmodule: Comparator


    module Adder
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0] A, input logic [WIDTH-1:0] B,
    input logic cin, output logic cout, output logic [WIDTH-1:0] sum);
      assign {cout, sum} = A+B+cin;


    endmodule: Adder



    module Subtracter
    #(parameter WIDTH = 16)
    (input logic [WIDTH-1:0] A, input logic [WIDTH-1:0] B,
    input logic bin, output logic bout, output logic [WIDTH-1:0] diff);
      assign {bout, diff} = A-B-bin;
    endmodule: Subtracter





  module DFlipFlop
    (input logic D, clock, reset_L, preset_L,
      output logic Q);
    always_ff @(posedge clock, negedge reset_L, negedge preset_L)
    if (~reset_L & ~preset_L)
      Q <= 1'bX;
    
    else if (~reset_L & preset_L)
        Q <= 0;
    else if (reset_L & ~preset_L)
        Q <= 1;
    else
        Q <= D;
    endmodule: DFlipFlop

  

    module Register
        #(parameter WIDTH=32)
        (input logic en, clear,
         input logic [WIDTH-1:0] D,
          input logic clock,
         output logic [WIDTH-1:0] Q);
         
        always_ff @(posedge clock)
          if (en)
            Q <= D;
          else if (clear)
            Q <= '0;
            
      endmodule : Register



      module Counter
        #(parameter WIDTH=32)
        (input logic en, clear, load, up,
         input logic [WIDTH-1:0] D,
         input  logic clock,
         output logic [WIDTH-1:0] Q);
         
        always_ff @(posedge clock)
          if (clear)
            Q <= '0;
          else if (load)
            Q <= D;
            // If en & up, count up
          else if (en & up)
            Q <= Q + 1;
        // Else if en & ~up, count down
          else if (en & ~up)
            Q <= Q - 1;
              
      endmodule : Counter



      module Synchronizer
        (input logic async, clock,
         output logic sync);
        logic preset_L, reset_L;
        logic ff_buf;
        // Synchronize the signal by running it through 
        //two flip-flops (buffering)
        
        assign preset_L = 1'b1; //not asserted
        assign reset_L = 1'b1; //not asserted
        DFlipFlop dut1(.D(async),.Q(ff_buf), .clock,.preset_L,.reset_L);
        DFlipFlop dut2(.D(ff_buf),.Q(sync),.clock,.preset_L, .reset_L);
    
    endmodule: Synchronizer



    module ShiftRegisterSIPO
        #(parameter WIDTH=32)
        (input  logic en, left, serial,clock,
         output logic [WIDTH-1:0] Q);
         
        always_ff @(posedge clock)
          if (en & left)
            Q <= {Q[WIDTH-2:0], serial};
          else if(en & ~left)
            Q <= {serial, Q[WIDTH-1:1]};
              
      endmodule : ShiftRegisterSIPO



      module ShiftRegisterPIPO
        #(parameter WIDTH=16)
        (input logic en, left, load, 
        input  logic [WIDTH-1:0] D,
        input logic clock,
         output logic [WIDTH-1:0] Q);
         
        always_ff @(posedge clock)
          if (load)
            Q <= D;
          else if (en & left)
            Q <= {Q[WIDTH-2:0], 1'b0};
          else if (en & ~left)
            Q <= {1'b0, Q[WIDTH-1:1]};
              
      endmodule : ShiftRegisterPIPO



      module BarrelShiftRegister
        #(parameter WIDTH=32)
        (input logic en, load,
        input logic [1:0] by,
         input logic [WIDTH-1:0] D,
         input  logic clock,
         output logic [WIDTH-1:0] Q);
         
        
        always_ff @(posedge clock)
          if (load)
              Q <= D;
          else if (en)
              Q <= (Q << by);
          
      endmodule : BarrelShiftRegister
      
		
		module Mux4to1
        #(parameter WIDTH = 3)
    (input logic [WIDTH-1:0] I0,
    input logic [WIDTH-1:0] I1,
	 input logic [WIDTH-1:0] I2,
    input logic [WIDTH-1:0] I3,
    input logic [1:0] S,
    output logic [WIDTH-1:0] Y);
      always_comb begin
		  case(S) 
		    2'b00: Y = I0;
			 2'b01: Y = I1;
			 2'b10: Y = I2;
			 2'b11: Y = I3;		  
		  endcase
		end
    endmodule: Mux4to1