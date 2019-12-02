 `timescale 1ns/100ps
// HUJTAG.v
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

module HUJTAG ( TDI,
                TDO,
                TMS,
                TCK,
                TRSTB,

                UTDI,        // output to user Data Registers
                UTDO,        // input  from user Data Registers
                UDRCAP,
                UDRCK,
                UDRSH,
                UDRUPD,
                URSTB,
                UIREG0,
                UIREG1,
                UIREG2,
                UIREG3,
                UIREG4,
                UIREG5,
                UIREG6,
                UIREG7);

input			TDI;
output			TDO;
input			TMS;
input			TCK;
input			TRSTB;

output          UTDI;        // output
input           UTDO;        // input
output          UDRCAP;
output          UDRCK;
output          UDRSH;
output          UDRUPD;
output          URSTB;
output          UIREG0;
output          UIREG1;
output          UIREG2;
output          UIREG3;
output          UIREG4;
output          UIREG5;
output          UIREG6;
output          UIREG7;

reg		[7:0]	UIREG;
reg				TDOq;
reg		[7:0]	IR_SHFTR;

wire			CLOCK_IR;
wire			ENABLE;
wire			SELECT;
wire			SHIFT_IR;
wire			TCK;
wire			TMS;
wire			UPDATE_IR;
wire			TRSTB;

wire			UDRCK;
wire			UDRCAP;
wire			UDRSH;
wire			UDRUPD;
wire			URSTB;
wire			UTDI;
wire			URST;

wire			UIREG7;
wire			UIREG6;
wire			UIREG5;
wire			UIREG4;
wire			UIREG3;
wire			UIREG2;
wire			UIREG1;
wire			UIREG0;	  

assign			UIREG7 = UIREG[7];
assign			UIREG6 = UIREG[6];
assign			UIREG5 = UIREG[5];
assign			UIREG4 = UIREG[4];
assign			UIREG3 = UIREG[3];
assign			UIREG2 = UIREG[2];
assign			UIREG1 = UIREG[1];
assign			UIREG0 = UIREG[0];

assign			UDRCK  = TCK;
assign			TDO = ENABLE ?  TDOq : 1'bz; 
assign			UTDI = TDI;
assign			URSTB = ~URST;

always @(negedge TCK) begin
	TDOq <= SELECT ? IR_SHFTR[0] : UTDO;
end

always	@(posedge TCK or posedge URST) begin
	if (URST) begin
		UIREG <= 8'h00;
		IR_SHFTR <= 8'h00;
	end
	else begin
		if (CLOCK_IR)  IR_SHFTR <= SHIFT_IR ? {TDI, IR_SHFTR[7:1]} : 8'h08;
		else if (UPDATE_IR) UIREG   <= IR_SHFTR;
	end
end			

tap tap( .CLOCK_DR(UDRCAP), 
		 .CLOCK_IR(CLOCK_IR), 
		 .ENABLE(ENABLE), 
		 .RESET(URST), 
		 .SELECT(SELECT), 
		 .SHIFT_DR(UDRSH), 
		 .SHIFT_IR(SHIFT_IR), 
		 .TCK(TCK), 
		 .TMS(TMS),
		 .UPDATE_DR(UDRUPD), 
		 .UPDATE_IR(UPDATE_IR), 
		 .XTCK(~TCK), 
		 .XTRST(TRSTB));

endmodule  // UJTAG