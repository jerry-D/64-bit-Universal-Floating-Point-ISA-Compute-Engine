//FuNN_H7.v
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

module FuNN (
    CLK,
    RESET,
    RM,
    ACT,     // 1 = activate, 0 = bipass activation
    ADT,     // 1 = add total, 0 = add 0
    actSel,
    SizeA_q0,
    SizeB_q0,
    SizeA_q2,
    SizeB_q2,
    SizeD_q2,
    SigA_q2,
    SigB_q2,
    SigD_q2,
    wren,
    wraddrs,
    wrdataA,
    wrdataB,
    rdenA,
    rdaddrsA,
    rddataA,
    rdenB,
    rdaddrsB,
    rddataB,
    exceptA,
    exceptB,
    restore,
    ready,
    ready_q0
    );

input CLK;
input RESET;
input [1:0] RM;
input ACT;
input ADT;
input [3:0] actSel;
input [2:0] SizeA_q0;
input [2:0] SizeB_q0;
input [2:0] SizeA_q2;
input [2:0] SizeB_q2;
input [2:0] SizeD_q2;
input SigA_q2;
input SigB_q2;
input SigD_q2;
input wren;
input [12:0] wraddrs;
input [1023:0] wrdataA;
input [1023:0] wrdataB;
input rdenA;
input [12:0] rdaddrsA;
output [1023:0] rddataA;
input rdenB;
input [12:0] rdaddrsB;
output [1023:0] rddataB;
output [4:0] exceptA;
output [4:0] exceptB;
input restore;
output ready;
output ready_q0;



reg [255:0] semaphor;  // one bit for each memory location 
reg readyA;
reg readyB;
reg rdenA_del;
reg readyA_q0;
reg readyB_q0;


wire ready;
wire ready_q0;
assign ready = readyA && readyB;
assign ready_q0 = readyA_q0 && readyB_q0;

wire [1023:0] rddataA;
wire [1023:0] rddataB;
wire [4:0] exceptA;
wire [4:0] exceptB;

wire shortPipeEn;
wire [63:0] R;
wire [18:0] R78;
wire [4:0] exceptR;
wire [63:0] D;
wire [4:0] exceptD;
wire [1023:0] fat_RAM_rddataA;
wire [1023:0] fat_RAM_rddataB;
wire [4:0] R_exceptA;
wire [4:0] R_exceptB;
wire [63:0] D_rddataA; 
wire [4:0] D_exceptA;        
wire [1023:0] R_rddataA;
wire [1023:0] R_rddataB;

wire [3:0] actSelDel;
wire wrenDel;
wire [12:0] wraddrsDel;
wire EarlyRdenDel;
wire [12:0] EarlyRdAddrsDel;
wire SigA_Del; 
wire SigB_Del; 
wire SigD_Del; 
wire [2:0] SizeD_Del;
wire wrenAct;




wire [63:0] X15in ;
wire [15:0] X15cnv;
wire [2:0]  X15GRS;
wire [4:0]  X15exc;

wire [63:0] X14in ;
wire [15:0] X14cnv;
wire [2:0]  X14GRS;
wire [4:0]  X14exc;

wire [63:0] X13in ;
wire [15:0] X13cnv;
wire [2:0]  X13GRS;
wire [4:0]  X13exc;

wire [63:0] X12in ;
wire [15:0] X12cnv;
wire [2:0]  X12GRS;
wire [4:0]  X12exc;

wire [63:0] X11in ;
wire [15:0] X11cnv;
wire [2:0]  X11GRS;
wire [4:0]  X11exc;

wire [63:0] X10in ;
wire [15:0] X10cnv;
wire [2:0]  X10GRS;
wire [4:0]  X10exc;

wire [63:0] X9in ;
wire [15:0] X9cnv;
wire [2:0]  X9GRS;
wire [4:0]  X9exc;

wire [63:0] X8in ;
wire [15:0] X8cnv;
wire [2:0]  X8GRS;
wire [4:0]  X8exc;

wire [63:0] X7in ;
wire [15:0] X7cnv;
wire [2:0]  X7GRS;
wire [4:0]  X7exc;

wire [63:0] X6in ;
wire [15:0] X6cnv;
wire [2:0]  X6GRS;
wire [4:0]  X6exc;

wire [63:0] X5in ;
wire [15:0] X5cnv;
wire [2:0]  X5GRS;
wire [4:0]  X5exc;

wire [63:0] X4in ;
wire [15:0] X4cnv;
wire [2:0]  X4GRS;
wire [4:0]  X4exc;

wire [63:0] X3in ;
wire [15:0] X3cnv;
wire [2:0]  X3GRS;
wire [4:0]  X3exc;

