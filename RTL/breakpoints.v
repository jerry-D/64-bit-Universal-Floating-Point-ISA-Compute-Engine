// breakpoints.v
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

module breakpoints (
    CLK,
    RESET,
    Instruction_q0,
    Instruction_q0_del,
    pre_PC,
    
    PC_EQ_BRKA_en, 
    PC_EQ_BRKB_en, 
    PC_GT_BRKA_en,
    PC_LT_BRKB_en,
    PC_AND_en,
        
    event_det,
    
    evnt_cntr,

    trigger_A,
    trigger_B,
    
    sstep,
    frc_brk,
    broke,
    skip_cmplt,
    break_q0,
    break_q1,
    break_q2,
    ind_mon_read_q0,
    ind_mon_write_q2,
    mon_read_addrs,
    mon_write_addrs,
    mon_read_size,
    mon_write_size,
    mon_req
    );

input CLK;
input RESET;
input  [63:0] Instruction_q0;
input  [`PCWIDTH-1:0] pre_PC;
output [63:0] Instruction_q0_del;


input PC_EQ_BRKA_en; 
input PC_EQ_BRKB_en; 
input PC_GT_BRKA_en;
input PC_LT_BRKB_en;
input PC_AND_en;

output event_det;
input  [31:0] evnt_cntr;
input  [`PCWIDTH-1:0] trigger_A;
input  [`PCWIDTH-1:0] trigger_B;
    
input sstep;

input frc_brk;

output broke;

output skip_cmplt;

output break_q0;
output break_q1;
output break_q2;
output ind_mon_read_q0;
output ind_mon_write_q2;
input  [31:0] mon_read_addrs;  
input  [31:0] mon_write_addrs; 
input  [2:0] mon_read_size;
input  [2:0] mon_write_size;

input  mon_req;

reg break_q0;
reg break_q1;
reg break_q2;

reg [1:0] break_state;

reg broke;

reg skip;

reg skip_cmplt;


reg [1:0]mon_state;

reg mon_req_q0;

reg [63:0] monitor_instructionq;


wire mon_cycl_det;
wire any_break_det;

wire [63:0] Instruction_q0_del;
wire [63:0] monitor_instruction;

wire PC_EQ_BRKA;
wire PC_GT_BRKA;
wire PC_EQ_BRKB;
wire PC_LT_BRKB;
wire PC_GT_BRKA_AND_LT_BRKB;

wire ind_mon_read;
wire ind_mon_write;
wire ind_mon_read_q0;
//wire ind_mon_write_q2;
                                                                                                         
wire event_det; 

reg ind_mon_write_q1;
reg ind_mon_write_q2;
reg mon_req_q1;
reg mon_req_q2;

assign ind_mon_read  = |mon_read_addrs[31:15];                                                                                       
assign ind_mon_write = |mon_write_addrs[31:15];
assign ind_mon_read_q0  = ind_mon_read  && break_q0;
//assign ind_mon_write_q2 = ind_mon_write && break_q2;

always @(posedge CLK) begin
    ind_mon_write_q1 <= ind_mon_write && mon_req_q0;
    ind_mon_write_q2 <= ind_mon_write_q1;   
end

assign PC_EQ_BRKA = (pre_PC == trigger_A) && PC_EQ_BRKA_en;  
assign PC_EQ_BRKB = (pre_PC == trigger_B) && PC_EQ_BRKB_en;  
assign PC_GT_BRKA = (pre_PC > trigger_A)  && PC_GT_BRKA_en;
assign PC_LT_BRKB = (pre_PC < trigger_B)  && PC_LT_BRKB_en;
assign PC_GT_BRKA_AND_LT_BRKB = (pre_PC > trigger_A) && 
                                (pre_PC < trigger_B) &&
                                 PC_AND_en;

assign event_det = (PC_EQ_BRKA  ||
                    PC_EQ_BRKB  ||
                    PC_GT_BRKA  || 
                    PC_LT_BRKB  ||
                    PC_GT_BRKA_AND_LT_BRKB);

assign any_break_det = (event_det && (evnt_cntr == 32'h0000_0001)) ||
                       frc_brk   ||
                       broke   ;
                       
                       
assign monitor_instruction = {5'b00000, mon_write_size, ind_mon_write, mon_write_addrs[14:0], 1'b0, mon_read_size, ind_mon_read, mon_read_addrs[14:0], 5'b00110, 15'h0000};    
assign Instruction_q0_del = break_q0 ?  monitor_instructionq : Instruction_q0;  

assign mon_cycl_det = mon_req && (mon_state[1:0]==2'b00);


always @(posedge CLK) begin
    if (RESET) begin
        mon_req_q0 <= 1'b0;
        mon_state <= 2'b00;
        monitor_instructionq <= 64'h0300003000030000;
    end
    else case(mon_state)
          2'b00 : if (mon_cycl_det) begin
                      monitor_instructionq <= monitor_instruction; 
                      mon_req_q0 <= mon_req;
                      mon_state <= 2'b01;
                  end    
          2'b01 : begin
                     monitor_instructionq <= 64'h0300003000030000;
                     mon_req_q0 <= 1'b0;           
                     mon_state <= 2'b10;
                  end    
          2'b10 : if (~mon_req) mon_state <= 2'b00; 
        default : begin
                     mon_req_q0 <= 1'b0;   
                     mon_state <= 2'b00;
                     monitor_instructionq <= 64'h0300003000030000;
                  end
         endcase          
end

always @(posedge CLK) begin
    if (RESET) begin                                                                                               
        break_q0 <= 1'b1;                                                                                          
        break_q1 <= 1'b1;                                                                                          
        break_q2 <= 1'b1;                                                                                          
    end
    else begin
        mon_req_q1 <= mon_req_q0;                                                                                                     
        mon_req_q2 <= mon_req_q1;                                                                                                     
        break_q0 <= (any_break_det && ~skip) || mon_cycl_det; 
        break_q1 <= break_q0;
        break_q2 <= break_q1;
    end                 
end   

//  sstep
always @(posedge CLK) begin
    if (RESET) begin
        broke <= 1'b0;
        break_state <=2'b00;
        skip <= 1'b0;
        skip_cmplt <= 1'b0;
    end
    else begin
        case(break_state) 
            2'b00 : if ((event_det && (evnt_cntr == 32'h0000_0001)) || frc_brk) begin 
                        broke <= 1'b1;
                        break_state <= 2'b01;
                    end
            2'b01 : if (sstep) begin
                        skip <= 1'b1;
                        skip_cmplt <= 1'b0;
                        break_state <= 2'b10;
                    end
            2'b10 : begin
                        skip <= 1'b0;
                        skip_cmplt <= 1'b1;
                        if (~sstep) begin
                           break_state <= 2'b11;
                           skip_cmplt <= 1'b0;
                        end    
                    end    
            2'b11 : if (~frc_brk) begin
                        broke <= 1'b0;
                        break_state <= 2'b00;
                    end
                    else break_state <= 2'b01;            
        endcase
    end
end   


endmodule
