//HardMax_H7.v
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

module HardMax_H7(
    CLK,
    RESET,
    shortPipeEn,
    wren,       
    SigD,       
    SizeD,      
    x0,
    x0GRS,
    x1,
    x1GRS,
    x2,
    x2GRS,
    x3,
    x3GRS,
    x4,
    x4GRS,
    x5,
    x5GRS,
    x6,
    x6GRS,
    x7,
    x7GRS,
    x8,
    x8GRS,
    x9,
    x9GRS,
    x10,
    x10GRS,
    x11,
    x11GRS,
    x12,
    x12GRS,
    x13,
    x13GRS,
    x14,
    x14GRS,
    x15,
    x15GRS,
    R,
    classOneHot,
    classTooHot,
    maxProb
    );
    
input  CLK;
input  RESET;
input  shortPipeEn;
input  wren;       
input  SigD;       
input  [2:0] SizeD;      
input [15:0] x0;
input  [2:0] x0GRS;
input [15:0] x1;
input  [2:0] x1GRS;
input [15:0] x2;
input  [2:0] x2GRS;
input [15:0] x3;
input  [2:0] x3GRS;
input [15:0] x4;
input  [2:0] x4GRS;
input [15:0] x5;
input  [2:0] x5GRS;
input [15:0] x6;
input  [2:0] x6GRS;
input [15:0] x7;
input  [2:0] x7GRS;
input [15:0] x8;
input  [2:0] x8GRS;
input [15:0] x9;
input  [2:0] x9GRS;
input [15:0] x10;
input  [2:0] x10GRS;
input [15:0] x11;
input  [2:0] x11GRS;
input [15:0] x12;
input  [2:0] x12GRS;
input [15:0] x13;
input  [2:0] x13GRS;
input [15:0] x14;
input  [2:0] x14GRS;
input [15:0] x15;
input  [2:0] x15GRS;
output [1023:0] R;     //result is either text 128-byte one-hot or binary 128-byte one-hot in either binary64, binary32, or bfloat16
output [15:0] classOneHot;   //16-bit one-hot i.e., prioritized classification
output [15:0] classTooHot;   // not-only-one-hot, in initial training, there may be more than one output value that is the same as one or more others
output [31:0] maxProb; //binary32 representation of the maximum value  

wire [18:0] xi0 ;
wire [18:0] xi1 ;                                                                                                
wire [18:0] xi2 ;                                                                                                
wire [18:0] xi3 ;
wire [18:0] xi4 ;
wire [18:0] xi5 ;
wire [18:0] xi6 ;
wire [18:0] xi7 ;
wire [18:0] xi8 ;
wire [18:0] xi9 ;
wire [18:0] xi10;
wire [18:0] xi11;
wire [18:0] xi12;
wire [18:0] xi13;
wire [18:0] xi14;
wire [18:0] xi15;

assign xi0  = { ~x0[15],  x0[14:0],  x0GRS[2:0]}; 
assign xi1  = { ~x1[15],  x1[14:0],  x1GRS[2:0]};
assign xi2  = { ~x2[15],  x2[14:0],  x2GRS[2:0]};
assign xi3  = { ~x3[15],  x3[14:0],  x3GRS[2:0]};
assign xi4  = { ~x4[15],  x4[14:0],  x4GRS[2:0]};
assign xi5  = { ~x5[15],  x5[14:0],  x5GRS[2:0]};
assign xi6  = { ~x6[15],  x6[14:0],  x6GRS[2:0]};
assign xi7  = { ~x7[15],  x7[14:0],  x7GRS[2:0]};
assign xi8  = { ~x8[15],  x8[14:0],  x8GRS[2:0]};
assign xi9  = { ~x9[15],  x9[14:0],  x9GRS[2:0]};
assign xi10 = {~x10[15], x10[14:0], x10GRS[2:0]};
assign xi11 = {~x11[15], x11[14:0], x11GRS[2:0]};
assign xi12 = {~x12[15], x12[14:0], x12GRS[2:0]};
assign xi13 = {~x13[15], x13[14:0], x13GRS[2:0]};
assign xi14 = {~x14[15], x14[14:0], x14GRS[2:0]};
assign xi15 = {~x15[15], x15[14:0], x15GRS[2:0]};

wire x0IsMax;
wire x1IsMax;
wire x2IsMax;
wire x3IsMax;
wire x4IsMax;
wire x5IsMax;
wire x6IsMax;
wire x7IsMax;
wire x8IsMax;
wire x9IsMax;
wire x10IsMax;
wire x11IsMax;
wire x12IsMax;
wire x13IsMax;
wire x14IsMax;
wire x15IsMax;

wire xi0_GTE_xi1;
wire xi0_GTE_xi2;
wire xi0_GTE_xi3;
wire xi0_GTE_xi4;
wire xi0_GTE_xi5;
wire xi0_GTE_xi6;
wire xi0_GTE_xi7;
wire xi0_GTE_xi8;
wire xi0_GTE_xi9;
wire xi0_GTE_xi10;
wire xi0_GTE_xi11;
wire xi0_GTE_xi12;
wire xi0_GTE_xi13;
wire xi0_GTE_xi14;
wire xi0_GTE_xi15;

wire xi1_GTE_xi0;
wire xi1_GTE_xi2;
wire xi1_GTE_xi3;
wire xi1_GTE_xi4;
wire xi1_GTE_xi5;
wire xi1_GTE_xi6;
wire xi1_GTE_xi7;
wire xi1_GTE_xi8;
wire xi1_GTE_xi9;
wire xi1_GTE_xi10;
wire xi1_GTE_xi11;
wire xi1_GTE_xi12;
wire xi1_GTE_xi13;
wire xi1_GTE_xi14;
wire xi1_GTE_xi15;

wire xi2_GTE_xi0;
wire xi2_GTE_xi1;
wire xi2_GTE_xi3;
wire xi2_GTE_xi4;
wire xi2_GTE_xi5;
wire xi2_GTE_xi6;
wire xi2_GTE_xi7;
wire xi2_GTE_xi8;
wire xi2_GTE_xi9;
wire xi2_GTE_xi10;
wire xi2_GTE_xi11;
wire xi2_GTE_xi12;
wire xi2_GTE_xi13;
wire xi2_GTE_xi14;
wire xi2_GTE_xi15;

