//Activ_H7.v
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

module Activ_H7(
    CLK   ,
    RESET ,
    wren,
    shortPipeEn,
    SigD,
    SizeD,
    actSel,
    X     ,
    GRSin ,
    exceptX,
    XWdiv,      
    XWdivGRS,   
    XWdivExcept,
    R_conv,
    exceptR_conv,
    R78,
    D_conv,
    exceptD_conv,
    RXW0 ,
    GXW0 ,
    RXW1 ,
    GXW1 ,
    RXW2 ,
    GXW2 ,
    RXW3 ,
    GXW3 ,
    RXW4 ,
    GXW4 ,
    RXW5 ,
    GXW5 ,
    RXW6 ,
    GXW6 ,
    RXW7 ,
    GXW7 ,
    RXW8 ,
    GXW8 ,
    RXW9 ,
    GXW9 ,
    RXW10,
    GXW10,
    RXW11,
    GXW11,
    RXW12,
    GXW12,
    RXW13,
    GXW13,
    RXW14,
    GXW14,
    RXW15,
    GXW15,                              
    hardMax_sel,                        
    hardMax,
    classOneHot,
    classTooHot,
    maxProb
    );

input CLK;
input RESET;
input wren;
input shortPipeEn;
input SigD;
input [2:0] SizeD;
input  [3:0] actSel;
input [15:0] X;
input [2:0] GRSin;
input [4:0] exceptX;
input [15:0] XWdiv;      
input [2:0]  XWdivGRS;   
input [4:0]  XWdivExcept;
output [63:0] R_conv;
output [18:0] R78;
output [63:0] D_conv;
output [4:0] exceptR_conv;
output [4:0] exceptD_conv;

input [15:0] RXW0 ;
input [2:0]  GXW0 ; 
input [15:0] RXW1 ;
input [2:0]  GXW1 ;
input [15:0] RXW2 ;
input [2:0]  GXW2 ;
input [15:0] RXW3 ;
input [2:0]  GXW3 ;
input [15:0] RXW4 ;
input [2:0]  GXW4 ;
input [15:0] RXW5 ;
input [2:0]  GXW5 ;
input [15:0] RXW6 ;
input [2:0]  GXW6 ;
input [15:0] RXW7 ;
input [2:0]  GXW7 ;
input [15:0] RXW8 ;
input [2:0]  GXW8 ;
input [15:0] RXW9 ;
input [2:0]  GXW9 ;
input [15:0] RXW10;
input [2:0]  GXW10;
input [15:0] RXW11;
input [2:0]  GXW11;
input [15:0] RXW12;
input [2:0]  GXW12;
input [15:0] RXW13;
input [2:0]  GXW13;
input [15:0] RXW14;
input [2:0]  GXW14;
input [15:0] RXW15;
input [2:0]  GXW15;
output hardMax_sel;
output [1023:0] hardMax;                         
output [15:0] classOneHot;                       
output [15:0] classTooHot;
output [31:0] maxProb;


wire [63:0] R_conv;
wire [63:0] D_conv;
wire [18:0] R78;

wire [4:0] exceptR_conv;
wire [4:0] exceptD_conv;

reg [3:0] actSel_del;
reg shortPipeEn_del;
reg [15:0] R;
reg [2:0] GRSout;
reg [15:0] X_del;
reg [2:0]  G_del;
reg [15:0] D;
reg [2:0] GRSoutD;
reg [4:0] except;

wire [15:0] R_SQNL;
wire [2:0]  G_SQNL;

wire [15:0] R_SQ_RBF;
wire [2:0]  G_SQ_RBF;

wire [15:0] R_HardTan;
wire [2:0]  G_HardTan;

wire [15:0] R_ReLU;
wire [2:0]  G_ReLU;

wire [15:0] R_LReLU;
wire [2:0]  G_LReLU;

wire [15:0] R_EXP;
wire [2:0]  G_EXP;
wire [4:0]  exceptEXP;

wire [15:0] R_TanH;
wire [2:0] G_TanH;
wire [4:0] exceptTanH;
                                              
wire [15:0] R_SoftStep;
wire [2:0] G_SoftStep;
wire [4:0] exceptSoftStep;

/*
wire [15:0] R_Elliot;
wire [2:0] G_Elliot;
wire [4:0] exceptElliot;
wire [15:0] D_Elliot;
wire [2:0] GRSoutD_Elliot;
*/


