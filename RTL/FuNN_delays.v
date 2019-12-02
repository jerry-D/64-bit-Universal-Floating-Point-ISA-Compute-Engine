//FuNN_delays.v
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

module FuNN_delays (
    CLK,
    RESET,
    ADT,
    actSel,
    wren,
    wraddrs,
    SigA_q2,
    SigB_q2,
    SigD_q2,
    SizeD_q2,
        
    ADT_Del,    //long is 9 clocks, short is 4 clocks
    wrenAct,    //delayed write enable for activation  --long is 10 clocks, short is 5
    SigA_Del,   //delayed SigA for activation  --long is 10 clocks, short is 5
    SigB_Del,   //delayed SigB for activation  --long is 10 clocks, short is 5
    SigD_Del,   //delayed SigD for activation  --long is 10 clocks, short is 5
    SizeD_Del,  //delayed SizeD for activation  --long is 10 clocks, short is 5
    actSelDel,  //delayed activation select  --long is 10 clocks, short is 5
    wrenDel,    //memory write enable --long is 17, clocks short is 6 clocks
    wraddrsDel, //memory write address --long is 17, clocks short is 6 clocks
    EarlyRdenDel,     // for accum C   --long is 8 clocks, short is 3 clocks
    EarlyRdAddrsDel   // for accum C   --long is 8 clocks, short is 3 clocks
    );
    
input  CLK;
input  RESET;
input  ADT;
input [3:0] actSel;
input  wren;
input  [12:0] wraddrs;
input SigA_q2;
input SigB_q2;
input SigD_q2;
input [2:0] SizeD_q2;
output ADT_Del;
output wrenAct;
output SigA_Del;
output SigB_Del;
output SigD_Del;
output [2:0] SizeD_Del;
output [3:0] actSelDel;
output wrenDel;
output [12:0] wraddrsDel;
output EarlyRdenDel;      //for accum C
output [12:0] EarlyRdAddrsDel;


reg [22:1] SigA_q2_del;
reg [22:1] SigB_q2_del;
reg [22:1] SigD_q2_del;
reg [2:0] SizeD_q2_del[22:1];

reg [22:1] wren_del;
    
reg [12:0] wraddrs_del[22:1];
reg [3:0] act_del[22:1]; //activation delay
reg [11:1] ADT_del;

wire wrenDel;
wire [12:0] wraddrsDel;
wire EarlyRdenDel;
wire [12:0] EarlyRdAddrsDel;
wire [3:0] actSelDel;
wire ADT_Del;
wire SigA_Del;
wire SigB_Del;
wire SigD_Del;
wire [2:0] SizeD_Del;

wire shortPipeSel;  //delays for shortPipeSel, actSelDel, wrenAct, SigA_Del, SigB_Del, SigD_Del and SizeD_Del must be the same
assign shortPipeSel = (~SigA_q2_del[5] && ~SigB_q2_del[5] && ~SigD_q2_del[5]);

assign wrenDel = (SigA_q2_del[17] || SigB_q2_del[17] || SigD_q2_del[17]) && wren_del[17] ? 1'b1 : (~SigA_q2_del[6] && ~SigB_q2_del[6] && ~SigD_q2_del[6]) && wren_del[6];
assign wraddrsDel = (SigA_q2_del[17] || SigB_q2_del[17] || SigD_q2_del[17]) && wren_del[17] ? wraddrs_del[17] : wraddrs_del[6];
assign EarlyRdenDel = ((SigA_q2_del[8] || SigB_q2_del[8] || SigD_q2_del[8]) && wren_del[8]) ? 1'b1 : (~SigA_q2_del[3] && ~SigB_q2_del[3] && ~SigD_q2_del[3]) && wren_del[3];
assign EarlyRdAddrsDel = (SigA_q2_del[8] || SigB_q2_del[8] || SigD_q2_del[8]) && wren_del[8] ? wraddrs_del[8] : wraddrs_del[3];  // this is for accum_Creg;

assign actSelDel = (SigA_q2_del[10] || SigB_q2_del[10] || SigD_q2_del[10]) && wren_del[10] ? act_del[10] : act_del[5]; 
assign wrenAct = (SigA_q2_del[10] || SigB_q2_del[10] || SigD_q2_del[10]) && wren_del[10] ? 1'b1 : (~SigA_q2_del[5] && ~SigB_q2_del[5] && ~SigD_q2_del[5]) && wren_del[5];