wire xi3_GTE_xi0;
wire xi3_GTE_xi1;
wire xi3_GTE_xi2;
wire xi3_GTE_xi4;
wire xi3_GTE_xi5;
wire xi3_GTE_xi6;
wire xi3_GTE_xi7;
wire xi3_GTE_xi8;
wire xi3_GTE_xi9;
wire xi3_GTE_xi10;
wire xi3_GTE_xi11;
wire xi3_GTE_xi12;
wire xi3_GTE_xi13;
wire xi3_GTE_xi14;
wire xi3_GTE_xi15;

wire xi4_GTE_xi0;
wire xi4_GTE_xi1;
wire xi4_GTE_xi2;
wire xi4_GTE_xi3;
wire xi4_GTE_xi5;
wire xi4_GTE_xi6;
wire xi4_GTE_xi7;
wire xi4_GTE_xi8;
wire xi4_GTE_xi9;
wire xi4_GTE_xi10;
wire xi4_GTE_xi11;
wire xi4_GTE_xi12;
wire xi4_GTE_xi13;
wire xi4_GTE_xi14;
wire xi4_GTE_xi15;

wire xi5_GTE_xi0;
wire xi5_GTE_xi1;
wire xi5_GTE_xi2;
wire xi5_GTE_xi3;
wire xi5_GTE_xi4;
wire xi5_GTE_xi6;
wire xi5_GTE_xi7;
wire xi5_GTE_xi8;
wire xi5_GTE_xi9;
wire xi5_GTE_xi10;
wire xi5_GTE_xi11;
wire xi5_GTE_xi12;
wire xi5_GTE_xi13;
wire xi5_GTE_xi14;
wire xi5_GTE_xi15;

wire xi6_GTE_xi0;
wire xi6_GTE_xi1;
wire xi6_GTE_xi2;
wire xi6_GTE_xi3;
wire xi6_GTE_xi4;
wire xi6_GTE_xi5;
wire xi6_GTE_xi7;
wire xi6_GTE_xi8;
wire xi6_GTE_xi9;
wire xi6_GTE_xi10;
wire xi6_GTE_xi11;
wire xi6_GTE_xi12;
wire xi6_GTE_xi13;
wire xi6_GTE_xi14;
wire xi6_GTE_xi15;

wire xi7_GTE_xi0;
wire xi7_GTE_xi1;
wire xi7_GTE_xi2;
wire xi7_GTE_xi3;
wire xi7_GTE_xi4;
wire xi7_GTE_xi5;
wire xi7_GTE_xi6;
wire xi7_GTE_xi8;
wire xi7_GTE_xi9;
wire xi7_GTE_xi10;
wire xi7_GTE_xi11;
wire xi7_GTE_xi12;
wire xi7_GTE_xi13;
wire xi7_GTE_xi14;
wire xi7_GTE_xi15;

wire xi8_GTE_xi0;
wire xi8_GTE_xi1;
wire xi8_GTE_xi2;
wire xi8_GTE_xi3;
wire xi8_GTE_xi4;
wire xi8_GTE_xi5;
wire xi8_GTE_xi6;
wire xi8_GTE_xi7;
wire xi8_GTE_xi9;
wire xi8_GTE_xi10;
wire xi8_GTE_xi11;
wire xi8_GTE_xi12;
wire xi8_GTE_xi13;
wire xi8_GTE_xi14;
wire xi8_GTE_xi15;

wire xi9_GTE_xi0;
wire xi9_GTE_xi1;
wire xi9_GTE_xi2;
wire xi9_GTE_xi3;
wire xi9_GTE_xi4;
wire xi9_GTE_xi5;
wire xi9_GTE_xi6;
wire xi9_GTE_xi7;
wire xi9_GTE_xi8;
wire xi9_GTE_xi10;
wire xi9_GTE_xi11;
wire xi9_GTE_xi12;
wire xi9_GTE_xi13;
wire xi9_GTE_xi14;
wire xi9_GTE_xi15;

wire xi10_GTE_xi0;
wire xi10_GTE_xi1;
wire xi10_GTE_xi2;
wire xi10_GTE_xi3;
wire xi10_GTE_xi4;
wire xi10_GTE_xi5;
wire xi10_GTE_xi6;
wire xi10_GTE_xi7;
wire xi10_GTE_xi8;
wire xi10_GTE_xi9;
wire xi10_GTE_xi11;
wire xi10_GTE_xi12;
wire xi10_GTE_xi13;
wire xi10_GTE_xi14;
wire xi10_GTE_xi15;

wire xi11_GTE_xi0;
wire xi11_GTE_xi1;
wire xi11_GTE_xi2;
wire xi11_GTE_xi3;
wire xi11_GTE_xi4;
wire xi11_GTE_xi5;
wire xi11_GTE_xi6;
wire xi11_GTE_xi7;
wire xi11_GTE_xi8;
wire xi11_GTE_xi9;
wire xi11_GTE_xi10;
wire xi11_GTE_xi12;
wire xi11_GTE_xi13;
wire xi11_GTE_xi14;
wire xi11_GTE_xi15;

wire xi12_GTE_xi0;
wire xi12_GTE_xi1;
wire xi12_GTE_xi2;
wire xi12_GTE_xi3;
wire xi12_GTE_xi4;
wire xi12_GTE_xi5;
wire xi12_GTE_xi6;
wire xi12_GTE_xi7;
wire xi12_GTE_xi8;
wire xi12_GTE_xi9;
wire xi12_GTE_xi10;
wire xi12_GTE_xi11;
wire xi12_GTE_xi13;
wire xi12_GTE_xi14;
wire xi12_GTE_xi15;

wire xi13_GTE_xi0;
wire xi13_GTE_xi1;
wire xi13_GTE_xi2;
wire xi13_GTE_xi3;
wire xi13_GTE_xi4;
wire xi13_GTE_xi5;
wire xi13_GTE_xi6;
wire xi13_GTE_xi7;
wire xi13_GTE_xi8;
wire xi13_GTE_xi9;
wire xi13_GTE_xi10;
wire xi13_GTE_xi11;
wire xi13_GTE_xi12;
wire xi13_GTE_xi14;
wire xi13_GTE_xi15;

wire xi14_GTE_xi0;
wire xi14_GTE_xi1;
wire xi14_GTE_xi2;
wire xi14_GTE_xi3;
wire xi14_GTE_xi4;
wire xi14_GTE_xi5;
wire xi14_GTE_xi6;
wire xi14_GTE_xi7;
wire xi14_GTE_xi8;
wire xi14_GTE_xi9;
wire xi14_GTE_xi10;
wire xi14_GTE_xi11;
wire xi14_GTE_xi12;
wire xi14_GTE_xi13;
wire xi14_GTE_xi15;