wire [15:0] D_SQNL;
wire [2:0] GRSoutD_SQNL;
`ifdef FuNN_Has_SQNL
SQNL_H7 SQNL(
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_SQNL),
    .GRSin (GRSin ),
    .GRSout(G_SQNL),
    .D     (D_SQNL),
    .GRSoutD(GRSoutD_SQNL)
    );
`else 
assign R_SQNL = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_SQNL = 0;
assign D_SQNL = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_SQNL = 0;
`endif

wire [15:0] D_SQ_RBF;
wire [2:0] GRSoutD_SQRBF;
`ifdef FuNN_Has_SQ_RFB
SQ_RBF_H7 SQ_RBF(
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_SQ_RBF),
    .GRSin (GRSin ),
    .GRSout(G_SQ_RBF),
    .D     (D_SQ_RBF),
    .GRSoutD(GRSoutD_SQRBF)
    );
`else
assign R_SQ_RBF = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_SQ_RBF = 0;
assign D_SQ_RBF = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_SQRBF = 0;
`endif


wire [15:0] D_HardTan;
wire [2:0] GRSoutD_HardTan; 
`ifdef FuNN_Has_HardTan   
HardTan_H7 HardTan(
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_HardTan),
    .GRSin (GRSin ),
    .GRSout(G_HardTan),
    .D     (D_HardTan),
    .GRSoutD(GRSoutD_HardTan)
    );
`else 
assign R_HardTan = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_HardTan = 0;
assign D_HardTan = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_HardTan = 0;
`endif


wire [15:0] D_ReLU;
wire [2:0] GRSoutD_ReLU;
`ifdef FuNN_Has_ReLU
ReLU_H7 ReLU(
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_ReLU),
    .GRSin (GRSin ),
    .GRSout(G_ReLU),
    .D     (D_ReLU),
    .GRSoutD(GRSoutD_ReLU)
    );
`else
assign R_ReLU = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_ReLU = 0;
assign D_ReLU = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_ReLU = 0;
`endif


wire [15:0] D_LReLU;
wire [2:0] GRSoutD_LReLU;
`ifdef FuNN_Has_LReLU
LReLU_H7 LReLU(
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_LReLU),
    .GRSin (GRSin ),
    .GRSout(G_LReLU),
    .D     (D_LReLU),
    .GRSoutD(GRSoutD_LReLU)
    );
`else
assign R_LReLU = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_LReLU = 0;
assign D_LReLU = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_LReLU = 0;
`endif


`ifdef FuNN_Has_Exp
exp_H7 EXP(
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_EXP),
    .GRSin (GRSin ),
    .GRSout(G_EXP),
    .except(exceptEXP)
    );
`else 
assign R_EXP = 16'h7F1A;   //NaN payload=1A --requested activation not defined    
assign G_EXP = 0;
assign exceptEXP = 0;
`endif

wire [15:0] D_TanH;
wire [2:0] GRSoutD_TanH;
wire [4:0] exceptD_TanH;

`ifdef FuNN_Has_TanH
TanH_H7 TanH(    
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_TanH),
    .GRSin (GRSin ),
    .GRSout(G_TanH),
    .except(exceptTanH),
    .D     (D_TanH),
    .GRSoutD(GRSoutD_TanH),
    .exceptD(exceptD_TanH)
    );
`else
assign R_TanH = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_TanH = 0;
assign D_TanH = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign exceptTanH = 0;
assign GRSoutD_TanH = 0;
assign exceptD_TanH = 0;
`endif

wire [15:0] D_SoftStep;
wire [2:0] GRSoutD_SStep;
wire [4:0] exceptD_SStep;

`ifdef FuNN_Has_SoftStep
SoftStep_H7 SoftStep(    
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_SoftStep),
    .GRSin (GRSin ),
    .GRSout(G_SoftStep),
    .except(exceptSoftStep),
    .D     (D_SoftStep),
    .GRSoutD(GRSoutD_SStep),
    .exceptD(exceptD_SStep)
    );
`else
assign R_SoftStep = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_SoftStep = 0;
assign exceptSoftStep = 0;
assign D_SoftStep = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_SStep = 0;
assign exceptD_SStep = 0;
`endif


wire [15:0] R_SoftPlus;
wire [2:0] G_SoftPlus;
wire [4:0] exceptSoftPlus;

