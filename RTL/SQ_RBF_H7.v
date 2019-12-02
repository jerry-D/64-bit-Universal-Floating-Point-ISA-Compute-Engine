//SQ_RBF_H7.v
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

module SQ_RBF_H7(
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
reg [15:0] Xq;
reg [2:0] GRSinq;

wire [15:0] sqrR;
wire [2:0] sqrGRS;
wire [15:0] SQ_RFB1;
wire [2:0] GRS_SQ_RFB1;
wire [15:0] SQ_RFB2;
wire [2:0] GRS_SQ_RFB2;
wire [15:0] x2div2;
wire [15:0] SQ_RFB2div2;

wire [15:0] deriv;
wire [2:0] derivGRS;
wire [2:0] sel;

assign x2div2 = {sqrR[15], sqrR[14:8] - 1, sqrR[7:0]};
assign SQ_RFB2div2 = {SQ_RFB2[15], SQ_RFB2[14:8] - 1, SQ_RFB2[7:0]};

//           __
//          /
//          |   1-(X^2/2)   : X <= 1.0
//  f(X) = <  2-((2-X^2)/2) : 1.0 <= |X| < 2.0
//          |        0      : |X| > -2.0
//          \__


reg sel_2;
reg sel_1;
reg sel_0;

always @(posedge CLK) begin
    Xq <= X;
    GRSinq <= GRSin;
    sel_2 <= {X[14:0], GRSin} <= {15'h3F00, 3'b000}; // |X| <= 1.0
    sel_1 <= ({X[14:0], GRSin} >= {15'h3F00, 3'b000}) && ({X[14:0], GRSin} < {15'h4000, 3'b000});  // 1.0 <= |X| < 2.0
    sel_0 <= ({X[14:0], GRSin} < {15'h4000, 3'b000});  // |X| > -2.0
end

assign sel = {sel_2, sel_1, sel_0};
always @(*)
    casex(sel)
        3'b1xx : begin
                    {R[15:0], GRSout} = {SQ_RFB1, GRS_SQ_RFB1};    // 1-(X^2/2)   : |X| <= 1.0
                    {D[15:0], GRSoutD} = {~Xq[15], Xq[14:0], GRSinq}; // derivative:  -X
                 end   
        3'b01x : begin
                    {R[15:0], GRSout} = {1'b0, SQ_RFB2div2[14:0], GRS_SQ_RFB2};   // (2-(X^2))/2 : 1.0 <= |X| < 2.0
                    {D[15:0], GRSoutD} = {~Xq[15], deriv[14:0], derivGRS};       // derivative:  (X-2) : 1 < x < 2
                 end                                                             //              (2+X) : -2 < x < -1
        3'b001 : begin
                    {R[15:0], GRSout} = 19'b0;   // 0 : |X| > -2.0
                    {D[15:0], GRSoutD} = 19'b0;                   // derivative is 0
                 end   
        default : begin
                    {R[15:0], GRSout} = 19'b0;
                    {D[15:0], GRSoutD} = 19'b0;
                  end  
    endcase

wire [4:0] sqrExcept;    
FMUL711noClk fsqr(      //X^2
//    .CLK   (CLK   ),
    .A     (X     ),
    .GRSinA(GRSin ),
    .B     (X     ),
    .GRSinB(GRSin ),
    .R     (sqrR  ),
    .GRSout(sqrGRS),
    .except(sqrExcept)
    );

wire [4:0] SQ_RBFexcept;
FADD711 fadd1(        // 1-(X^2/2)
    .CLK   (CLK      ),
    .A     (16'h3F00),  //+1.0
    .GRSinA(3'b000),
    .B     ({1'b1, x2div2[14:0]}),
    .GRSinB(sqrGRS),
    .R     (SQ_RFB1),
    .GRSout(GRS_SQ_RFB1),
    .except(SQ_RBFexcept)
    );

wire [4:0] fadd2Except;
//FADD711noClk fadd2(         // 2-(X^2)
FADD711 fadd2(         // 2-(X^2)
    .CLK   (CLK      ),
    .A     (16'h4000),  //+2.0
    .GRSinA(3'b000),
    .B     ({1'b1, sqrR[14:0]}),
    .GRSinB(sqrGRS   ),
    .R     (SQ_RFB2  ),
    .GRSout(GRS_SQ_RFB2),
    .except(fadd2Except)
    );

wire [4:0] fadd4Except;
//FADD711 fadd4(         // 2-X for derivative
FADD711 fadd4(         // X-2 for derivative
    .CLK   (CLK      ),
    .A     ({1'b0, X[14:0]}),  //+2.0
    .GRSinA(3'b000),
    .B     (16'hC000),  //-2.0
    .GRSinB(GRSin ),
    .R     (deriv  ),
    .GRSout(derivGRS),
    .except(fadd4Except)
    );

endmodule