wire xi15_GTE_xi0;
wire xi15_GTE_xi1;
wire xi15_GTE_xi2;
wire xi15_GTE_xi3;
wire xi15_GTE_xi4;
wire xi15_GTE_xi5;
wire xi15_GTE_xi6;
wire xi15_GTE_xi7;
wire xi15_GTE_xi8;
wire xi15_GTE_xi9;
wire xi15_GTE_xi10;
wire xi15_GTE_xi11;
wire xi15_GTE_xi12;
wire xi15_GTE_xi13;
wire xi15_GTE_xi14;

assign xi0_GTE_xi1  = xi0 >= xi1 ;
assign xi0_GTE_xi2  = xi0 >= xi2 ;
assign xi0_GTE_xi3  = xi0 >= xi3 ;
assign xi0_GTE_xi4  = xi0 >= xi4 ;
assign xi0_GTE_xi5  = xi0 >= xi5 ;
assign xi0_GTE_xi6  = xi0 >= xi6 ;
assign xi0_GTE_xi7  = xi0 >= xi7 ;
assign xi0_GTE_xi8  = xi0 >= xi8 ;
assign xi0_GTE_xi9  = xi0 >= xi9 ;
assign xi0_GTE_xi10 = xi0 >= xi10;
assign xi0_GTE_xi11 = xi0 >= xi11;
assign xi0_GTE_xi12 = xi0 >= xi12;
assign xi0_GTE_xi13 = xi0 >= xi13;
assign xi0_GTE_xi14 = xi0 >= xi14;
assign xi0_GTE_xi15 = xi0 >= xi15;

assign xi1_GTE_xi0  = xi1 >= xi0 ;
assign xi1_GTE_xi2  = xi1 >= xi2 ;
assign xi1_GTE_xi3  = xi1 >= xi3 ;
assign xi1_GTE_xi4  = xi1 >= xi4 ;
assign xi1_GTE_xi5  = xi1 >= xi5 ;
assign xi1_GTE_xi6  = xi1 >= xi6 ;
assign xi1_GTE_xi7  = xi1 >= xi7 ;
assign xi1_GTE_xi8  = xi1 >= xi8 ;
assign xi1_GTE_xi9  = xi1 >= xi9 ;
assign xi1_GTE_xi10 = xi1 >= xi10;
assign xi1_GTE_xi11 = xi1 >= xi11;
assign xi1_GTE_xi12 = xi1 >= xi12;
assign xi1_GTE_xi13 = xi1 >= xi13;
assign xi1_GTE_xi14 = xi1 >= xi14;
assign xi1_GTE_xi15 = xi1 >= xi15;

assign xi2_GTE_xi0  = xi2 >= xi0 ;
assign xi2_GTE_xi1  = xi2 >= xi1 ;
assign xi2_GTE_xi3  = xi2 >= xi3 ;
assign xi2_GTE_xi4  = xi2 >= xi4 ;
assign xi2_GTE_xi5  = xi2 >= xi5 ;
assign xi2_GTE_xi6  = xi2 >= xi6 ;
assign xi2_GTE_xi7  = xi2 >= xi7 ;
assign xi2_GTE_xi8  = xi2 >= xi8 ;
assign xi2_GTE_xi9  = xi2 >= xi9 ;
assign xi2_GTE_xi10 = xi2 >= xi10;
assign xi2_GTE_xi11 = xi2 >= xi11;
assign xi2_GTE_xi12 = xi2 >= xi12;
assign xi2_GTE_xi13 = xi2 >= xi13;
assign xi2_GTE_xi14 = xi2 >= xi14;
assign xi2_GTE_xi15 = xi2 >= xi15;

assign xi3_GTE_xi0  = xi3 >= xi0 ;
assign xi3_GTE_xi1  = xi3 >= xi1 ;
assign xi3_GTE_xi2  = xi3 >= xi2 ;
assign xi3_GTE_xi4  = xi3 >= xi4 ;
assign xi3_GTE_xi5  = xi3 >= xi5 ;
assign xi3_GTE_xi6  = xi3 >= xi6 ;
assign xi3_GTE_xi7  = xi3 >= xi7 ;
assign xi3_GTE_xi8  = xi3 >= xi8 ;
assign xi3_GTE_xi9  = xi3 >= xi9 ;
assign xi3_GTE_xi10 = xi3 >= xi10;
assign xi3_GTE_xi11 = xi3 >= xi11;
assign xi3_GTE_xi12 = xi3 >= xi12;
assign xi3_GTE_xi13 = xi3 >= xi13;
assign xi3_GTE_xi14 = xi3 >= xi14;
assign xi3_GTE_xi15 = xi3 >= xi15;

assign xi4_GTE_xi0  = xi4 >= xi0 ;
assign xi4_GTE_xi1  = xi4 >= xi1 ;
assign xi4_GTE_xi2  = xi4 >= xi2 ;
assign xi4_GTE_xi3  = xi4 >= xi3 ;
assign xi4_GTE_xi5  = xi4 >= xi5 ;
assign xi4_GTE_xi6  = xi4 >= xi6 ;
assign xi4_GTE_xi7  = xi4 >= xi7 ;
assign xi4_GTE_xi8  = xi4 >= xi8 ;
assign xi4_GTE_xi9  = xi4 >= xi9 ;
assign xi4_GTE_xi10 = xi4 >= xi10;
assign xi4_GTE_xi11 = xi4 >= xi11;
assign xi4_GTE_xi12 = xi4 >= xi12;
assign xi4_GTE_xi13 = xi4 >= xi13;
assign xi4_GTE_xi14 = xi4 >= xi14;
assign xi4_GTE_xi15 = xi4 >= xi15;

assign xi5_GTE_xi0  = xi5 >= xi0 ;
assign xi5_GTE_xi1  = xi5 >= xi1 ;
assign xi5_GTE_xi2  = xi5 >= xi2 ;
assign xi5_GTE_xi3  = xi5 >= xi3 ;
assign xi5_GTE_xi4  = xi5 >= xi4 ;
assign xi5_GTE_xi6  = xi5 >= xi6 ;
assign xi5_GTE_xi7  = xi5 >= xi7 ;
assign xi5_GTE_xi8  = xi5 >= xi8 ;
assign xi5_GTE_xi9  = xi5 >= xi9 ;
assign xi5_GTE_xi10 = xi5 >= xi10;
assign xi5_GTE_xi11 = xi5 >= xi11;
assign xi5_GTE_xi12 = xi5 >= xi12;
assign xi5_GTE_xi13 = xi5 >= xi13;
assign xi5_GTE_xi14 = xi5 >= xi14;
assign xi5_GTE_xi15 = xi5 >= xi15;