wire [63:0] X2in ;
wire [15:0] X2cnv;
wire [2:0]  X2GRS;
wire [4:0]  X2exc;

wire [63:0] X1in ;
wire [15:0] X1cnv;
wire [2:0]  X1GRS;
wire [4:0]  X1exc;

wire [63:0] X0in ;
wire [15:0] X0cnv;
wire [2:0]  X0GRS;
wire [4:0]  X0exc;


wire [63:0] W15in ;
wire [15:0] W15cnv;
wire [2:0]  W15GRS;
wire [4:0]  W15exc;

wire [63:0] W14in ;
wire [15:0] W14cnv;
wire [2:0]  W14GRS;
wire [4:0]  W14exc;

wire [63:0] W13in ;
wire [15:0] W13cnv;
wire [2:0]  W13GRS;
wire [4:0]  W13exc;

wire [63:0] W12in ;
wire [15:0] W12cnv;
wire [2:0]  W12GRS;
wire [4:0]  W12exc;

wire [63:0] W11in ;
wire [15:0] W11cnv;
wire [2:0]  W11GRS;
wire [4:0]  W11exc;

wire [63:0] W10in ;
wire [15:0] W10cnv;
wire [2:0]  W10GRS;
wire [4:0]  W10exc;

wire [63:0] W9in ;
wire [15:0] W9cnv;
wire [2:0]  W9GRS;
wire [4:0]  W9exc;

wire [63:0] W8in ;
wire [15:0] W8cnv;
wire [2:0]  W8GRS;
wire [4:0]  W8exc;

wire [63:0] W7in ;
wire [15:0] W7cnv;
wire [2:0]  W7GRS;
wire [4:0]  W7exc;

wire [63:0] W6in ;
wire [15:0] W6cnv;
wire [2:0]  W6GRS;
wire [4:0]  W6exc;

wire [63:0] W5in ;
wire [15:0] W5cnv;
wire [2:0]  W5GRS;
wire [4:0]  W5exc;

wire [63:0] W4in ;
wire [15:0] W4cnv;
wire [2:0]  W4GRS;
wire [4:0]  W4exc;

wire [63:0] W3in ;
wire [15:0] W3cnv;
wire [2:0]  W3GRS;
wire [4:0]  W3exc;

wire [63:0] W2in ;
wire [15:0] W2cnv;
wire [2:0]  W2GRS;
wire [4:0]  W2exc;

wire [63:0] W1in ;
wire [15:0] W1cnv;
wire [2:0]  W1GRS;
wire [4:0]  W1exc;

wire [63:0] W0in ;
wire [15:0] W0cnv;
wire [2:0]  W0GRS;
wire [4:0]  W0exc;

