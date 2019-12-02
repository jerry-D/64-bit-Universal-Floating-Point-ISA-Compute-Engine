// RAM_func.v
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

 `timescale 1ns/1ns

module RAM_func #(parameter ADDRS_WIDTH = 10, parameter DATA_WIDTH = 32) (
    CLK,
    wren,
    wraddrs,
    wrdata,
    rdenA,
    rdaddrsA,
    rddataA,
    rdenB,
    rdaddrsB,
    rddataB);    

input  CLK;
input  wren;
input  [ADDRS_WIDTH-1:0] wraddrs;
input  [DATA_WIDTH-1:0] wrdata;
input  rdenA;
input  [ADDRS_WIDTH-1:0] rdaddrsA;
output [DATA_WIDTH-1:0] rddataA;
input  rdenB;    
input  [ADDRS_WIDTH-1:0] rdaddrsB;
output [DATA_WIDTH-1:0] rddataB;


reg    [DATA_WIDTH-1:0] triportRAMA[(2**ADDRS_WIDTH)-1:0];
reg    [DATA_WIDTH-1:0] triportRAMB[(2**ADDRS_WIDTH)-1:0];

integer i;

initial begin
   i = (2**ADDRS_WIDTH)-1;
   while(i) 
    begin
        triportRAMA[i] = 0;
        triportRAMB[i] = 0;
        i = i - 1;
    end
    triportRAMA[0] = 0;
    triportRAMB[0] = 0;
end

reg [DATA_WIDTH-1:0] rddataA;
reg [DATA_WIDTH-1:0] rddataB;
    
always @(posedge CLK) begin
    if (wren) triportRAMA[wraddrs] <= wrdata;
    if (rdenA) rddataA <=  (wren && (wraddrs==rdaddrsA)) ? wrdata : triportRAMA[rdaddrsA];
end
always @(posedge CLK) begin
    if (wren) triportRAMB[wraddrs] <= wrdata;
    if (rdenB) rddataB <=  (wren && (wraddrs==rdaddrsB)) ? wrdata : triportRAMB[rdaddrsB];  
end

endmodule    