assign xi6_GTE_xi0  = xi6 >= xi0 ;
assign xi6_GTE_xi1  = xi6 >= xi1 ;
assign xi6_GTE_xi2  = xi6 >= xi2 ;
assign xi6_GTE_xi3  = xi6 >= xi3 ;
assign xi6_GTE_xi4  = xi6 >= xi4 ;
assign xi6_GTE_xi5  = xi6 >= xi5 ;
assign xi6_GTE_xi7  = xi6 >= xi7 ;
assign xi6_GTE_xi8  = xi6 >= xi8 ;
assign xi6_GTE_xi9  = xi6 >= xi9 ;
assign xi6_GTE_xi10 = xi6 >= xi10;
assign xi6_GTE_xi11 = xi6 >= xi11;
assign xi6_GTE_xi12 = xi6 >= xi12;
assign xi6_GTE_xi13 = xi6 >= xi13;
assign xi6_GTE_xi14 = xi6 >= xi14;
assign xi6_GTE_xi15 = xi6 >= xi15;

assign xi7_GTE_xi0  = xi7 >= xi0 ;
assign xi7_GTE_xi1  = xi7 >= xi1 ;
assign xi7_GTE_xi2  = xi7 >= xi2 ;
assign xi7_GTE_xi3  = xi7 >= xi3 ;
assign xi7_GTE_xi4  = xi7 >= xi4 ;
assign xi7_GTE_xi5  = xi7 >= xi5 ;
assign xi7_GTE_xi6  = xi7 >= xi6 ;
assign xi7_GTE_xi8  = xi7 >= xi8 ;
assign xi7_GTE_xi9  = xi7 >= xi9 ;
assign xi7_GTE_xi10 = xi7 >= xi10;
assign xi7_GTE_xi11 = xi7 >= xi11;
assign xi7_GTE_xi12 = xi7 >= xi12;
assign xi7_GTE_xi13 = xi7 >= xi13;
assign xi7_GTE_xi14 = xi7 >= xi14;
assign xi7_GTE_xi15 = xi7 >= xi15;

assign xi8_GTE_xi0  = xi8 >= xi0 ;
assign xi8_GTE_xi1  = xi8 >= xi1 ;
assign xi8_GTE_xi2  = xi8 >= xi2 ;
assign xi8_GTE_xi3  = xi8 >= xi3 ;
assign xi8_GTE_xi4  = xi8 >= xi4 ;
assign xi8_GTE_xi5  = xi8 >= xi5 ;
assign xi8_GTE_xi6  = xi8 >= xi6 ;
assign xi8_GTE_xi7  = xi8 >= xi7 ;
assign xi8_GTE_xi9  = xi8 >= xi9 ;
assign xi8_GTE_xi10 = xi8 >= xi10;
assign xi8_GTE_xi11 = xi8 >= xi11;
assign xi8_GTE_xi12 = xi8 >= xi12;
assign xi8_GTE_xi13 = xi8 >= xi13;
assign xi8_GTE_xi14 = xi8 >= xi14;
assign xi8_GTE_xi15 = xi8 >= xi15;

assign xi9_GTE_xi0  = xi9 >= xi0 ;
assign xi9_GTE_xi1  = xi9 >= xi1 ;
assign xi9_GTE_xi2  = xi9 >= xi2 ;
assign xi9_GTE_xi3  = xi9 >= xi3 ;
assign xi9_GTE_xi4  = xi9 >= xi4 ;
assign xi9_GTE_xi5  = xi9 >= xi5 ;
assign xi9_GTE_xi6  = xi9 >= xi6 ;
assign xi9_GTE_xi7  = xi9 >= xi7 ;
assign xi9_GTE_xi8  = xi9 >= xi8 ;
assign xi9_GTE_xi10 = xi9 >= xi10;
assign xi9_GTE_xi11 = xi9 >= xi11;
assign xi9_GTE_xi12 = xi9 >= xi12;
assign xi9_GTE_xi13 = xi9 >= xi13;
assign xi9_GTE_xi14 = xi9 >= xi14;
assign xi9_GTE_xi15 = xi9 >= xi15;

assign xi10_GTE_xi0  = xi10 >= xi0 ;
assign xi10_GTE_xi1  = xi10 >= xi1 ;
assign xi10_GTE_xi2  = xi10 >= xi2 ;
assign xi10_GTE_xi3  = xi10 >= xi3 ;
assign xi10_GTE_xi4  = xi10 >= xi4 ;
assign xi10_GTE_xi5  = xi10 >= xi5 ;
assign xi10_GTE_xi6  = xi10 >= xi6 ;
assign xi10_GTE_xi7  = xi10 >= xi7 ;
assign xi10_GTE_xi8  = xi10 >= xi8 ;
assign xi10_GTE_xi9  = xi10 >= xi9 ;
assign xi10_GTE_xi11 = xi10 >= xi11;
assign xi10_GTE_xi12 = xi10 >= xi12;
assign xi10_GTE_xi13 = xi10 >= xi13;
assign xi10_GTE_xi14 = xi10 >= xi14;
assign xi10_GTE_xi15 = xi10 >= xi15;

assign xi11_GTE_xi0  = xi11 >= xi0 ;
assign xi11_GTE_xi1  = xi11 >= xi1 ;
assign xi11_GTE_xi2  = xi11 >= xi2 ;
assign xi11_GTE_xi3  = xi11 >= xi3 ;
assign xi11_GTE_xi4  = xi11 >= xi4 ;
assign xi11_GTE_xi5  = xi11 >= xi5 ;
assign xi11_GTE_xi6  = xi11 >= xi6 ;
assign xi11_GTE_xi7  = xi11 >= xi7 ;
assign xi11_GTE_xi8  = xi11 >= xi8 ;
assign xi11_GTE_xi9  = xi11 >= xi9 ;
assign xi11_GTE_xi10 = xi11 >= xi10;
assign xi11_GTE_xi12 = xi11 >= xi12;
assign xi11_GTE_xi13 = xi11 >= xi13;
assign xi11_GTE_xi14 = xi11 >= xi14;
assign xi11_GTE_xi15 = xi11 >= xi15;