assign rddataA = rdenA_del ? R_rddataA[1023:0] : {960'b0, D_rddataA[63:0]};
assign rddataB = R_rddataB[1023:0];
assign exceptA = rdenA_del ? R_exceptA : D_exceptA; 
assign exceptB = R_exceptB;
assign shortPipeEn = ~SigA_Del && ~SigB_Del && ~SigD_Del;

always @(posedge CLK) rdenA_del <= rdenA && ~rdaddrsA[8];

assign X15in = wrdataA[1023:960];
assign X14in = wrdataA[ 959:896];
assign X13in = wrdataA[ 895:832];
assign X12in = wrdataA[ 831:768];
assign X11in = wrdataA[ 767:704];
assign X10in = wrdataA[ 703:640];
assign  X9in = wrdataA[ 639:576];
assign  X8in = wrdataA[ 575:512];
assign  X7in = wrdataA[ 511:448];
assign  X6in = wrdataA[ 447:384];
assign  X5in = wrdataA[ 383:320];
assign  X4in = wrdataA[ 319:256];
assign  X3in = wrdataA[ 255:192];
assign  X2in = wrdataA[ 191:128];
assign  X1in = wrdataA[ 127: 64];
assign  X0in = wrdataA[  63:  0];

assign W15in = wrdataB[1023:960];
assign W14in = wrdataB[ 959:896];
assign W13in = wrdataB[ 895:832];
assign W12in = wrdataB[ 831:768];
assign W11in = wrdataB[ 767:704];
assign W10in = wrdataB[ 703:640];
assign  W9in = wrdataB[ 639:576];
assign  W8in = wrdataB[ 575:512];
assign  W7in = wrdataB[ 511:448];
assign  W6in = wrdataB[ 447:384];
assign  W5in = wrdataB[ 383:320];
assign  W4in = wrdataB[ 319:256];
assign  W3in = wrdataB[ 255:192];
assign  W2in = wrdataB[ 191:128];
assign  W1in = wrdataB[ 127: 64];
assign  W0in = wrdataB[  63:  0];

wire pipeLenSel;
assign pipeLenSel = SigA_q2 || SigB_q2 || SigD_q2; // if either SigA or SigB or SigD = 1 (indicating DecCharSequence) then this signals long pipe

// 6 clocks (long pipe), 1 clock (short pipe)
univ_in_H7 x15(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata(X15in), .binOut(X15cnv), .GRSout(X15GRS), .except(X15exc));
univ_in_H7 x14(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata(X14in), .binOut(X14cnv), .GRSout(X14GRS), .except(X14exc));
univ_in_H7 x13(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata(X13in), .binOut(X13cnv), .GRSout(X13GRS), .except(X13exc));
univ_in_H7 x12(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata(X12in), .binOut(X12cnv), .GRSout(X12GRS), .except(X12exc));
univ_in_H7 x11(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata(X11in), .binOut(X11cnv), .GRSout(X11GRS), .except(X11exc));
univ_in_H7 x10(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata(X10in), .binOut(X10cnv), .GRSout(X10GRS), .except(X10exc));
univ_in_H7  x9(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X9in), .binOut( X9cnv), .GRSout( X9GRS), .except( X9exc));
univ_in_H7  x8(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X8in), .binOut( X8cnv), .GRSout( X8GRS), .except( X8exc));
univ_in_H7  x7(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X7in), .binOut( X7cnv), .GRSout( X7GRS), .except( X7exc));
univ_in_H7  x6(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X6in), .binOut( X6cnv), .GRSout( X6GRS), .except( X6exc));
univ_in_H7  x5(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X5in), .binOut( X5cnv), .GRSout( X5GRS), .except( X5exc));
univ_in_H7  x4(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X4in), .binOut( X4cnv), .GRSout( X4GRS), .except( X4exc));
univ_in_H7  x3(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X3in), .binOut( X3cnv), .GRSout( X3GRS), .except( X3exc));
univ_in_H7  x2(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X2in), .binOut( X2cnv), .GRSout( X2GRS), .except( X2exc));
univ_in_H7  x1(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X1in), .binOut( X1cnv), .GRSout( X1GRS), .except( X1exc));
univ_in_H7  x0(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeA_q2 ), .Sig (SigA_q2), .wrdata( X0in), .binOut( X0cnv), .GRSout( X0GRS), .except( X0exc));

univ_in_H7 w15(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata(W15in), .binOut(W15cnv), .GRSout(W15GRS), .except(W15exc));
univ_in_H7 w14(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata(W14in), .binOut(W14cnv), .GRSout(W14GRS), .except(W14exc));
univ_in_H7 w13(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata(W13in), .binOut(W13cnv), .GRSout(W13GRS), .except(W13exc));
univ_in_H7 w12(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata(W12in), .binOut(W12cnv), .GRSout(W12GRS), .except(W12exc));
univ_in_H7 w11(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata(W11in), .binOut(W11cnv), .GRSout(W11GRS), .except(W11exc));
univ_in_H7 w10(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata(W10in), .binOut(W10cnv), .GRSout(W10GRS), .except(W10exc));
univ_in_H7  w9(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W9in), .binOut( W9cnv), .GRSout( W9GRS), .except( W9exc));
univ_in_H7  w8(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W8in), .binOut( W8cnv), .GRSout( W8GRS), .except( W8exc));
univ_in_H7  w7(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W7in), .binOut( W7cnv), .GRSout( W7GRS), .except( W7exc));
univ_in_H7  w6(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W6in), .binOut( W6cnv), .GRSout( W6GRS), .except( W6exc));
univ_in_H7  w5(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W5in), .binOut( W5cnv), .GRSout( W5GRS), .except( W5exc));
univ_in_H7  w4(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W4in), .binOut( W4cnv), .GRSout( W4GRS), .except( W4exc));
univ_in_H7  w3(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W3in), .binOut( W3cnv), .GRSout( W3GRS), .except( W3exc));
univ_in_H7  w2(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W2in), .binOut( W2cnv), .GRSout( W2GRS), .except( W2exc));
univ_in_H7  w1(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W1in), .binOut( W1cnv), .GRSout( W1GRS), .except( W1exc));
univ_in_H7  w0(.CLK (CLK), .RESET (RESET), .wren (wren), .pipeLenSel (pipeLenSel), .Size (SizeB_q2 ), .Sig (SigB_q2), .wrdata( W0in), .binOut( W0cnv), .GRSout( W0GRS), .except( W0exc));

wire [15:0] RXW15;
wire [15:0] RXW14;
wire [15:0] RXW13;
wire [15:0] RXW12;
wire [15:0] RXW11;
wire [15:0] RXW10;
wire [15:0] RXW9;
wire [15:0] RXW8;
wire [15:0] RXW7;
wire [15:0] RXW6;
wire [15:0] RXW5;
wire [15:0] RXW4;
wire [15:0] RXW3;
wire [15:0] RXW2;
wire [15:0] RXW1;
wire [15:0] RXW0;

