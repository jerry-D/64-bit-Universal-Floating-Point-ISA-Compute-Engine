//univ_out_H7.v
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

module univ_out_H7 (
    CLK,
    RESET,
    shortPipeEn,
    wren,
    SigD,
    SizeD,   //destination Size
    wrdata,
    GRSin,
    exceptIn,
    R_conv,
    exceptR_conv,       //{divX0, invalid, overflow, underflow, inexact}
    R78                 //unconverted, but includes GRS bits
    );

input CLK;
input RESET;
input shortPipeEn;
input wren;
input SigD;
input [2:0] SizeD;
input [15:0] wrdata;
input [2:0] GRSin;
input [4:0] exceptIn;
output [63:0] R_conv;
output [4:0] exceptR_conv;
output [18:0] R78;

reg [63:0] binQ_del_0,
           binQ_del_1,
           binQ_del_2,
           binQ_del_3,
           binQ_del_4,
           binQ_del_5,
           binQ_del_6;

reg [18:0] R78_del_1,
           R78_del_2,
           R78_del_3,
           R78_del_4,
           R78_del_5,
           R78_del_6;

reg TextSel_del_1,           
    TextSel_del_2,
    TextSel_del_3,
    TextSel_del_4,
    TextSel_del_5,
    TextSel_del_6;
    
reg [4:0] except_del_1,
          except_del_2,
          except_del_3,
          except_del_4,
          except_del_5,
          except_del_6;
                  
wire [63:0] R_LongPipe;
wire [63:0] R_ShortPipe;
wire [63:0] R_conv;
wire [4:0] exceptLongPipe;
wire [4:0] exceptShortPipe;
wire [4:0] exceptR_conv;
           
wire [7:0]  bf16Exp;
wire [7:0]  bin32Exp;
wire [10:0] bin64Exp;
wire [63:0] ascOut;
wire [4:0] except;
wire [18:0] R78;
wire XisZero;
wire XisNaN;
wire XisInf;
wire XisSubnormal;

assign XisZero = ~|wrdata[14:0];
assign XisNaN = &wrdata[14:8] && |wrdata[6:0];
assign XisInf = &wrdata[14:8] && ~|wrdata[7:0];
assign XisSubnormal = ~XisZero && ~|wrdata[14:8];


assign except = 5'b00000;

assign bf16Exp  = (XisZero || XisNaN || XisInf) ? wrdata[14:8] : wrdata[14:8]-63+127;
assign bin32Exp = (XisZero || XisNaN || XisInf) ? wrdata[14:8] : wrdata[14:8]-63+127;
assign bin64Exp = (XisZero || XisNaN || XisInf) ? wrdata[14:8] : wrdata[14:8]-63+1023;

assign R_LongPipe = TextSel_del_6 ? ascOut : binQ_del_6;
assign R_ShortPipe = binQ_del_0;
assign exceptLongPipe = except_del_6;
assign exceptShortPipe = except_del_1;

assign R78 = shortPipeEn && wren ? {wrdata, GRSin} : R78_del_6;

assign R_conv = shortPipeEn && wren ? R_ShortPipe : R_LongPipe;
assign exceptR_conv = shortPipeEn ? exceptShortPipe : exceptLongPipe;


wire [1:0] binFormatSel;
assign binFormatSel = SizeD[1:0];
always @(*)
   case(binFormatSel)
       2'b00 : binQ_del_0 = 0;
       2'b01 : binQ_del_0 = {48'b0, wrdata[15],  bf16Exp, wrdata[7:1]};
       2'b10 : binQ_del_0 = {32'b0, wrdata[15], bin32Exp, wrdata[7:0], GRSin[2:0], 12'b0};
       2'b11 : binQ_del_0 = {wrdata[15], bin64Exp, wrdata[7:0], GRSin[2:0], 41'b0};
   endcase

always @(posedge CLK) begin
   if (wren) except_del_1 <= exceptIn;
   else except_del_1 <= 0;
    except_del_2 <= except_del_1;
    except_del_3 <= except_del_2;
    except_del_4 <= except_del_3;
    except_del_5 <= except_del_4;
    except_del_6 <= except_del_5;
end    
    
always @(posedge CLK) begin
    if (wren) binQ_del_1 <= binQ_del_0;
    else binQ_del_1 <= 0;
    binQ_del_2 <= binQ_del_1;
    binQ_del_3 <= binQ_del_2;
    binQ_del_4 <= binQ_del_3;
    binQ_del_5 <= binQ_del_4;
    binQ_del_6 <= binQ_del_5;
end 

              
always @(posedge CLK) begin
    R78_del_1 <= {wrdata, GRSin};
    R78_del_2 <= R78_del_1;
    R78_del_3 <= R78_del_2;
    R78_del_4 <= R78_del_3;
    R78_del_5 <= R78_del_4;
    R78_del_6 <= R78_del_5;
end               


always @(posedge CLK) begin
    TextSel_del_1 <= SigD && wren;
    TextSel_del_2 <= TextSel_del_1;
    TextSel_del_3 <= TextSel_del_2;
    TextSel_del_4 <= TextSel_del_3;
    TextSel_del_5 <= TextSel_del_4;
    TextSel_del_6 <= TextSel_del_5;
end

`ifdef FuNN_Has_ToDecimalChar
binToDecCharH8 binDec(  //6 clocks
    .RESET (RESET ),
    .CLK   (CLK   ),
    .wren  (wren  ),
    .wrdata(wrdata),
    .ascOut(ascOut)
    );             
`else
assign ascOut = 0;
`endif

endmodule