assign SigA_Del = (SigA_q2_del[10] || SigB_q2_del[10] || SigD_q2_del[10]) && SigA_q2_del[10] && wren_del[10] ? 1'b1 : SigA_q2_del[5];
assign SigB_Del = (SigA_q2_del[10] || SigB_q2_del[10] || SigD_q2_del[10]) && SigB_q2_del[10] && wren_del[10] ? 1'b1 : SigB_q2_del[5];
assign SigD_Del = (SigA_q2_del[10] || SigB_q2_del[10] || SigD_q2_del[10]) && SigD_q2_del[10] && wren_del[10] ? 1'b1 : SigD_q2_del[5];

assign SizeD_Del = (SigA_q2_del[10] || SigB_q2_del[10] || SigD_q2_del[10]) && wren_del[10] ? SizeD_q2_del[10] : SizeD_q2_del[5];
assign ADT_Del = (SigA_q2_del[9] || SigB_q2_del[9] || SigD_q2_del[9]) && wren_del[9] ? ADT_del[9] : (~SigA_q2_del[4] && ~SigB_q2_del[4] && ~SigD_q2_del[4]) && wren_del[4] && ADT_del[4];


always @(posedge CLK) begin
    if (RESET) act_del[ 1] <= 0;
    else if (wren) act_del[ 1] <= actSel;
    act_del[ 2] <= act_del[ 1];
    act_del[ 3] <= act_del[ 2];
    act_del[ 4] <= act_del[ 3];
    act_del[ 5] <= act_del[ 4];
    act_del[ 6] <= act_del[ 5];
    act_del[ 7] <= act_del[ 6];
    act_del[ 8] <= act_del[ 7];
    act_del[ 9] <= act_del[ 8];
    act_del[10] <= act_del[ 9];
    act_del[11] <= act_del[10];
    act_del[12] <= act_del[11];
    act_del[13] <= act_del[12];
    act_del[14] <= act_del[13];
    act_del[15] <= act_del[14];
    act_del[16] <= act_del[15];
    act_del[17] <= act_del[16];
    act_del[18] <= act_del[17];
    act_del[19] <= act_del[18];
    act_del[20] <= act_del[19];
    act_del[21] <= act_del[20];
    act_del[22] <= act_del[21];
end    


always @(posedge CLK) begin
    if (RESET) begin 
        wren_del[ 1] <= 0;
        wren_del[ 2] <= 0;
        wren_del[ 3] <= 0;
        wren_del[ 4] <= 0;
        wren_del[ 5] <= 0;
        wren_del[ 6] <= 0;
        wren_del[ 7] <= 0;
        wren_del[ 8] <= 0;
        wren_del[ 9] <= 0;
        wren_del[10] <= 0;
        wren_del[11] <= 0;
        wren_del[12] <= 0;
        wren_del[13] <= 0;
        wren_del[14] <= 0;
        wren_del[15] <= 0;
        wren_del[16] <= 0;
        wren_del[17] <= 0;
        wren_del[18] <= 0;
        wren_del[19] <= 0;
        wren_del[20] <= 0;
        wren_del[21] <= 0;
        wren_del[22] <= 0;
    end    
    else wren_del[1] <= wren;
    wren_del[ 2] <= wren_del[ 1];
    wren_del[ 3] <= wren_del[ 2];
    wren_del[ 4] <= wren_del[ 3];
    wren_del[ 5] <= wren_del[ 4];
    wren_del[ 6] <= wren_del[ 5];
    wren_del[ 7] <= wren_del[ 6];
    wren_del[ 8] <= wren_del[ 7];
    wren_del[ 9] <= wren_del[ 8];
    wren_del[10] <= wren_del[ 9];
    wren_del[11] <= wren_del[10];
    wren_del[12] <= wren_del[11];
    wren_del[13] <= wren_del[12];
    wren_del[14] <= wren_del[13];
    wren_del[15] <= wren_del[14];
    wren_del[16] <= wren_del[15];
    wren_del[17] <= wren_del[16];
    wren_del[18] <= wren_del[17];
    wren_del[19] <= wren_del[18];
    wren_del[20] <= wren_del[19];
    wren_del[21] <= wren_del[20];
    wren_del[22] <= wren_del[21];