wire  [2:0] GXW15;
wire  [2:0] GXW14;
wire  [2:0] GXW13;
wire  [2:0] GXW12;
wire  [2:0] GXW11;
wire  [2:0] GXW10;
wire  [2:0] GXW9;
wire  [2:0] GXW8;
wire  [2:0] GXW7;
wire  [2:0] GXW6;
wire  [2:0] GXW5;
wire  [2:0] GXW4;
wire  [2:0] GXW3;
wire  [2:0] GXW2;
wire  [2:0] GXW1;
wire  [2:0] GXW0;

wire [4:0] X15except;
wire [4:0] X14except;
wire [4:0] X13except;
wire [4:0] X12except;
wire [4:0] X11except;
wire [4:0] X10except;
wire [4:0]  X9except;
wire [4:0]  X8except;
wire [4:0]  X7except;
wire [4:0]  X6except;
wire [4:0]  X5except;
wire [4:0]  X4except;
wire [4:0]  X3except;
wire [4:0]  X2except;
wire [4:0]  X1except;
wire [4:0]  X0except;

// 1 clock
FMUL711 XW15(.CLK (CLK), .A (X15cnv), .GRSinA(X15GRS), .B (W15cnv), .GRSinB (W15GRS), .R (RXW15), .GRSout(GXW15), .except(X15except));
FMUL711 XW14(.CLK (CLK), .A (X14cnv), .GRSinA(X14GRS), .B (W14cnv), .GRSinB (W14GRS), .R (RXW14), .GRSout(GXW14), .except(X14except));
FMUL711 XW13(.CLK (CLK), .A (X13cnv), .GRSinA(X13GRS), .B (W13cnv), .GRSinB (W13GRS), .R (RXW13), .GRSout(GXW13), .except(X13except));
FMUL711 XW12(.CLK (CLK), .A (X12cnv), .GRSinA(X12GRS), .B (W12cnv), .GRSinB (W12GRS), .R (RXW12), .GRSout(GXW12), .except(X12except));
FMUL711 XW11(.CLK (CLK), .A (X11cnv), .GRSinA(X11GRS), .B (W11cnv), .GRSinB (W11GRS), .R (RXW11), .GRSout(GXW11), .except(X11except));
FMUL711 XW10(.CLK (CLK), .A (X10cnv), .GRSinA(X10GRS), .B (W10cnv), .GRSinB (W10GRS), .R (RXW10), .GRSout(GXW10), .except(X10except));
FMUL711  XW9(.CLK (CLK), .A ( X9cnv), .GRSinA( X9GRS), .B ( W9cnv), .GRSinB ( W9GRS), .R ( RXW9), .GRSout( GXW9), .except( X9except));
FMUL711  XW8(.CLK (CLK), .A ( X8cnv), .GRSinA( X8GRS), .B ( W8cnv), .GRSinB ( W8GRS), .R ( RXW8), .GRSout( GXW8), .except( X8except));
FMUL711  XW7(.CLK (CLK), .A ( X7cnv), .GRSinA( X7GRS), .B ( W7cnv), .GRSinB ( W7GRS), .R ( RXW7), .GRSout( GXW7), .except( X7except));
FMUL711  XW6(.CLK (CLK), .A ( X6cnv), .GRSinA( X6GRS), .B ( W6cnv), .GRSinB ( W6GRS), .R ( RXW6), .GRSout( GXW6), .except( X6except));
FMUL711  XW5(.CLK (CLK), .A ( X5cnv), .GRSinA( X5GRS), .B ( W5cnv), .GRSinB ( W5GRS), .R ( RXW5), .GRSout( GXW5), .except( X5except));
FMUL711  XW4(.CLK (CLK), .A ( X4cnv), .GRSinA( X4GRS), .B ( W4cnv), .GRSinB ( W4GRS), .R ( RXW4), .GRSout( GXW4), .except( X4except));
FMUL711  XW3(.CLK (CLK), .A ( X3cnv), .GRSinA( X3GRS), .B ( W3cnv), .GRSinB ( W3GRS), .R ( RXW3), .GRSout( GXW3), .except( X3except));
FMUL711  XW2(.CLK (CLK), .A ( X2cnv), .GRSinA( X2GRS), .B ( W2cnv), .GRSinB ( W2GRS), .R ( RXW2), .GRSout( GXW2), .except( X2except));
FMUL711  XW1(.CLK (CLK), .A ( X1cnv), .GRSinA( X1GRS), .B ( W1cnv), .GRSinB ( W1GRS), .R ( RXW1), .GRSout( GXW1), .except( X1except));
FMUL711  XW0(.CLK (CLK), .A ( X0cnv), .GRSinA( X0GRS), .B ( W0cnv), .GRSinB ( W0GRS), .R ( RXW0), .GRSout( GXW0), .except( X0except));