assign xi12_GTE_xi0  = xi12 >= xi0 ;
assign xi12_GTE_xi1  = xi12 >= xi1 ;
assign xi12_GTE_xi2  = xi12 >= xi2 ;
assign xi12_GTE_xi3  = xi12 >= xi3 ;
assign xi12_GTE_xi4  = xi12 >= xi4 ;
assign xi12_GTE_xi5  = xi12 >= xi5 ;
assign xi12_GTE_xi6  = xi12 >= xi6 ;
assign xi12_GTE_xi7  = xi12 >= xi7 ;
assign xi12_GTE_xi8  = xi12 >= xi8 ;
assign xi12_GTE_xi9  = xi12 >= xi9 ;
assign xi12_GTE_xi10 = xi12 >= xi10;
assign xi12_GTE_xi11 = xi12 >= xi11;
assign xi12_GTE_xi13 = xi12 >= xi13;
assign xi12_GTE_xi14 = xi12 >= xi14;
assign xi12_GTE_xi15 = xi12 >= xi15;

assign xi13_GTE_xi0  = xi13 >= xi0 ;
assign xi13_GTE_xi1  = xi13 >= xi1 ;
assign xi13_GTE_xi2  = xi13 >= xi2 ;
assign xi13_GTE_xi3  = xi13 >= xi3 ;
assign xi13_GTE_xi4  = xi13 >= xi4 ;
assign xi13_GTE_xi5  = xi13 >= xi5 ;
assign xi13_GTE_xi6  = xi13 >= xi6 ;
assign xi13_GTE_xi7  = xi13 >= xi7 ;
assign xi13_GTE_xi8  = xi13 >= xi8 ;
assign xi13_GTE_xi9  = xi13 >= xi9 ;
assign xi13_GTE_xi10 = xi13 >= xi10;
assign xi13_GTE_xi11 = xi13 >= xi11;
assign xi13_GTE_xi12 = xi13 >= xi12;
assign xi13_GTE_xi14 = xi13 >= xi14;
assign xi13_GTE_xi15 = xi13 >= xi15;

assign xi14_GTE_xi0  = xi14 >= xi0 ;
assign xi14_GTE_xi1  = xi14 >= xi1 ;
assign xi14_GTE_xi2  = xi14 >= xi2 ;
assign xi14_GTE_xi3  = xi14 >= xi3 ;
assign xi14_GTE_xi4  = xi14 >= xi4 ;
assign xi14_GTE_xi5  = xi14 >= xi5 ;
assign xi14_GTE_xi6  = xi14 >= xi6 ;
assign xi14_GTE_xi7  = xi14 >= xi7 ;
assign xi14_GTE_xi8  = xi14 >= xi8 ;
assign xi14_GTE_xi9  = xi14 >= xi9 ;
assign xi14_GTE_xi10 = xi14 >= xi10;
assign xi14_GTE_xi11 = xi14 >= xi11;
assign xi14_GTE_xi12 = xi14 >= xi12;
assign xi14_GTE_xi13 = xi14 >= xi13;
assign xi14_GTE_xi15 = xi14 >= xi15;

assign xi15_GTE_xi0  = xi15 >= xi0 ;
assign xi15_GTE_xi1  = xi15 >= xi1 ;
assign xi15_GTE_xi2  = xi15 >= xi2 ;
assign xi15_GTE_xi3  = xi15 >= xi3 ;
assign xi15_GTE_xi4  = xi15 >= xi4 ;
assign xi15_GTE_xi5  = xi15 >= xi5 ;
assign xi15_GTE_xi6  = xi15 >= xi6 ;
assign xi15_GTE_xi7  = xi15 >= xi7 ;
assign xi15_GTE_xi8  = xi15 >= xi8 ;
assign xi15_GTE_xi9  = xi15 >= xi9 ;
assign xi15_GTE_xi10 = xi15 >= xi10;
assign xi15_GTE_xi11 = xi15 >= xi11;
assign xi15_GTE_xi12 = xi15 >= xi12;
assign xi15_GTE_xi13 = xi15 >= xi13;
assign xi15_GTE_xi14 = xi15 >= xi14;