end    
    
always @(posedge CLK) begin
    wraddrs_del[ 1] <= wraddrs;
    wraddrs_del[ 2] <= wraddrs_del[ 1] ;
    wraddrs_del[ 3] <= wraddrs_del[ 2];
    wraddrs_del[ 4] <= wraddrs_del[ 3];
    wraddrs_del[ 5] <= wraddrs_del[ 4];
    wraddrs_del[ 6] <= wraddrs_del[ 5];
    wraddrs_del[ 7] <= wraddrs_del[ 6];
    wraddrs_del[ 8] <= wraddrs_del[ 7];
    wraddrs_del[ 9] <= wraddrs_del[ 8];
    wraddrs_del[10] <= wraddrs_del[ 9];
    wraddrs_del[11] <= wraddrs_del[10];
    wraddrs_del[12] <= wraddrs_del[11];
    wraddrs_del[13] <= wraddrs_del[12];
    wraddrs_del[14] <= wraddrs_del[13];
    wraddrs_del[15] <= wraddrs_del[14];
    wraddrs_del[16] <= wraddrs_del[15];
    wraddrs_del[17] <= wraddrs_del[16];
    wraddrs_del[18] <= wraddrs_del[17];
    wraddrs_del[19] <= wraddrs_del[18];
    wraddrs_del[20] <= wraddrs_del[19];
    wraddrs_del[21] <= wraddrs_del[20];
    wraddrs_del[22] <= wraddrs_del[21];
end    
    
always @(posedge CLK) begin
    SigD_q2_del[1] <= SigD_q2;
    SigD_q2_del[ 2] <= SigD_q2_del[ 1] ;
    SigD_q2_del[ 3] <= SigD_q2_del[ 2];
    SigD_q2_del[ 4] <= SigD_q2_del[ 3];
    SigD_q2_del[ 5] <= SigD_q2_del[ 4];
    SigD_q2_del[ 6] <= SigD_q2_del[ 5];
    SigD_q2_del[ 7] <= SigD_q2_del[ 6];
    SigD_q2_del[ 8] <= SigD_q2_del[ 7];
    SigD_q2_del[ 9] <= SigD_q2_del[ 8];
    SigD_q2_del[10] <= SigD_q2_del[ 9];
    SigD_q2_del[11] <= SigD_q2_del[10];
    SigD_q2_del[12] <= SigD_q2_del[11];
    SigD_q2_del[13] <= SigD_q2_del[12];
    SigD_q2_del[14] <= SigD_q2_del[13];
    SigD_q2_del[15] <= SigD_q2_del[14];
    SigD_q2_del[16] <= SigD_q2_del[15];
    SigD_q2_del[17] <= SigD_q2_del[16];
    SigD_q2_del[18] <= SigD_q2_del[17];
    SigD_q2_del[19] <= SigD_q2_del[18];
    SigD_q2_del[20] <= SigD_q2_del[19];
    SigD_q2_del[21] <= SigD_q2_del[20];
    SigD_q2_del[22] <= SigD_q2_del[21];
end                         
    
always @(posedge CLK) begin
    SigA_q2_del[ 1] <= SigA_q2;
    SigA_q2_del[ 2] <= SigA_q2_del[ 1] ;
    SigA_q2_del[ 3] <= SigA_q2_del[ 2];
    SigA_q2_del[ 4] <= SigA_q2_del[ 3];
    SigA_q2_del[ 5] <= SigA_q2_del[ 4];
    SigA_q2_del[ 6] <= SigA_q2_del[ 5];
    SigA_q2_del[ 7] <= SigA_q2_del[ 6];
    SigA_q2_del[ 8] <= SigA_q2_del[ 7];
    SigA_q2_del[ 9] <= SigA_q2_del[ 8];
    SigA_q2_del[10] <= SigA_q2_del[ 9];
    SigA_q2_del[11] <= SigA_q2_del[10];
    SigA_q2_del[12] <= SigA_q2_del[11];
    SigA_q2_del[13] <= SigA_q2_del[12];
    SigA_q2_del[14] <= SigA_q2_del[13];
    SigA_q2_del[15] <= SigA_q2_del[14];
    SigA_q2_del[16] <= SigA_q2_del[15];
    SigA_q2_del[17] <= SigA_q2_del[16];
    SigA_q2_del[18] <= SigA_q2_del[17];
    SigA_q2_del[19] <= SigA_q2_del[18];
    SigA_q2_del[20] <= SigA_q2_del[19];
    SigA_q2_del[21] <= SigA_q2_del[20];
    SigA_q2_del[22] <= SigA_q2_del[21];