wire [15:0] Radd15_14;
wire [15:0] Radd13_12;
wire [15:0] Radd11_10;
wire [15:0] Radd9_8;
wire [15:0] Radd7_6;
wire [15:0] Radd5_4;
wire [15:0] Radd3_2;
wire [15:0] Radd1_0;

wire [2:0] Gadd15_14;
wire [2:0] Gadd13_12;
wire [2:0] Gadd11_10;
wire [2:0] Gadd9_8;
wire [2:0] Gadd7_6;
wire [2:0] Gadd5_4;
wire [2:0] Gadd3_2;
wire [2:0] Gadd1_0;

wire [4:0] exceptAdd15_14;
wire [4:0] exceptAdd13_12;
wire [4:0] exceptAdd11_10;
wire [4:0] exceptAdd9_8  ;
wire [4:0] exceptAdd7_6  ;
wire [4:0] exceptAdd5_4  ;
wire [4:0] exceptAdd3_2  ;
wire [4:0] exceptAdd1_0  ;

// 0 clocks
FADD711noClk add15_14(.A (RXW15), .GRSinA (GXW15), .B (RXW14), .GRSinB(GXW14), .R (Radd15_14), .GRSout(Gadd15_14), .except(exceptAdd15_14));
FADD711noClk add13_12(.A (RXW13), .GRSinA (GXW13), .B (RXW12), .GRSinB(GXW12), .R (Radd13_12), .GRSout(Gadd13_12), .except(exceptAdd13_12));
FADD711noClk add11_10(.A (RXW11), .GRSinA (GXW11), .B (RXW10), .GRSinB(GXW10), .R (Radd11_10), .GRSout(Gadd11_10), .except(exceptAdd11_10));
FADD711noClk   add9_8(.A (RXW9 ), .GRSinA (GXW9 ), .B (RXW8 ), .GRSinB(GXW8 ), .R (Radd9_8  ), .GRSout(Gadd9_8  ), .except(exceptAdd9_8  ));
FADD711noClk   add7_6(.A (RXW7 ), .GRSinA (GXW7 ), .B (RXW6 ), .GRSinB(GXW6 ), .R (Radd7_6  ), .GRSout(Gadd7_6  ), .except(exceptAdd7_6  ));
FADD711noClk   add5_4(.A (RXW5 ), .GRSinA (GXW5 ), .B (RXW4 ), .GRSinB(GXW4 ), .R (Radd5_4  ), .GRSout(Gadd5_4  ), .except(exceptAdd5_4  ));
FADD711noClk   add3_2(.A (RXW3 ), .GRSinA (GXW3 ), .B (RXW2 ), .GRSinB(GXW2 ), .R (Radd3_2  ), .GRSout(Gadd3_2  ), .except(exceptAdd3_2  ));
FADD711noClk   add1_0(.A (RXW1 ), .GRSinA (GXW1 ), .B (RXW0 ), .GRSinB(GXW0 ), .R (Radd1_0  ), .GRSout(Gadd1_0  ), .except(exceptAdd1_0  ));

wire [15:0] Radd15_14_13_12;
wire [15:0] Radd11_10_9_8;
wire [15:0] Radd7_6_5_4;
wire [15:0] Radd3_2_1_0;

wire [2:0] Gadd15_14_13_12;
wire [2:0] Gadd11_10_9_8;
wire [2:0] Gadd7_6_5_4;
wire [2:0] Gadd3_2_1_0;

wire [4:0] exceptAdd15_14_13_12;
wire [4:0] exceptAdd11_10_9_8  ;
wire [4:0] exceptAdd7_6_5_4    ;
wire [4:0] exceptAdd3_2_1_0    ;

// 1 clock
FADD711 add15_14_13_12(.CLK (CLK), .A (Radd15_14), .GRSinA (Gadd15_14), .B (Radd13_12), .GRSinB (Gadd13_12), .R (Radd15_14_13_12), .GRSout (Gadd15_14_13_12), .except(exceptAdd15_14_13_12) );      
FADD711 add11_10_9_8  (.CLK (CLK), .A (Radd11_10), .GRSinA (Gadd11_10), .B (Radd9_8),   .GRSinB (Gadd9_8),   .R (Radd11_10_9_8),   .GRSout (Gadd11_10_9_8)  , .except(exceptAdd11_10_9_8  ) );      
FADD711 add7_6_5_4    (.CLK (CLK), .A (Radd7_6),   .GRSinA (Gadd7_6),   .B (Radd5_4),   .GRSinB (Gadd5_4),   .R (Radd7_6_5_4),     .GRSout (Gadd7_6_5_4)    , .except(exceptAdd7_6_5_4    ) );      
FADD711 add3_2_1_0    (.CLK (CLK), .A (Radd3_2),   .GRSinA (Gadd3_2),   .B (Radd1_0),   .GRSinB (Gadd1_0),   .R (Radd3_2_1_0),     .GRSout (Gadd3_2_1_0)    , .except(exceptAdd3_2_1_0    ) );