assign x0IsMax  =  xi0_GTE_xi1 && xi0_GTE_xi2 && xi0_GTE_xi3 && xi0_GTE_xi4 && xi0_GTE_xi5 && xi0_GTE_xi6 && xi0_GTE_xi7 && xi0_GTE_xi8 && xi0_GTE_xi9 && xi0_GTE_xi10 && xi0_GTE_xi11 && xi0_GTE_xi12 && xi0_GTE_xi13 && xi0_GTE_xi14 && xi0_GTE_xi15; 
assign x1IsMax  =  xi1_GTE_xi0 && xi1_GTE_xi2 && xi1_GTE_xi3 && xi1_GTE_xi4 && xi1_GTE_xi5 && xi1_GTE_xi6 && xi1_GTE_xi7 && xi1_GTE_xi8 && xi1_GTE_xi9 && xi1_GTE_xi10 && xi1_GTE_xi11 && xi1_GTE_xi12 && xi1_GTE_xi13 && xi1_GTE_xi14 && xi1_GTE_xi15; 
assign x2IsMax  =  xi2_GTE_xi0 && xi2_GTE_xi1 && xi2_GTE_xi3 && xi2_GTE_xi4 && xi2_GTE_xi5 && xi2_GTE_xi6 && xi2_GTE_xi7 && xi2_GTE_xi8 && xi2_GTE_xi9 && xi2_GTE_xi10 && xi2_GTE_xi11 && xi2_GTE_xi12 && xi2_GTE_xi13 && xi2_GTE_xi14 && xi2_GTE_xi15; 
assign x3IsMax  =  xi3_GTE_xi0 && xi3_GTE_xi1 && xi3_GTE_xi2 && xi3_GTE_xi4 && xi3_GTE_xi5 && xi3_GTE_xi6 && xi3_GTE_xi7 && xi3_GTE_xi8 && xi3_GTE_xi9 && xi3_GTE_xi10 && xi3_GTE_xi11 && xi3_GTE_xi12 && xi3_GTE_xi13 && xi3_GTE_xi14 && xi3_GTE_xi15; 
assign x4IsMax  =  xi4_GTE_xi0 && xi4_GTE_xi1 && xi4_GTE_xi2 && xi4_GTE_xi3 && xi4_GTE_xi5 && xi4_GTE_xi6 && xi4_GTE_xi7 && xi4_GTE_xi8 && xi4_GTE_xi9 && xi4_GTE_xi10 && xi4_GTE_xi11 && xi4_GTE_xi12 && xi4_GTE_xi13 && xi4_GTE_xi14 && xi4_GTE_xi15; 
assign x5IsMax  =  xi5_GTE_xi0 && xi5_GTE_xi1 && xi5_GTE_xi2 && xi5_GTE_xi3 && xi5_GTE_xi4 && xi5_GTE_xi6 && xi5_GTE_xi7 && xi5_GTE_xi8 && xi5_GTE_xi9 && xi5_GTE_xi10 && xi5_GTE_xi11 && xi5_GTE_xi12 && xi5_GTE_xi13 && xi5_GTE_xi14 && xi5_GTE_xi15; 
assign x6IsMax  =  xi6_GTE_xi0 && xi6_GTE_xi1 && xi6_GTE_xi2 && xi6_GTE_xi3 && xi6_GTE_xi4 && xi6_GTE_xi5 && xi6_GTE_xi7 && xi6_GTE_xi8 && xi6_GTE_xi9 && xi6_GTE_xi10 && xi6_GTE_xi11 && xi6_GTE_xi12 && xi6_GTE_xi13 && xi6_GTE_xi14 && xi6_GTE_xi15; 
assign x7IsMax  =  xi7_GTE_xi0 && xi7_GTE_xi1 && xi7_GTE_xi2 && xi7_GTE_xi3 && xi7_GTE_xi4 && xi7_GTE_xi5 && xi7_GTE_xi6 && xi7_GTE_xi8 && xi7_GTE_xi9 && xi7_GTE_xi10 && xi7_GTE_xi11 && xi7_GTE_xi12 && xi7_GTE_xi13 && xi7_GTE_xi14 && xi7_GTE_xi15; 
assign x8IsMax  =  xi8_GTE_xi0 && xi8_GTE_xi1 && xi8_GTE_xi2 && xi8_GTE_xi3 && xi8_GTE_xi4 && xi8_GTE_xi5 && xi8_GTE_xi6 && xi8_GTE_xi7 && xi8_GTE_xi9 && xi8_GTE_xi10 && xi8_GTE_xi11 && xi8_GTE_xi12 && xi8_GTE_xi13 && xi8_GTE_xi14 && xi8_GTE_xi15; 
assign x9IsMax  =  xi9_GTE_xi0 && xi9_GTE_xi1 && xi9_GTE_xi2 && xi9_GTE_xi3 && xi9_GTE_xi4 && xi9_GTE_xi5 && xi9_GTE_xi6 && xi9_GTE_xi7 && xi9_GTE_xi8 && xi9_GTE_xi10 && xi9_GTE_xi11 && xi9_GTE_xi12 && xi9_GTE_xi13 && xi9_GTE_xi14 && xi9_GTE_xi15; 
assign x10IsMax =  xi10_GTE_xi0 && xi10_GTE_xi1 && xi10_GTE_xi2 && xi10_GTE_xi3 && xi10_GTE_xi4 && xi10_GTE_xi5 && xi10_GTE_xi6 && xi10_GTE_xi7 && xi10_GTE_xi8 && xi10_GTE_xi9 && xi10_GTE_xi11 && xi10_GTE_xi12 && xi10_GTE_xi13 && xi10_GTE_xi14 && xi10_GTE_xi15; 
assign x11IsMax =  xi11_GTE_xi0 && xi11_GTE_xi1 && xi11_GTE_xi2 && xi11_GTE_xi3 && xi11_GTE_xi4 && xi11_GTE_xi5 && xi11_GTE_xi6 && xi11_GTE_xi7 && xi11_GTE_xi8 && xi11_GTE_xi9 && xi11_GTE_xi10 && xi11_GTE_xi12 && xi11_GTE_xi13 && xi11_GTE_xi14 && xi11_GTE_xi15; 
assign x12IsMax =  xi12_GTE_xi0 && xi12_GTE_xi1 && xi12_GTE_xi2 && xi12_GTE_xi3 && xi12_GTE_xi4 && xi12_GTE_xi5 && xi12_GTE_xi6 && xi12_GTE_xi7 && xi12_GTE_xi8 && xi12_GTE_xi9 && xi12_GTE_xi10 && xi12_GTE_xi11 && xi12_GTE_xi13 && xi12_GTE_xi14 && xi12_GTE_xi15; 
assign x13IsMax =  xi13_GTE_xi0 && xi13_GTE_xi1 && xi13_GTE_xi2 && xi13_GTE_xi3 && xi13_GTE_xi4 && xi13_GTE_xi5 && xi13_GTE_xi6 && xi13_GTE_xi7 && xi13_GTE_xi8 && xi13_GTE_xi9 && xi13_GTE_xi10 && xi13_GTE_xi11 && xi13_GTE_xi12 && xi13_GTE_xi14 && xi13_GTE_xi15; 
assign x14IsMax =  xi14_GTE_xi0 && xi14_GTE_xi1 && xi14_GTE_xi2 && xi14_GTE_xi3 && xi14_GTE_xi4 && xi14_GTE_xi5 && xi14_GTE_xi6 && xi14_GTE_xi7 && xi14_GTE_xi8 && xi14_GTE_xi9 && xi14_GTE_xi10 && xi14_GTE_xi11 && xi14_GTE_xi12 && xi14_GTE_xi13 && xi14_GTE_xi15; 
assign x15IsMax =  xi15_GTE_xi0 && xi15_GTE_xi1 && xi15_GTE_xi2 && xi15_GTE_xi3 && xi15_GTE_xi4 && xi15_GTE_xi5 && xi15_GTE_xi6 && xi15_GTE_xi7 && xi15_GTE_xi8 && xi15_GTE_xi9 && xi15_GTE_xi10 && xi15_GTE_xi11 && xi15_GTE_xi12 && xi15_GTE_xi13 && xi15_GTE_xi14; 

reg [15:0] maxSel_del_1,
           maxSel_del_2,
           maxSel_del_3,
           maxSel_del_4,
           maxSel_del_5,
           maxSel_del_6,
           maxSel_del_7,
           maxSel_del_8,
           maxSel_del_9;
           
reg TextSel_del_1,
    TextSel_del_2,
    TextSel_del_3,
    TextSel_del_4,
    TextSel_del_5,
    TextSel_del_6;
    
reg [1:0] SizeD_del_1,
          SizeD_del_2,
          SizeD_del_3,
          SizeD_del_4,
          SizeD_del_5,
          SizeD_del_6;
          
reg [1023:0] maxASC;
reg [1023:0] binOut;
reg shortPipeEn_del;
reg wren_del;
reg SigD_del;
reg [2:0] SizeD_del;


reg [15:0] class;
//reg [1:0] R_size;
wire [1:0] R_size;
wire [1023:0] R_ShortPipe;
wire [1023:0] R_LongPipe;
wire [1023:0] R;
wire [15:0] maxSel;

