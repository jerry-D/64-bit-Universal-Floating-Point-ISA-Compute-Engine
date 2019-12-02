//univ_in_H7.v
//
// Author:  Jerry D. Harthcock
// Version:  1.21  November 30, 2019
// Copyright (C) 2019.  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                    //
//                                                    Open-Source                                                     //
//                            SYMPL 64-Bit Universal Floating-point ISA Compute Engine and                            //
//                                   Fused Universal Neural Network (FuNN) eNNgine                                    //
//                                    Evaluation and Product Development License                                      //
//                                                                                                                    //
//                                                                                                                    //
// Open-source means:  this source code and this instruction set ("this IP") may be freely downloaded, copied,        //
// modified, distributed and used in accordance with the terms and conditons of the licenses provided herein.         //
//                                                                                                                    //
// Provided that you comply with all the terms and conditions set forth herein, Jerry D. Harthcock ("licensor"),      //
// the original author and exclusive copyright owner of this SYMPL 64-Bit Universal Floating-point ISA Compute Engine //
// and Fused Universal Neural Network (FuNN) eNNgine, including related development software ("this IP"), hereby      //
// grants recipient of this IP ("licensee"), a world-wide, paid-up, non-exclusive license to implement this IP        //
// within the programmable fabric of Xilinx Kintex Ultra and Kintex Ultra+ brand FPGAs--only--and used only for the   //
// purposes of evaluation, education, and development of end products and related development tools.  Furthermore,    //
// limited to the purposes of prototyping, evaluation, characterization and testing of implementations in a hard,     //
// custom or semi-custom ASIC, any university or institution of higher education may have their implementation of     //
// this IP produced for said limited purposes at any foundary of their choosing provided that such prototypes do      //
// not ever wind up in commercial circulation, with this license extending to such foundary and is in connection      //
// with said academic pursuit and under the supervision of said university or institution of higher education.        //
//                                                                                                                    //
// Any copying, distribution, customization, modification, or derivative work of this IP must include an exact copy   //
// of this license and original copyright notice at the very top of each source file and any derived netlist, and,    //
// in the case of binaries, a printed copy of this license and/or a text format copy in a separate file distributed   //
// with said netlists or binary files having the file name, "LICENSE.txt".  You, the licensee, also agree not to      //
// remove any copyright notices from any source file covered or distributed under this Evaluation and Product         //
// Development License.                                                                                               //
//                                                                                                                    //
// LICENSOR DOES NOT WARRANT OR GUARANTEE THAT YOUR USE OF THIS IP WILL NOT INFRINGE THE RIGHTS OF OTHERS OR          //
// THAT IT IS SUITABLE OR FIT FOR ANY PURPOSE AND THAT YOU, THE LICENSEE, AGREE TO HOLD LICENSOR HARMLESS FROM        //
// ANY CLAIM BROUGHT BY YOU OR ANY THIRD PARTY FOR YOUR SUCH USE.                                                     //
//                                                                                                                    //
// Licensor reserves all his rights, including, but in no way limited to, the right to change or modify the terms     //
// and conditions of this Evaluation and Product Development License anytime without notice of any kind to anyone.    //
// By using this IP for any purpose, licensee agrees to all the terms and conditions set forth in this Evaluation     //
// and Product Development License.                                                                                   //
//                                                                                                                    //
// This Evaluation and Product Development License does not include the right to sell products that incorporate       //
// this IP or any IP derived from this IP. If you would like to obtain such a license, please contact Licensor.       //
//                                                                                                                    //
// Licensor can be contacted at:  SYMPL.gpu@gmail.com or Jerry.Harthcock@gmail.com                                    //
//                                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 `timescale 1ns/100ps

module univ_in_H7 (
    CLK,
    RESET,
    wren,
    pipeLenSel,   //1=long pipe, 0=short pipe
    Size,         //source Size
    Sig,          //source Signal
    wrdata,
    binOut,
    GRSout,
    except    //{divX0, invalid, overflow, underflow, inexact}
    );

input CLK;
input RESET;
input wren;
input pipeLenSel;
input [2:0] Size;        //source Size
input Sig;               //source Signal
input [63:0] wrdata;    
output [15:0] binOut;
output [2:0] GRSout;
output [4:0] except;

wire [15:0] binOutDCS;
wire [2:0] GRSoutDCS;

reg [15:0] bin78_del_2,
           bin78_del_3,
           bin78_del_4,
           bin78_del_5,
           bin78_del_6;

reg [2:0]  bin78GRS_del_2,
           bin78GRS_del_3,
           bin78GRS_del_4,
           bin78GRS_del_5,
           bin78GRS_del_6;         

reg  overflow_del_2,
     overflow_del_3,
     overflow_del_4,
     overflow_del_5,
     overflow_del_6;