wire [15:0] Radd15_14_13_12_11_10_9_8;
wire [15:0] Radd7_6_5_4_3_2_1_0;     

wire [2:0] Gadd15_14_13_12_11_10_9_8;
wire [2:0] Gadd7_6_5_4_3_2_1_0;   

wire [4:0] exceptAdd15_14_13_12_11_10_9_8;  
wire [4:0] exceptAdd7_6_5_4_3_2_1_0;  
 
// 0 clocks
FADD711noClk add15_14_13_12_11_10_9_8(.A (Radd15_14_13_12), .GRSinA (Gadd15_14_13_12), .B (Radd11_10_9_8), .GRSinB(Gadd11_10_9_8), .R (Radd15_14_13_12_11_10_9_8), .GRSout(Gadd15_14_13_12_11_10_9_8), .except(exceptAdd15_14_13_12_11_10_9_8));
FADD711noClk       add7_6_5_4_3_2_1_0(.A (Radd7_6_5_4),     .GRSinA (Gadd7_6_5_4),     .B (Radd3_2_1_0),   .GRSinB(Gadd3_2_1_0),   .R (Radd7_6_5_4_3_2_1_0),       .GRSout(Gadd7_6_5_4_3_2_1_0)      , .except(exceptAdd7_6_5_4_3_2_1_0));

wire [15:0] RaddFinal;
wire [2:0]  GaddFinal;
wire [4:0] exceptAddFinal;

// 1 clock                        4s
FADD711 addFinal(.CLK (CLK), .A (Radd15_14_13_12_11_10_9_8), .GRSinA (Gadd15_14_13_12_11_10_9_8), .B (Radd7_6_5_4_3_2_1_0), .GRSinB (Gadd7_6_5_4_3_2_1_0), .R (RaddFinal), .GRSout (GaddFinal), .except(exceptAddFinal));      

// 1 clock
wire ADT_Del;
wire [15:0] R_accum;
wire [18:0] C_accum;
wire [2:0] GRS_accum;
wire [4:0] exceptAccum;    //might want to make this adder fatter, at least range-wise
FADD711 addAccum(.CLK (CLK), .A (RaddFinal), .GRSinA (GaddFinal), .B (ADT_Del ? C_accum[18:3] : 16'h0000), .GRSinB (ADT_Del ? C_accum[2:0] : 3'b000), .R (R_accum), .GRSout (GRS_accum), .except(exceptAccum) );      

wire [15:0] XWdiv;
wire [2:0] XWdivGRS;
wire [4:0] XWdivExcept;
FDIV711 fdiv(    // 4 clocks  --used mainly for computing SoftMax, but can be general purpose within 1|7|8 range
    .CLK   (CLK  ),
    .RESET (RESET),
    .A     (X0cnv),
    .GRSinA(X0GRS),
    .B     (W0cnv),
    .GRSinB(X0GRS),
    .R     (XWdiv),
    .GRSout(XWdivGRS),
    .except(XWdivExcept)
    );
     
