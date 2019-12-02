//tap.v
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
 
module tap( CLOCK_DR, CLOCK_IR, ENABLE, RESET, SELECT, SHIFT_DR, SHIFT_IR, TCK, TMS,
            UPDATE_DR, UPDATE_IR, XTCK, XTRST );


output CLOCK_DR, CLOCK_IR, ENABLE, RESET, SELECT, SHIFT_DR, SHIFT_IR;
input TCK, TMS;
output UPDATE_DR, UPDATE_IR;
input XTCK, XTRST;

reg [3:0] TAP;
reg RESET;
reg ENABLE;
reg SHIFT_IRq;
reg SHIFT_DRq;
reg CLOCK_IRq;
reg UPDATE_IR;
reg CLOCK_DRq;
reg UPDATE_DR;


wire SELECT;
wire SHIFT_IR;
wire SHIFT_DR;
wire CLOCK_IR;
wire CLOCK_DR;
wire TRST;

assign SELECT = TAP[0];
assign SHIFT_IR = !SHIFT_IRq;
assign SHIFT_DR = !SHIFT_DRq;
assign CLOCK_IR = !CLOCK_IRq;
assign CLOCK_DR = !CLOCK_DRq;

assign TRST = !XTRST;

always @(posedge TCK or posedge TRST) begin
	if (TRST) begin
		TAP[3:0] <= 4'b1111;
	end
	else begin
		TAP[3] <= ~(~(TAP[3] && ~TAP[1] && ~TMS)   		&& 
				    ~(TMS && ~TAP[2])               	&& 
				    ~(TMS && ~TAP[3])               	&& 
				    ~(TAP[1] && TAP[0] && TMS));

		TAP[2] <= ~(~(TAP[2] && ~TAP[3] && ~TMS)   		&& 
				    ~(~TAP[1] && ~TMS)              	&& 
				    ~(TAP[2] && ~TAP[0] && ~TMS)     	&& 
				    ~(~TAP[3] && ~TAP[0] && ~TMS)    	&& 
				    ~(TAP[1] && TMS && ~TAP[2])      	&& 
				    ~(TAP[3] && TAP[1] && TAP[0] && TMS));

		TAP[1] <= ~(~(TAP[1] && ~TAP[2]) 				&& 
				    ~(TAP[3] && TAP[1]) 				&& 
				    ~(TMS && ~TAP[2]));

		TAP[0] <= ~(~(TAP[0] && ~TAP[1]) 				&& 
				    ~(TAP[2] && TAP[0]) 				&& 
				    ~(TAP[1] && ~TAP[2] && ~TMS) 		&& 
				    ~(TAP[1] && ~TAP[3] && ~TAP[2] && ~TAP[0]));
	end
end

always @(posedge XTCK or posedge TRST) begin
	if (TRST) begin
		RESET <= 1'b1;
		ENABLE <= 1'b0;
		SHIFT_IRq <= 1'b0;
		SHIFT_DRq <= 1'b0;
		CLOCK_IRq <= 1'b1;
		CLOCK_DRq <= 1'b1;	
		UPDATE_IR <= 1'b0;
		UPDATE_DR <= 1'b0;
	end
	else begin
		RESET <= &TAP[3:0];
		ENABLE    <= ~(~(TAP[2] &&  TAP[0] && ~TAP[3] && ~TAP[1]) && 
					   ~(TAP[2] && ~TAP[3] && ~TAP[1] && ~TAP[0]));

		SHIFT_IRq <=   ~(TAP[2] &&  TAP[0] && ~TAP[3] && ~TAP[1]);

		SHIFT_DRq <=   ~(TAP[2] && ~TAP[3] && ~TAP[1] && ~TAP[0]);

		CLOCK_IRq <=   ~(TAP[2] &&  TAP[0] && ~TAP[3]);

		CLOCK_DRq <=   ~(TAP[2] && ~TAP[3] && ~TAP[0]);

		UPDATE_IR <=     TAP[3] &&  TAP[1] && TAP[0]  && ~TAP[2];
		UPDATE_DR <=     TAP[3] && ~TAP[2] && TAP[1]  && ~TAP[0];

	end
end




endmodule // tap