`ifdef FuNN_Has_SoftPlus     
SoftPlus_H7 SoftPlus(    
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_SoftPlus),
    .GRSin (GRSin ),
    .GRSout(G_SoftPlus),
    .except(exceptSoftPlus)
    );
`else 
assign R_SoftPlus = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_SoftPlus = 0;
assign exceptSoftPlus = 0;
`endif
    
wire [15:0] R_Gaussian;
wire [2:0] G_Gaussian;
wire [4:0] exceptGaussian;
wire [15:0] D_Gaussian;
wire [2:0] GRSoutD_Gaus;
wire [4:0] exceptD_Gaus;

`ifdef FuNN_Has_Gaussian
Gaussian_H7 Gaus(
    .CLK   (CLK  ),
    .RESET (RESET),
    .X     (X    ),
    .R     (R_Gaussian),
    .GRSin (GRSin     ),
    .GRSout(G_Gaussian),
    .except(exceptGaussian),
    .D     (D_Gaussian),
    .GRSoutD(GRSoutD_Gaus),
    .exceptD(exceptD_Gaus)
    );
`else
assign R_Gaussian = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign G_Gaussian = 0;
assign exceptGaussian = 0;
assign D_Gaussian = 16'h7F1A;   //NaN payload=1A --requested activation not defined
assign GRSoutD_Gaus = 0;
assign exceptD_Gaus = 0;
`endif    
    
/*
Elliot_H7 Elliot(    
    .CLK   (CLK   ),
    .RESET (RESET ),
    .X     (X     ),
    .R     (R_Elliot),
    .GRSin (GRSin ),
    .GRSout(G_Elliot),
    .D     (D_Elliot),
    .GRSoutD(GRSoutD_Elliot)
    );
*/
reg wren_del;
reg SigD_del;
reg [2:0] SizeD_del;

wire [1023:0] hardMax;                                  
wire [15:0] classOneHot;                                
wire [15:0] classTooHot;                                      
wire [31:0] maxProb;
wire hardMax_sel;