FuNN_delays delays(
    .CLK      (CLK   ),
    .RESET    (RESET ),
    .ADT      (ADT   ),                   //1 = add total, 0 = add zero
    .actSel   (ACT ? actSel : 4'b0000),   //ACT = 1 = enable activation, 0 = bypass
    .wren     (wren  ),
    .wraddrs  (wraddrs[12:0]),
    .SigA_q2  (SigA_q2),
    .SigB_q2  (SigB_q2),
    .SigD_q2  (SigD_q2),
    .SizeD_q2 (SizeD_q2),
 
    .ADT_Del  (ADT_Del),         
    .wrenAct  (wrenAct),         
    .SigA_Del (SigA_Del),        
    .SigB_Del (SigB_Del),        
    .SigD_Del (SigD_Del),        
    .SizeD_Del(SizeD_Del),       
    .actSelDel(actSelDel[3:0]),  
    .wrenDel(wrenDel),           
    .wraddrsDel(wraddrsDel[12:0]),                                  
    .EarlyRdenDel(EarlyRdenDel),                                    
    .EarlyRdAddrsDel(EarlyRdAddrsDel[12:0])   
    );

wire [1023:0] hardMax;
wire [15:0] classOneHot;
wire [15:0] classTooHot;
wire [31:0] maxProb;
Activ_H7 activ(            //7 clocks (long pipe), 1 clock (short pipe)
    .CLK   (CLK),
    .RESET (RESET),
    .wren  (wrenAct),
    .shortPipeEn(shortPipeEn),
    .SigD  (SigD_Del ),
    .SizeD (SizeD_Del),
    .actSel(actSelDel),
    .X     (R_accum),
    .GRSin (GRS_accum),
    .exceptX(exceptAccum),
    .XWdiv      (XWdiv),
    .XWdivGRS   (XWdivGRS),
    .XWdivExcept(XWdivExcept),
    .R_conv(R),
    .R78(R78),  //for C accumulator
    .exceptR_conv(exceptR),
    .D_conv(D),
    .exceptD_conv(exceptD),
    .RXW0 (RXW0 ),
    .GXW0 (GXW0 ),
    .RXW1 (RXW1 ),
    .GXW1 (GXW1 ),
    .RXW2 (RXW2 ),
    .GXW2 (GXW2 ),
    .RXW3 (RXW3 ),
    .GXW3 (GXW3 ),
    .RXW4 (RXW4 ),
    .GXW4 (GXW4 ),
    .RXW5 (RXW5 ),
    .GXW5 (GXW5 ),
    .RXW6 (RXW6 ),
    .GXW6 (GXW6 ),
    .RXW7 (RXW7 ),
    .GXW7 (GXW7 ),
    .RXW8 (RXW8 ),
    .GXW8 (GXW8 ),
    .RXW9 (RXW9 ),
    .GXW9 (GXW9 ),
    .RXW10(RXW10),
    .GXW10(GXW10),
    .RXW11(RXW11),
    .GXW11(GXW11),
    .RXW12(RXW12),
    .GXW12(GXW12),
    .RXW13(RXW13),
    .GXW13(GXW13),
    .RXW14(RXW14),
    .GXW14(GXW14),
    .RXW15(RXW15),
    .GXW15(GXW15),
    .hardMax_sel(hardMax_sel),
    .hardMax(hardMax),
    .classOneHot(classOneHot),
    .classTooHot(classTooHot),
    .maxProb(maxProb)
    );

    
//threePortFatRAMx1024 #(.ADDRS_WIDTH(8))  //256 gob-deep x 128 bytes-wide  (32768 bytes total)
threePortFatRAMx1024 #(.ADDRS_WIDTH(4))    //16 gob-deep x 128 bytes-wide  (2048 bytes total)
    resultBuf( 
    .CLK       (CLK   ),
    .wren      (wrenDel ),
    .wrsize    ({hardMax_sel, 2'b11}),        // at the moment, all writes are either 8bytes or 128 bytes
    .wraddrs   ({wraddrsDel[7:0], 3'b000}),   //8byte aligned address
    .wrdata    (hardMax_sel ? hardMax : {960'b0, R[63:0]}),          
    .rdenA     (rdenA && ~rdaddrsA[8]),
    .rdAsize   (SizeA_q0[2:0]),                                                     
    .rdaddrsA  ({rdaddrsA[7:0], 3'b000}),     //byte address                                
    .rddataA   (R_rddataA[1023:0]),                                               
    .rdenB     (rdenB && ~rdaddrsB[8]),                                                       
    .rdBsize   (SizeB_q0[2:0]),     
    .rdaddrsB  ({rdaddrsB[7:0], 3'b000}),    //byte address
    .rddataB   (R_rddataB[1023:0])
    );    

RAM_func_dp #(.ADDRS_WIDTH(8), .DATA_WIDTH(19))  //this memory is not per se visible to external world
  C_acc(                                         //might want to make this fatter
    .CLK(CLK),
    .RESET(RESET),
    .wren(wrenDel),                              //same as result memory
    .wraddrs(wraddrsDel[7:0]),
    .wrdata(R78[18:0]),                          //binary 7|8 format only, but with GRS
    .rden(EarlyRdenDel && ~EarlyRdAddrsDel[8]),  // read only when activation is "accumulate"
    .rdaddrs(EarlyRdAddrsDel[7:0]),              // read address is an early write address
    .rddata(C_accum[18:0])
    );    


RAM_func #(.ADDRS_WIDTH(8), .DATA_WIDTH(5))      // result exception memory
  R_except(
    .CLK(CLK),
    .wren(wrenDel ),
    .wraddrs(wraddrsDel[7:0]),
    .wrdata(exceptR),
    .rdenA(rdenA && ~rdaddrsA[8]),
    .rdaddrsA(rdaddrsA[7:0]),
    .rddataA(R_exceptA),
    .rdenB(rdenB && ~rdaddrsB[8]),
    .rdaddrsB(rdaddrsB[7:0]),
    .rddataB(R_exceptB)
    );    
                                                                
RAM_func_dp #(.ADDRS_WIDTH(8), .DATA_WIDTH(64))                 
derivative(
    .CLK(CLK),
    .RESET(RESET),
    .wren(wrenDel),
    .wraddrs(wraddrsDel[7:0]),
    .wrdata(hardMax_sel ? {classTooHot, classOneHot, maxProb} : D[63:0]),	//classTooHot reveals other outputs also
    .rden(rdenA && rdaddrsA[8]),											//registering a "1", i.e., same probability
    .rdaddrs(rdaddrsA[7:0]),
    .rddata(D_rddataA[63:0])
    ); 
       
RAM_func_dp #(.ADDRS_WIDTH(8), .DATA_WIDTH(5)) 
D_except(
    .CLK(CLK),
    .RESET(RESET),
    .wren(wrenDel),
    .wraddrs(wraddrsDel[7:0]),
    .wrdata(exceptD),
    .rden(rdenA && rdaddrsA[8]),
    .rdaddrs(rdaddrsA[7:0]),
    .rddata(D_exceptA[4:0])
    );    

always @(posedge CLK) begin
    if (RESET) semaphor <= {256{1'b1}};    //one bit per node/cell
    else begin
        if (wren && ~restore) semaphor[wraddrs[7:0]] <= 1'b0;
        if (wrenDel) semaphor[wraddrsDel[7:0]] <= 1'b1;
    end
end     

always @(*) begin
    if (RESET) begin
        readyA_q0 = 1'b1;
        readyB_q0 = 1'b1;
    end  
    else begin
         if ((SizeA_q0==3'b111) && rdenA) readyA_q0 = (semaphor[rdaddrsA[7:0]   ] && 
                                                       semaphor[rdaddrsA[7:0]+1 ] &&
                                                       semaphor[rdaddrsA[7:0]+2 ] &&
                                                       semaphor[rdaddrsA[7:0]+3 ] &&
                                                       semaphor[rdaddrsA[7:0]+4 ] &&
                                                       semaphor[rdaddrsA[7:0]+5 ] &&
                                                       semaphor[rdaddrsA[7:0]+6 ] &&
                                                       semaphor[rdaddrsA[7:0]+7 ] &&
                                                       semaphor[rdaddrsA[7:0]+8 ] &&
                                                       semaphor[rdaddrsA[7:0]+9 ] &&
                                                       semaphor[rdaddrsA[7:0]+10] &&
                                                       semaphor[rdaddrsA[7:0]+11] &&
                                                       semaphor[rdaddrsA[7:0]+12] &&
                                                       semaphor[rdaddrsA[7:0]+13] &&
                                                       semaphor[rdaddrsA[7:0]+14] &&
                                                       semaphor[rdaddrsA[7:0]+15]);

         else if ((SizeA_q0==3'b011) && rdenA) readyA_q0 = semaphor[rdaddrsA[7:0]   ]; 
         else readyA_q0 = 1'b1;
         
         if ((SizeB_q0==3'b111) && rdenB) readyB_q0 = (semaphor[rdaddrsB[7:0]   ] && 
                                                       semaphor[rdaddrsB[7:0]+1 ] &&
                                                       semaphor[rdaddrsB[7:0]+2 ] &&
                                                       semaphor[rdaddrsB[7:0]+3 ] &&
                                                       semaphor[rdaddrsB[7:0]+4 ] &&
                                                       semaphor[rdaddrsB[7:0]+5 ] &&
                                                       semaphor[rdaddrsB[7:0]+6 ] &&
                                                       semaphor[rdaddrsB[7:0]+7 ] &&
                                                       semaphor[rdaddrsB[7:0]+8 ] &&
                                                       semaphor[rdaddrsB[7:0]+9 ] &&
                                                       semaphor[rdaddrsB[7:0]+10] &&
                                                       semaphor[rdaddrsB[7:0]+11] &&
                                                       semaphor[rdaddrsB[7:0]+12] &&
                                                       semaphor[rdaddrsB[7:0]+13] &&
                                                       semaphor[rdaddrsB[7:0]+14] &&
                                                       semaphor[rdaddrsB[7:0]+15]);

         else if ((SizeB_q0==3'b011) && rdenB) readyB_q0 = semaphor[rdaddrsB[7:0]   ]; 
         else readyB_q0 = 1'b1;

    end   
end

always @(posedge CLK)
    if (RESET) begin
        readyA <= readyA_q0;
        readyB <= readyB_q0;
    end  
    else begin
        readyA <= readyA_q0;
        readyB <= readyB_q0;
    end
endmodule
