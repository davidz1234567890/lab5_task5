`default_nettype none
module Multiplier(input logic start, reset, clock,
                  input logic [7:0] a, b,
                  
                  output logic [15:0] out,
                  output logic done,
                  output logic [1:0] ZN_flags);
logic up = 1'b1;
logic load = 1'b0;
logic [3:0] D = 4'b0;
logic en_counter, clear_counter;
logic [3:0] count;
logic load_a, load_b;
Counter #(4) count_to_8(.en(en_counter), .clear(clear_counter), 
         .load, .up,
         .D,
         .clock,
         .Q(count));
assign done = (count === 4'h8) ? 1'b1 : 1'b0;//(count == 4'd8);

logic sel, sel_a, AeqB, AgtB;
logic [15:0] b_abs;
logic [15:0] not_b;

logic [7:0] a_out, b_out;
Register #(8) a_register(.en(load_a), .clear(1'b0),
         .D(a),
         .clock,
         .Q(a_out));
Register #(8) b_register(.en(load_b), .clear(1'b0),
         .D(b),
         .clock,
         .Q(b_out));
/*MagComp #(8) determine_if_neg(.A(b),
    .B(8'd0),
    .AltB(sel), .AeqB, .AgtB);*/
assign sel = b_out[7] & 1'b1;
assign sel_a = a_out[7] & 1'b1;
logic [15:0] a_new, b_new;
assign b_new = (sel) ? {8'b1111_1111, b_out} : {8'b0000_0000, b_out};
assign a_new = (sel_a) ? {8'b1111_1111, a_out} : {8'b0000_0000, a_out};


assign not_b = ~(b_new) + 1;

Mux2to1 #(16)  select_abs_value(.I0(b_new),
    .I1(not_b),
    .S(sel),
    .Y(b_abs));

logic [15:0] not_product, product;
assign not_product = ~(product) + 1;

Mux2to1 #(16)  select_correct_product(.I0(product),
    .I1(not_product),
    .S(sel),
    .Y(out));

logic [15:0] A_shifted, B_shifted;
assign A_shifted = a_new << count;
assign B_shifted = b_abs >> count;

logic load_product, clear_product;
logic [15:0] product_in;

Register #(16) product_register(.en(load_product), .clear(clear_product),
         .D(product_in),
         .clock,
         .Q(product));
logic select_add_amount;
assign select_add_amount = B_shifted & 1'b1;
logic [15:0] num_to_add;
Mux2to1 #(16)  select_for_add(.I0(16'b0),
    .I1(A_shifted),
    .S(select_add_amount),
    .Y(num_to_add));

assign product_in = num_to_add + product;

fsm control(.start, .done, .reset, .clock, .load_a, .load_b,
          .en_counter, .clear_counter, .load_product, .clear_product);
logic not_needed;

assign ZN_flags[1] = out[15]; //Negative flag
assign ZN_flags[0] = (out == 16'd0); //zero flag

//negative bit is index 1
//zero bit is index 0

endmodule: Multiplier



module fsm(input logic start, done, reset, clock,
          output logic en_counter, clear_counter, load_product, clear_product,
          output logic load_a, load_b);
enum logic {nothing = 1'b0, in_multiply = 1'b1} State, nextState;
always_comb begin
  case(State)
    nothing: begin
      nextState = start ? in_multiply : nothing;
      load_a = start ? 1'b1 : 1'b0;
      load_b = start ? 1'b1 : 1'b0;
      en_counter = 1'b0;
      load_product = 1'b0;
      clear_counter = 1'b1;
      clear_product = 1'b1;
    end
    in_multiply: begin
      nextState = done ? nothing : in_multiply;
      en_counter = done ? 1'b0 : 1'b1;
      load_a = 1'b0;
      load_b = 1'b0;
      load_product = done ? 1'b0 : 1'b1;
      clear_counter = done ? 1'b1 : 1'b0;
      clear_product = 1'b0;//done ? 1'b1 : 1'b0;

    end

  endcase

end

always_ff @(posedge clock, posedge reset)
  if(reset)
    State <= nothing;
  else
    State <= nextState;


endmodule: fsm




module test_bench;
  logic start, reset, clock, done;
  logic [7:0] a, b;
  logic [15:0] out;
  logic [1:0] ZN_flags;
  Multiplier DUT(.start, .reset, .clock,
                  .a, .b,
                  .out,
                  .done,
                  .ZN_flags);

  initial begin
      clock = 0;
      reset = 1;
      reset <= 0;
      forever #5 clock = ~clock;
    end

    initial begin
      start <= 1'b0; a <= 8'b1111_1111; b <= 8'b0000_0001;
      @(posedge clock);
      start <= 1'b1;
      @(posedge clock);
      start <= 1'b0;
      @(posedge clock);

      @(posedge clock);


      @(posedge clock);

      @(posedge clock);

      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      start <= 1'b0; a <= 8'b1000_0000; b <= 8'b1000_0000;
      @(posedge clock);
      start <= 1'b1;
      @(posedge clock);
      start <= 1'b0;
      @(posedge clock);

      @(posedge clock);

      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      start <= 1'b0; a <= 8'b0000_0101; b <= 8'b0000_0011;
      @(posedge clock);
      start <= 1'b1;
      @(posedge clock);
      start <= 1'b0;
      @(posedge clock);

      @(posedge clock);

      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);



      start <= 1'b1; a <= 8'h3A; b <= 8'h50;
      @(posedge clock);
      start <= 1'b0;
      @(posedge clock);
      start <= 1'b0;
      @(posedge clock);

      @(posedge clock);

      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      //$finish;

    end




endmodule: test_bench



//add comment here