`ifdef FuNN_Has_HardMax
HardMax_H7 hardmax(
    .CLK   (CLK  ),
    .RESET (RESET),
    .shortPipeEn(shortPipeEn),
    .wren       (wren),
    .SigD       (SigD),
    .SizeD      (SizeD),   //destination Size
    .x0    (RXW0 ),
    .x0GRS (GXW0 ),
    .x1    (RXW1 ),
    .x1GRS (GXW1 ),
    .x2    (RXW2 ),
    .x2GRS (GXW2 ),
    .x3    (RXW3 ),
    .x3GRS (GXW3 ),
    .x4    (RXW4 ),
    .x4GRS (GXW4 ),
    .x5    (RXW5 ),
    .x5GRS (GXW5 ),
    .x6    (RXW6 ),
    .x6GRS (GXW6 ),
    .x7    (RXW7 ),
    .x7GRS (GXW7 ),
    .x8    (RXW8 ),
    .x8GRS (GXW8 ),
    .x9    (RXW9 ),
    .x9GRS (GXW9 ),
    .x10   (RXW10),
    .x10GRS(GXW10),
    .x11   (RXW11),
    .x11GRS(GXW11),
    .x12   (RXW12),
    .x12GRS(GXW12),
    .x13   (RXW13),
    .x13GRS(GXW13),
    .x14   (RXW14),
    .x14GRS(GXW14),
    .x15   (RXW15),
    .x15GRS(GXW15),
    .R     (hardMax),
    .classOneHot (classOneHot),
    .classTooHot (classTooHot),
    .maxProb(maxProb)
    );
    

reg hardMax_wren_del_1,
    hardMax_wren_del_2,
    hardMax_wren_del_3,
    hardMax_wren_del_4,
    hardMax_wren_del_5,
    hardMax_wren_del_6;
always @(posedge CLK) begin
    hardMax_wren_del_1 <= ~shortPipeEn_del && wren_del && (actSel_del==4'b1100);  //code for hardmax
    hardMax_wren_del_2 <= hardMax_wren_del_1;
    hardMax_wren_del_3 <= hardMax_wren_del_2;
    hardMax_wren_del_4 <= hardMax_wren_del_3;
    hardMax_wren_del_5 <= hardMax_wren_del_4;   
    hardMax_wren_del_6 <= hardMax_wren_del_5;
end

assign hardMax_sel = shortPipeEn_del && wren_del && (actSel_del==4'b1100) ? 1'b1 : hardMax_wren_del_6; 
 
`else
assign hardMax = 0;
assign classOneHot = 0;
assign classNumber = 0;
assign maxProb = 0;
assign hardMax_sel = 0;
`endif


always @(posedge CLK) 
    if (wren) actSel_del <= actSel;
    else actSel_del <= 4'b0000;

reg [4:0] exceptX_del;    
always @(posedge CLK) 
    if (wren) {X_del, G_del, exceptX_del} <= {X, GRSin, exceptX};
    else {X_del, G_del, exceptX_del} <= 19'b0;

reg [15:0] XWdiv_del;    
reg [2:0] XWdivGRS_del;
reg [4:0] XWdivExcept_del; 
always @(posedge CLK) 
    if (wren) {XWdiv_del, XWdivGRS_del, XWdivExcept_del} <= {XWdiv, XWdivGRS, XWdivExcept};
    else {XWdiv_del, XWdivGRS_del, XWdivExcept_del} <= 19'b0;


always @(posedge CLK) begin
    shortPipeEn_del <= shortPipeEn;
    wren_del <= wren;
    SigD_del <= SigD;
    SizeD_del <= SizeD;
end    

reg [2:0] GRSoutR;
reg [4:0] exceptR;
reg [4:0] exceptD; 
    
always @(*)
    case(actSel_del)
        4'b0000 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {X_del,      G_del,        exceptX_del,     16'h0000,   3'b000,          5'b00000     };  //feed thru with no activation
        4'b0001 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_SQNL,     G_SQNL,       5'b00000,        D_SQNL,     GRSoutD_SQNL,    5'b00000     }; 
        4'b0010 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_ReLU,     G_ReLU,       5'b00000,        D_ReLU,     GRSoutD_ReLU,    5'b00000     }; 
        4'b0011 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_LReLU,    G_LReLU,      5'b00000,        D_LReLU,    GRSoutD_LReLU,   5'b00000     };  
        4'b0100 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_HardTan,  G_HardTan,    5'b00000,        D_HardTan,  GRSoutD_HardTan, 5'b00000     };
        4'b0101 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_SQ_RBF,   G_SQ_RBF,     5'b00000,        D_SQ_RBF,   GRSoutD_SQRBF,   5'b00000     }; 
        4'b0110 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_EXP,      G_EXP,        exceptEXP,       R_EXP,      G_EXP,           5'b00000     };
        4'b0111 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_TanH,     G_TanH,       exceptTanH,      D_TanH,     GRSoutD_TanH,    exceptD_TanH };
        4'b1000 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_SoftStep, G_SoftStep,   exceptSoftStep,  D_SoftStep, GRSoutD_SStep,   exceptD_SStep};
        4'b1001 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_SoftPlus, G_SoftPlus,   exceptSoftPlus,  R_SoftStep, G_SoftStep,      exceptD_SStep};
        4'b1010 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {R_Gaussian, G_Gaussian,   exceptGaussian,  D_Gaussian, GRSoutD_Gaus,    exceptD_Gaus };
        4'b1011 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = {XWdiv_del,  XWdivGRS_del, XWdivExcept_del, 16'h0000,   3'b000,          5'b00000     }; //division for SoftMax
        4'b1100 : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = 0; //HardMax
        default : {R, GRSoutR, exceptR, D, GRSoutD, exceptD} = 0;
    endcase     

univ_out_H7 univ_out_R(
    .CLK(CLK),
    .RESET(RESET),
    .shortPipeEn(shortPipeEn_del),
    .wren(wren_del),
    .SigD(SigD_del),
    .SizeD(SizeD_del),   //destination Size
    .wrdata(R),
    .GRSin(GRSoutR),
    .exceptIn(exceptR),
    .R_conv(R_conv ),
    .exceptR_conv(exceptR_conv), //{divX0, invalid, overflow, underflow, inexact}
    .R78(R78)
    );

univ_out_H7 univ_out_D(
    .CLK(CLK),
    .RESET(RESET),
    .shortPipeEn(shortPipeEn_del),
    .wren(wren_del),
    .SigD(SigD_del),
    .SizeD(SizeD_del),   //destination Size
    .wrdata(D),
    .GRSin(GRSoutD),
    .exceptIn(exceptD),
    .R_conv(D_conv ),
    .exceptR_conv(exceptD_conv), //{divX0, invalid, overflow, underflow, inexact}
    .R78()
    );


endmodule




                          