end                         
    
always @(posedge CLK) begin
    SigB_q2_del[ 1] <= SigB_q2;
    SigB_q2_del[ 2] <= SigB_q2_del[ 1] ;
    SigB_q2_del[ 3] <= SigB_q2_del[ 2];
    SigB_q2_del[ 4] <= SigB_q2_del[ 3];
    SigB_q2_del[ 5] <= SigB_q2_del[ 4];
    SigB_q2_del[ 6] <= SigB_q2_del[ 5];
    SigB_q2_del[ 7] <= SigB_q2_del[ 6];
    SigB_q2_del[ 8] <= SigB_q2_del[ 7];
    SigB_q2_del[ 9] <= SigB_q2_del[ 8];
    SigB_q2_del[10] <= SigB_q2_del[ 9];
    SigB_q2_del[11] <= SigB_q2_del[10];
    SigB_q2_del[12] <= SigB_q2_del[11];
    SigB_q2_del[13] <= SigB_q2_del[12];
    SigB_q2_del[14] <= SigB_q2_del[13];
    SigB_q2_del[15] <= SigB_q2_del[14];
    SigB_q2_del[16] <= SigB_q2_del[15];
    SigB_q2_del[17] <= SigB_q2_del[16];
    SigB_q2_del[18] <= SigB_q2_del[17];
    SigB_q2_del[19] <= SigB_q2_del[18];
    SigB_q2_del[20] <= SigB_q2_del[19];
    SigB_q2_del[21] <= SigB_q2_del[20];
    SigB_q2_del[22] <= SigB_q2_del[21];
end                         

always @(posedge CLK) begin
    if (RESET) SizeD_q2_del[1] <= 0;
    else SizeD_q2_del[1] <= SizeD_q2;
    SizeD_q2_del[ 2] <= SizeD_q2_del[ 1] ;
    SizeD_q2_del[ 3] <= SizeD_q2_del[ 2];
    SizeD_q2_del[ 4] <= SizeD_q2_del[ 3];
    SizeD_q2_del[ 5] <= SizeD_q2_del[ 4];
    SizeD_q2_del[ 6] <= SizeD_q2_del[ 5];
    SizeD_q2_del[ 7] <= SizeD_q2_del[ 6];
    SizeD_q2_del[ 8] <= SizeD_q2_del[ 7];
    SizeD_q2_del[ 9] <= SizeD_q2_del[ 8];
    SizeD_q2_del[10] <= SizeD_q2_del[ 9];
    SizeD_q2_del[11] <= SizeD_q2_del[10];
    SizeD_q2_del[12] <= SizeD_q2_del[11];
    SizeD_q2_del[13] <= SizeD_q2_del[12];
    SizeD_q2_del[14] <= SizeD_q2_del[13];
    SizeD_q2_del[15] <= SizeD_q2_del[14];
    SizeD_q2_del[16] <= SizeD_q2_del[15];
    SizeD_q2_del[17] <= SizeD_q2_del[16];
    SizeD_q2_del[18] <= SizeD_q2_del[17];
    SizeD_q2_del[19] <= SizeD_q2_del[18];
    SizeD_q2_del[20] <= SizeD_q2_del[19];
    SizeD_q2_del[21] <= SizeD_q2_del[20];
    SizeD_q2_del[22] <= SizeD_q2_del[21];
end                         
    
always @(posedge CLK) begin
    ADT_del[1] <= ADT;
    ADT_del[ 2] <= ADT_del[ 1];
    ADT_del[ 3] <= ADT_del[ 2];
    ADT_del[ 4] <= ADT_del[ 3];
    ADT_del[ 5] <= ADT_del[ 4];
    ADT_del[ 6] <= ADT_del[ 5];
    ADT_del[ 7] <= ADT_del[ 6];
    ADT_del[ 8] <= ADT_del[ 7];
    ADT_del[ 9] <= ADT_del[ 8];
    ADT_del[10] <= ADT_del[ 9];
    ADT_del[11] <= ADT_del[10];
end    
    


    
    
endmodule