assign R_ShortPipe = binOut;
assign R_LongPipe = TextSel_del_6 ? maxASC : binOut;
assign R = shortPipeEn_del && wren_del ? R_ShortPipe : R_LongPipe;
//assign maxSel = {x0IsMax, x1IsMax, x2IsMax, x3IsMax, x4IsMax, x5IsMax, x6IsMax, x7IsMax, x8IsMax, x9IsMax, x10IsMax, x11IsMax, x12IsMax, x13IsMax, x14IsMax, x15IsMax};
assign maxSel = {x15IsMax, x14IsMax, x13IsMax, x12IsMax, x11IsMax, x10IsMax, x9IsMax, x8IsMax, x7IsMax, x6IsMax, x5IsMax, x4IsMax, x3IsMax, x2IsMax, x1IsMax, x0IsMax};
assign R_size = shortPipeEn_del && wren_del ? SizeD_del[1:0] : SizeD_del_6;


always @(posedge CLK) begin
    shortPipeEn_del <= shortPipeEn;
    wren_del <= wren;
    SigD_del <= SigD;
    SizeD_del <= SizeD;
end    

reg [15:0] oneHot;
always @(*)
    casex(maxSel_del_3)
        16'b1xxxxxxxxxxxxxxx : oneHot <= 16'b1000000000000000;
        16'bx1xxxxxxxxxxxxxx : oneHot <= 16'b0100000000000000;
        16'bxx1xxxxxxxxxxxxx : oneHot <= 16'b0010000000000000;
        16'bxxx1xxxxxxxxxxxx : oneHot <= 16'b0001000000000000;
        16'bxxxx1xxxxxxxxxxx : oneHot <= 16'b0000100000000000;
        16'bxxxxx1xxxxxxxxxx : oneHot <= 16'b0000010000000000;
        16'bxxxxxx1xxxxxxxxx : oneHot <= 16'b0000001000000000;
        16'bxxxxxxx1xxxxxxxx : oneHot <= 16'b0000000100000000;
        16'bxxxxxxxx1xxxxxxx : oneHot <= 16'b0000000010000000;
        16'bxxxxxxxxx1xxxxxx : oneHot <= 16'b0000000001000000;
        16'bxxxxxxxxxx1xxxxx : oneHot <= 16'b0000000000100000;
        16'bxxxxxxxxxxx1xxxx : oneHot <= 16'b0000000000010000;
        16'bxxxxxxxxxxxx1xxx : oneHot <= 16'b0000000000001000;
        16'bxxxxxxxxxxxxx1xx : oneHot <= 16'b0000000000000100;
        16'bxxxxxxxxxxxxxx1x : oneHot <= 16'b0000000000000010;
        16'bxxxxxxxxxxxxxxx1 : oneHot <= 16'b0000000000000001;
                     default : oneHot <= 0;
    endcase
    

reg [31:0] maxProb;
reg [15:0] classTooHot;
reg [15:0] classOneHot;
reg [31:0] cNumOH_q4;
reg [31:0] cNumOH_q5;
reg [31:0] cNumOH_q6;
reg [31:0] cNumOH_q7;
reg [31:0] cNumOH_q8;
reg [31:0] cNumOH_q9;
reg [31:0] maxProb_q2;
reg [31:0] maxProb_q3;
reg [31:0] maxProb_q4;
reg [31:0] maxProb_q5;
reg [31:0] maxProb_q6;
reg [31:0] maxProb_q7;
reg [31:0] maxProb_q8;
reg [31:0] maxProb_q9;

always @(posedge CLK) begin
    class <= (shortPipeEn && wren) ? maxSel_del_3 : maxSel_del_9;
    {classTooHot, classOneHot} <= (shortPipeEn && wren) ? {maxSel_del_3, oneHot} : cNumOH_q9;
    maxProb <= (shortPipeEn && wren) ? maxProb_q3 : maxProb_q9;
    cNumOH_q4 <= {maxSel_del_3, oneHot};
    cNumOH_q5 <= cNumOH_q4;
    cNumOH_q6 <= cNumOH_q5;
    cNumOH_q7 <= cNumOH_q6;
    cNumOH_q8 <= cNumOH_q7;
    cNumOH_q9 <= cNumOH_q8;
end

reg [15:0] maxValue;
always @(posedge CLK)
    casex(maxSel)
        16'b1xxxxxxxxxxxxxxx : maxValue <= x15;
        16'bx1xxxxxxxxxxxxxx : maxValue <= x14;
        16'bxx1xxxxxxxxxxxxx : maxValue <= x13;
        16'bxxx1xxxxxxxxxxxx : maxValue <= x12;
        16'bxxxx1xxxxxxxxxxx : maxValue <= x11;
        16'bxxxxx1xxxxxxxxxx : maxValue <= x10;
        16'bxxxxxx1xxxxxxxxx : maxValue <= x9;
        16'bxxxxxxx1xxxxxxxx : maxValue <= x8;
        16'bxxxxxxxx1xxxxxxx : maxValue <= x7;
        16'bxxxxxxxxx1xxxxxx : maxValue <= x6;
        16'bxxxxxxxxxx1xxxxx : maxValue <= x5;
        16'bxxxxxxxxxxx1xxxx : maxValue <= x4;
        16'bxxxxxxxxxxxx1xxx : maxValue <= x3;
        16'bxxxxxxxxxxxxx1xx : maxValue <= x2;
        16'bxxxxxxxxxxxxxx1x : maxValue <= x1;
        16'bxxxxxxxxxxxxxxx1 : maxValue <= x0;
                     default : maxValue <= 0;
    endcase
    
wire maxIsNaN;
wire maxIsZero;
wire maxIsInf;
assign maxIsNaN = &maxValue[14:8] && |maxValue[6:0];
assign maxIsZero = ~|maxValue[14:0];
assign maxIsInf = &maxValue[14:8] && ~|maxValue[7:0]; 