reg  underflow_del_2,
     underflow_del_3,
     underflow_del_4,
     underflow_del_5,
     underflow_del_6;
     
reg  inexact_del_2,
     inexact_del_3,
     inexact_del_4,
     inexact_del_5,
     inexact_del_6;
     

reg  H7_del_1,
     H7_del_2,
     H7_del_3,
     H7_del_4,
     H7_del_5,
     H7_del_6;
           
wire [4:0] except;
wire ovflw;
wire divX0;
wire undflw;

wire ovflwDCS;
wire divX0DCS;
wire undflwDCS;
wire inexactDCS;

assign ovflwDCS   = 0;  //not implemented yet
assign divX0DCS   = 0;  //not implemented yet
assign undflwDCS  = 0;  //not implemented yet
assign inexactDCS = 0;  //not implemented yet

//possible input formats
wire H7;
wire bin64;
wire bin32;
wire bfloat16;

//assign H7       = (Size==3'b111) &&  Sig;
assign H7       = &Size[1:0] &&  Sig;     //must be 8 bytes or multiples of 8 bytes
assign bin64    = (Size==3'b111) && ~Sig;
assign bin32    = (Size==3'b110) && ~Sig;
assign bfloat16 = (Size==3'b101) && ~Sig;

wire bin64inf;
wire bin32inf;
wire bfloat16inf;

wire bin64nan;
wire bin32nan;
wire bfloat16nan;

wire bin64zero;
wire bin32zero;
wire bfloat16zero;

assign bin64inf    =  bin64    &&  &wrdata[62:52] && ~|wrdata[51:0];
assign bin32inf    =  bin32    &&  &wrdata[30:23] && ~|wrdata[22:0];
assign bfloat16inf =  bfloat16 &&  &wrdata[14:7]  && ~|wrdata[6:0];

assign bin64nan    =  bin64    &&  &wrdata[62:52] && |wrdata[51:0];
assign bin32nan    =  bin32    &&  &wrdata[30:23] && |wrdata[22:0];
assign bfloat16nan =  bfloat16 &&  &wrdata[14:7]  && |wrdata[6:0];

assign bin64zero = ~|wrdata[62:0];
assign bin32zero = ~|wrdata[30:0];
assign bfloat16zero = ~|wrdata[14:0];

wire [2:0] binFormatSel;
assign binFormatSel = {bin64, bin32, bfloat16};

wire [10:0] bin64unbExp;
assign bin64unbExp = wrdata[62:52] - 1023;
wire [10:0] convBin64toBin78biased;
assign convBin64toBin78biased = bin64unbExp + 63;

wire [7:0] bin32unbExp;
assign bin32unbExp = wrdata[30:23] - 127;
wire [7:0] convBin32toBin78biased;
assign convBin32toBin78biased = bin32unbExp + 63;

wire [7:0] bf16unbExp;
assign bf16unbExp = wrdata[14:7] - 127;
wire [7:0] convBF16toBin78biased;
assign convBF16toBin78biased = bf16unbExp + 63;


reg [15:0] bin78;
reg [2:0] bin78GRS;
reg overflow;
reg underflow;
reg inexact;

always @(posedge CLK)
    if (RESET) {overflow, underflow, inexact, bin78, bin78GRS} <= 22'b0;
    else if (wren)
        casex(binFormatSel)
            3'b1xx : if (bin64zero) {overflow, underflow, inexact, bin78, bin78GRS} <= 0;
                     else if ((wrdata[62:52] < (1023 + 63)) && (wrdata[62:52] > (1023 - 62))) {overflow, underflow, inexact, bin78, bin78GRS} <= {2'b00, |wrdata[43:0], wrdata[63], convBin64toBin78biased[6:0], wrdata[51:44],  wrdata[43:42], |wrdata[41:0]}; 
                     else if (bin64inf || bin64nan) {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b000, wrdata[63], 7'h7F, wrdata[51:44], 3'b000}; 
                     else if (wrdata[62:52] <= (1023 - 62)) {overflow, underflow, inexact, bin78, bin78GRS} <= {1'b0, |wrdata[42:0], |wrdata[42:0], wrdata[63], 7'h00, 1'b1,  wrdata[51:43],  wrdata[42:41], |wrdata[40:0]};
                     else  {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b101, wrdata[63], 7'h7F, 8'h00, 3'b000};
            3'b01x : if (bin32zero) {overflow, underflow, inexact, bin78, bin78GRS} <= 0;
                     else if ((wrdata[30:23] < (127 + 63)) && (wrdata[30:23] > (127 - 62))) {overflow, underflow, inexact, bin78, bin78GRS} <= {2'b00, |wrdata[14:0], wrdata[31], convBin32toBin78biased[6:0], wrdata[22:15],  wrdata[14:13], |wrdata[12:0]}; 
                     else if (bin32inf || bin32nan) {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b000, wrdata[31], 7'h7F, wrdata[22:15], 3'b000}; 
                     else if (wrdata[30:23] <= (127 - 62)) {overflow, underflow, inexact, bin78, bin78GRS} <= {1'b0, |wrdata[13:0], |wrdata[13:0], wrdata[31], 7'h00, 1'b1, wrdata[22:14], wrdata[13:12], |wrdata[11:0]};
                     else  {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b101, wrdata[31], 7'h7F, 8'h00, 3'b000};
            3'b001 : if (bfloat16zero) {overflow, underflow, inexact, bin78, bin78GRS} <= 0;
                     else if ((wrdata[14:7] < (127 + 63)) && (wrdata[14:7] > (127 - 62))) {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b000, wrdata[15], convBF16toBin78biased[6:0],  wrdata[6:0], 4'b0000}; 
                     else if ( bfloat16inf ||  bfloat16nan) {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b000, wrdata[15], 7'h7F, wrdata[6:0], 4'b0000}; 
                     else if (wrdata[14:7] <= (127 - 62)) {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b010, wrdata[15], 7'h00, 1'b1, wrdata[6:0], 3'b000};
                     else  {overflow, underflow, inexact, bin78, bin78GRS} <= {3'b101, wrdata[31], 7'h7F, 8'h00, 3'b000};
           default : {overflow, underflow, inexact, bin78, bin78GRS} = 22'b0;
        endcase
       
always @(posedge CLK) begin
    bin78_del_2 <= bin78;
    bin78_del_3 <= bin78_del_2;
    bin78_del_4 <= bin78_del_3;
    bin78_del_5 <= bin78_del_4;
    bin78_del_6 <= bin78_del_5;
end

always @(posedge CLK) begin
    bin78GRS_del_2 <= bin78GRS;
    bin78GRS_del_3 <= bin78GRS_del_2;
    bin78GRS_del_4 <= bin78GRS_del_3;
    bin78GRS_del_5 <= bin78GRS_del_4;
    bin78GRS_del_6 <= bin78GRS_del_5;
end

always @(posedge CLK) begin
    overflow_del_2 <= overflow;
    overflow_del_3 <= overflow_del_2;
    overflow_del_4 <= overflow_del_3;
    overflow_del_5 <= overflow_del_4;
    overflow_del_6 <= overflow_del_5;
end

always @(posedge CLK) begin
    underflow_del_2 <= underflow;
    underflow_del_3 <= underflow_del_2;
    underflow_del_4 <= underflow_del_3;
    underflow_del_5 <= underflow_del_4;
    underflow_del_6 <= underflow_del_5;
end

always @(posedge CLK) begin
    inexact_del_2 <= inexact;
    inexact_del_3 <= inexact_del_2;
    inexact_del_4 <= inexact_del_3;
    inexact_del_5 <= inexact_del_4;
    inexact_del_6 <= inexact_del_5;
end

always @(posedge CLK) begin
    H7_del_1 <= H7;
    H7_del_2 <= H7_del_1;
    H7_del_3 <= H7_del_2;
    H7_del_4 <= H7_del_3;
    H7_del_5 <= H7_del_4;
    H7_del_6 <= H7_del_5;
end

reg [6:1] pipeLenSel_del;
always @(posedge CLK) begin
    pipeLenSel_del[1] <= pipeLenSel;
    pipeLenSel_del[2] <= pipeLenSel_del[1];
    pipeLenSel_del[3] <= pipeLenSel_del[2];
    pipeLenSel_del[4] <= pipeLenSel_del[3];
    pipeLenSel_del[5] <= pipeLenSel_del[4];
    pipeLenSel_del[6] <= pipeLenSel_del[5];
end

`ifdef FuNN_Has_FromDecimalChar
decCharToBinH8 DCStoBinH8_out(
    .RESET (RESET ),
    .CLK   (CLK   ),
    .wren  (wren  ),
    .wrdata(wrdata),
    .binOut(binOutDCS),
    .GRS   (GRSoutDCS)
    );
`else
assign binOutDCS = 0;
assign GRSoutDCS = 0;
`endif

reg wren_del;
always @(posedge CLK) wren_del <= wren;

assign binOut = (~pipeLenSel_del[1] && wren_del) ? bin78    : (H7_del_6 ? binOutDCS : bin78_del_6);
assign GRSout = (~pipeLenSel_del[1] && wren_del) ? bin78GRS : (H7_del_6 ? GRSoutDCS : bin78GRS_del_6);
assign except = (~pipeLenSel_del[1] && wren_del) ? {1'b0, 1'b0, overflow, underflow, inexact} : (H7_del_6 ? 5'b00000 : {1'b0, 1'b0, overflow_del_6, underflow_del_6, inexact_del_6});

endmodule
