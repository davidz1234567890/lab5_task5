/*
 * File: datapath.v
 * Created: 4/5/1998
 * Modules contained: datapath
 *
 * Changelog:
 * 23 Oct 2009: Separated paths.v into datapath.v and controlpath.v
 * 17 Nov 2009: Minor updates to facilitate synthesis (mcbender)
 * 13 Oct 2010: Updated always to always_comb and always_ff.Renamed to.sv(abeera)
 * 17 Oct 2010: Updated to use enums instead of define's (iclanton)
 * 24 Oct 2010: Updated to use stuct (abeera)
 * 9  Nov 2010: Slightly modified variable names (abeera)
 * 25 Apr 2013: Changed newMDR to tri (mromanko)
 * 8  Mar 2019: Changed to fit RISC240 spec (pbannai)
 * 4  Nov 2019: Changed MDR to fit Altera IP block (mgcai)
 */

`include "constants.sv"

/*
 * module datapath
 *
 * This is the datapath for the RISC240.  Modules are instantiated and
 * connected.
 */
module datapath (
   output [15:0] ir,
   output [3:0]  condCodes,
   output [15:0] aluSrcA,
   output [15:0] aluSrcB,
   output [127:0] viewReg, //register for viewing in debugging
   output [15:0] result, //changed from aluResult, to result
   output [15:0] pc,
   output [15:0] memAddr,
   output [15:0] MDRout,  // output of datapath just for viewing
   inout  [15:0] dataBus,
   output [2:0]  selRD,
   output [2:0]  selRS1,
   output [2:0]  selRS2,
   input start, //new code here
  output [15:0] output_multiply,
  output [7:0] newA, newB,
   output done, //new code here
	
	
	output [15:0] for_ledg15_0,
	input [17:0] SW,
	
	
   input controlPts  cPts,
   input         clock,
   input         reset_L);
   
   logic [15:0] regRS1, regRS2, aluResult;
   logic [15:0] memOut;
   logic [14:0] marOut;
   logic [3:0]  newCC;
   logic loadReg_L, loadPC_L, loadMDR_L, writeMD_L, loadMAR_L, loadIR_L;
   tri   [15:0] newMDR;

   // Assign wires
   assign loadMDR_L = writeMD_L & cPts.re_L;
   assign selRD  = ir[8:6];
   assign selRS1 = ir[5:3];
   assign selRS2 = ir[2:0];

   assign memAddr = {marOut, 1'b0};

   // Instantiate the modules that we need:
   reg_file rfile(
           .outRS1(regRS1),
           .outRS2(regRS2),
           .outView(viewReg),
           .in(result), //changed
           .selRD,
           .selRS1,
           .selRS2,
           .clock,
           .reset_L,
           .load_L(loadReg_L));

   tridrive #(.WIDTH(16)) a(.data(result), .bus(newMDR), .en_L(writeMD_L)), //changed
                          b(.data(dataBus), .bus(newMDR), .en_L(cPts.re_L)),
                          c(.data(MDRout), .bus(dataBus), .en_L(cPts.we_L));

   aluMux #(.WIDTH(16)) MuxA(.inA(regRS1),
                             .inB(pc),
                             .inC(MDRout),
                             .out(aluSrcA),
                             .sel(cPts.srcA)),
                        MuxB(.inA(regRS2),
                             .inB(pc),
                             .inC(MDRout),
                             .out(aluSrcB),
                             .sel(cPts.srcB));

   alu alu_dp(.out(aluResult), .condCodes(newCC), .inA(aluSrcA), .inB(aluSrcB),
              .opcode(cPts.alu_op));

   logic [7:0] dest_out;
   decoder #(8) reg_load_decoder(.I(cPts.dest),
                                 .en(1'b1),
                                 .D(dest_out));
											
					/*logic [7:0] Y1, Y2;						
	 Mux2to1 #(8) control_switch1(.I0(newMDR),
    .I1(SW[7:0],
    .S(memAddr == 16'h0310),
    .Y(Y1));
	 Mux2to1 #(8) control_switch2(.I0(newMDR),
    .I1(SW[15:8],
    .S(memAddr == 16'h0312),
    .Y(Y2));*/
	 logic [7:0] Y1, Y2;
	 logic [1:0] sel;
	 assign sel[0] = (memAddr == 16'h0312);
	 assign sel[1] = (memAddr == 16'h0310);
	 
	 
logic [15:0] upper, lower;
assign lower = (SW[7] & 1'b1) ? {8'b1111_1111, SW[7:0]} : {8'b0000_0000, SW[7:0]};
assign upper = (SW[15] & 1'b1) ? {8'b1111_1111, SW[15:8]} : {8'b0000_0000, SW[15:8]};
	 
	 Mux4to1
        #(8)
    select_switches(.I0(newMDR),
    .I1(upper),
	 .I2(lower),
    .I3(Y1),
    .S(sel),
    .Y(Y2));
											
											
											
											

   assign {loadIR_L, loadMAR_L, writeMD_L, loadPC_L, loadReg_L} = dest_out[4:0];
   logic [3:0] CC_good;
   register #(.WIDTH(16)) memDataReg(.out(MDRout), .in(Y2/*newMDR*/), .load_L(loadMDR_L),
                                     .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) pcReg(     .out(pc), .in(result), .load_L(loadPC_L),
                                     .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(15)) memAddrReg(.out(marOut), .in(result[15:1]), .load_L(loadMAR_L),
                                     .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) instrReg(  .out(ir), .in(result), .load_L(loadIR_L),
                                     .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(4)) condCodeReg(.out(condCodes), .in(CC_good), .load_L(cPts.lcc_L),
                                     .clock(clock), .reset_L(reset_L));
   
   //logic [15:0] output_multiply;
   logic [1:0] flags;
   //logic [7:0] newA, newB;
   assign newA = aluSrcA[7:0];
   assign newB = aluSrcB[7:0];
   Multiplier DUT_multiply(.start, .reset(~reset_L), .clock,
                  .a(newA), .b(newB),
                  .out(output_multiply),
                  .done,
                  .ZN_flags(flags));
   
   Mux2to1 #(16)
    choose_output(.I0(aluResult),
    .I1(output_multiply),
    .S(done),
    .Y(result));
    /*always_comb begin
      result = aluResult;
      if(done) result = output_multiply;
    end*/

    logic [3:0] updated_CC_from_multiply;
    assign updated_CC_from_multiply[3] = flags[0]; //for the Z flag
    assign updated_CC_from_multiply[2] = flags[1]; //for the N flag
    assign updated_CC_from_multiply[1] = 1'b0; //for the C flag
    assign updated_CC_from_multiply[0] = 1'b0; //for the V flag
    

    Mux2to1 #(4)
    choose_flags(.I0(newCC),
    .I1(updated_CC_from_multiply),
    .S(done),
    .Y(CC_good));
	 
	 
	 
	 Register #(16) ledr_reg(.en(memAddr == 16'h0300), .clear(1'b0),
         .D(MDRout),
         .clock,
         .Q(for_ledg15_0));
endmodule