always @(posedge CLK) begin
    if (maxIsNaN) maxProb_q2 <= {maxValue[15], 8'hFF, maxValue[7:0], 15'b0};
    else if (maxIsInf) maxProb_q2 <= {maxValue[15], 8'hFF, 23'b0};
    else if (maxIsZero) maxProb_q2 <= {maxValue[15], 31'h0};
    else maxProb_q2 <= {maxValue[15], maxValue[14:8]+64, maxValue[7:0], 15'b0};
     maxProb_q3 <= maxProb_q2;
     maxProb_q4 <= maxProb_q3;
     maxProb_q5 <= maxProb_q4;
     maxProb_q6 <= maxProb_q5;
     maxProb_q7 <= maxProb_q6;
     maxProb_q8 <= maxProb_q7;
     maxProb_q9 <= maxProb_q8;
end
    
always @(posedge CLK) begin           
    maxSel_del_1 <= maxSel;
    maxSel_del_2 <= maxSel_del_1;
    maxSel_del_3 <= maxSel_del_2;
    maxSel_del_4 <= maxSel_del_3;
    maxSel_del_5 <= maxSel_del_4;
    maxSel_del_6 <= maxSel_del_5;
    maxSel_del_7 <= maxSel_del_6;
    maxSel_del_8 <= maxSel_del_7;
    maxSel_del_9 <= maxSel_del_8;
end

          
always @(posedge CLK) begin
    TextSel_del_1 <= SigD_del && wren_del;
    TextSel_del_2 <= TextSel_del_1;
    TextSel_del_3 <= TextSel_del_2;
    TextSel_del_4 <= TextSel_del_3;                                             
    TextSel_del_5 <= TextSel_del_4;                                             
    TextSel_del_6 <= TextSel_del_5;                                             
end                                                                             
                                                                                
always @(posedge CLK) begin                                                     
   SizeD_del_1 <= SizeD[1:0];                                                   
   SizeD_del_2 <= SizeD_del_1;                                                  
   SizeD_del_3 <= SizeD_del_2;                                                  
   SizeD_del_4 <= SizeD_del_3;                                                  
   SizeD_del_5 <= SizeD_del_4;                                                  
   SizeD_del_6 <= SizeD_del_5;                                                  
end                                                                             
                                                                                
reg [63:0] one;                                                                 
always @(*)                                                                     
    case(R_size)
        2'b00 : one = 64'b0;
        2'b01 : one = 64'h0000000000007F00;
        2'b10 : one = 64'h000000007F000000;
        2'b11 : one = 64'h3FF0000000000000; 
    endcase
    
always @(*)
    casex(class)
        16'b1xxxxxxxxxxxxxxx : binOut <= {             one, {15{64'b0}}};
        16'bx1xxxxxxxxxxxxxx : binOut <= {    64'b0,   one, {14{64'b0}}};
        16'bxx1xxxxxxxxxxxxx : binOut <= {{ 2{64'b0}}, one, {13{64'b0}}};
        16'bxxx1xxxxxxxxxxxx : binOut <= {{ 3{64'b0}}, one, {12{64'b0}}};
        16'bxxxx1xxxxxxxxxxx : binOut <= {{ 4{64'b0}}, one, {11{64'b0}}};
        16'bxxxxx1xxxxxxxxxx : binOut <= {{ 5{64'b0}}, one, {10{64'b0}}};
        16'bxxxxxx1xxxxxxxxx : binOut <= {{ 6{64'b0}}, one, { 9{64'b0}}};
        16'bxxxxxxx1xxxxxxxx : binOut <= {{ 7{64'b0}}, one, { 8{64'b0}}};
        16'bxxxxxxxx1xxxxxxx : binOut <= {{ 8{64'b0}}, one, { 7{64'b0}}};
        16'bxxxxxxxxx1xxxxxx : binOut <= {{ 9{64'b0}}, one, { 6{64'b0}}};
        16'bxxxxxxxxxx1xxxxx : binOut <= {{10{64'b0}}, one, { 5{64'b0}}};
        16'bxxxxxxxxxxx1xxxx : binOut <= {{11{64'b0}}, one, { 4{64'b0}}};
        16'bxxxxxxxxxxxx1xxx : binOut <= {{12{64'b0}}, one, { 3{64'b0}}};
        16'bxxxxxxxxxxxxx1xx : binOut <= {{13{64'b0}}, one, { 2{64'b0}}};
        16'bxxxxxxxxxxxxxx1x : binOut <= {{14{64'b0}}, one, { 1{64'b0}}};
        16'bxxxxxxxxxxxxxxx1 : binOut <= {{15{64'b0}}, one};
                     default : binOut <= 0;
    endcase

always @(posedge CLK)
    casex(maxSel_del_9)
        16'b1xxxxxxxxxxxxxxx : maxASC <= {    "     1.0",               {15{"     0.0"}}};
        16'bx1xxxxxxxxxxxxxx : maxASC <= {    "     0.0",   "     1.0", {14{"     0.0"}}};
        16'bxx1xxxxxxxxxxxxx : maxASC <= {{ 2{"     0.0"}}, "     1.0", {13{"     0.0"}}};
        16'bxxx1xxxxxxxxxxxx : maxASC <= {{ 3{"     0.0"}}, "     1.0", {12{"     0.0"}}};
        16'bxxxx1xxxxxxxxxxx : maxASC <= {{ 4{"     0.0"}}, "     1.0", {11{"     0.0"}}};
        16'bxxxxx1xxxxxxxxxx : maxASC <= {{ 5{"     0.0"}}, "     1.0", {10{"     0.0"}}};
        16'bxxxxxx1xxxxxxxxx : maxASC <= {{ 6{"     0.0"}}, "     1.0", { 9{"     0.0"}}};
        16'bxxxxxxx1xxxxxxxx : maxASC <= {{ 7{"     0.0"}}, "     1.0", { 8{"     0.0"}}};
        16'bxxxxxxxx1xxxxxxx : maxASC <= {{ 8{"     0.0"}}, "     1.0", { 7{"     0.0"}}};
        16'bxxxxxxxxx1xxxxxx : maxASC <= {{ 9{"     0.0"}}, "     1.0", { 6{"     0.0"}}};
        16'bxxxxxxxxxx1xxxxx : maxASC <= {{10{"     0.0"}}, "     1.0", { 5{"     0.0"}}};
        16'bxxxxxxxxxxx1xxxx : maxASC <= {{11{"     0.0"}}, "     1.0", { 4{"     0.0"}}};
        16'bxxxxxxxxxxxx1xxx : maxASC <= {{12{"     0.0"}}, "     1.0", { 3{"     0.0"}}};
        16'bxxxxxxxxxxxxx1xx : maxASC <= {{13{"     0.0"}}, "     1.0", { 2{"     0.0"}}};
        16'bxxxxxxxxxxxxxx1x : maxASC <= {{14{"     0.0"}}, "     1.0", { 1{"     0.0"}}};
        16'bxxxxxxxxxxxxxxx1 : maxASC <= {{15{"     0.0"}}, "     1.0"};
                     default : maxASC <= { 16{"     0.0"}};

    endcase


endmodule
