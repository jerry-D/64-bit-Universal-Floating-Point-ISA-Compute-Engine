//SQNL_H7.v
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

module SQNL_H7(
    CLK,
    RESET,
    X,
    R,
    GRSin,
    GRSout,
    D,
    GRSoutD
    );

input CLK;
input RESET;
input [15:0] X;
output [15:0] R;
input [2:0] GRSin;
output [2:0] GRSout;
output [15:0] D;
output [2:0] GRSoutD;

reg [2:0] GRSout;
reg [15:0] R;
reg [15:0] D;
reg [2:0] GRSoutD;
reg [15:0] X_del;
reg [2:0] GRSin_del;

wire [15:0] sqrR;
wire [2:0] sqrGRS;
//wire [18:0] x2div4;
wire [15:0] x2div4;
assign x2div4 = {sqrR[15], sqrR[14:8] - 2, sqrR[7:0]};
wire [15:0] SQNLadd;
wire [2:0] GRSoutAdd;

wire [15:0] X_div2;
wire [15:0] onePlusMinusXdiv2;
wire [2:0] GRSoutPlusMinus;

//           __
//          /
//          |         1 : X > 2.0
//          | X-(X^2/4) : 0 <= X <= 2.0
//  f(X) = <
//          | X+(X^2/4) : -2 <= X < 0
//          |        -1 : X < -2.0
//          \__

reg [3:0] sel;
wire subtr;
assign    subtr = (~X[15] && ({X[14:0], GRSin} >= {15'h0000, 3'b000})) && (~X[15] && ({X[14:0], GRSin} <= {15'h4000, 3'b000})) ;  // 0 <= X <= 2.0

always @(posedge CLK) begin
    X_del <= X;
    GRSin_del <= GRSin;
    sel[3] <= ~X[15] && ({X[14:0], GRSin} > {15'h4000, 3'b000});    // X > 2.0
    sel[2] <= subtr;  // 0 <= X <= 2.0
    
    sel[1] <= X[15] && ({X[14:0], GRSin} <= {15'h4000, 3'b000});    // -2 <= X < 0
    
    sel[0] <=  X[15] && ({X[14:0], GRSin} >  {15'h4000, 3'b000});    // X < -2.0
end

always @(*)
    casex(sel)
        4'b1xxx : {R[15:0], GRSout} = {16'h3f00, 3'b000};
        4'b01xx,
        4'b001x : {R[15:0], GRSout} = {SQNLadd, GRSoutAdd};
        4'b0001 : {R[15:0], GRSout} = {16'hbf00, 3'b000};
        default : {R[15:0], GRSout} = 19'b0;
    endcase
    
//derivative
//   1 - (X/2)
//   1 + (X/2)

always @(*)
    casex(sel)
        4'b1xxx : {D[15:0], GRSoutD} = 19'b0;
        4'b01xx,
        4'b001x : {D[15:0], GRSoutD} = {onePlusMinusXdiv2, GRSoutPlusMinus};
        4'b0001 : {D[15:0], GRSoutD} = 19'b0;
        default : {D[15:0], GRSoutD} = 19'b0;
    endcase
    
wire [4:0] sqrExcept;    
FMUL711noClk fsqr(
//    .CLK   (CLK   ),
    .A     (X     ),
    .GRSinA(GRSin ),
    .B     (X     ),
    .GRSinB(GRSin ),
    .R     (sqrR  ),
    .GRSout(sqrGRS),
    .except(sqrExcept)
    );

wire [4:0] SQNLexcept;
FADD711 fadd1(
    .CLK   (CLK      ),
//    .A     (X_del    ),
    .A     (X        ),
    .GRSinA(GRSin_del),
    .B     ({subtr^x2div4[15], x2div4[14:0]}),
    .GRSinB(sqrGRS   ),
    .R     (SQNLadd  ),
    .GRSout(GRSoutAdd),
    .except(SQNLexcept)
    );

wire [4:0] fadd2Except;
// derivative calculation
assign X_div2 = {X[15], (X[14:8] - 1'b1), X[7:0]};    
FADD711 fadd2(
    .CLK   (CLK      ),
    .A     (16'h3F00    ),
    .GRSinA(3'b000),
    .B     ({subtr^X_div2[15], X_div2[14:0]}),
    .GRSinB(GRSin  ),
    .R     (onePlusMinusXdiv2),
    .GRSout(GRSoutPlusMinus),
    .except(fadd2Except)
    );
         

endmodule
