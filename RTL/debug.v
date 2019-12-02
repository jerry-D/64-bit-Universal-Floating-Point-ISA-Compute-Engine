//debug.v
//
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

module debug (
    CLK,
    RESET_IN,
    RESET_OUT,
    
    HTCK  ,
    HTRSTn,
    HTMS  ,
    HTDI  ,
    HTDO  ,
    
    Instruction_q0,
    Instruction_q0_del,
    pre_PC,
    PC,     
    pc_q2, 
    done,     
    discont,
    break_q0,
    break_q1,
    break_q2,
    event_det,
    swbreakDetect,
    ind_mon_read_q0,
    ind_mon_write_q2,
    mon_write_reg,                 //pre-registered data to be written during monitor write
    mon_read_reg,                  //data captured during monitor read
    mon_read_addrs,                //monitor read-from address
    mon_write_addrs_q2,            //monitor write-to address

    HOST_wraddrs,
    HOST_wrdata,
    HOST_wrSize,
    HOST_wren,
    
    HOST_rdaddrs,
    HOST_rddata,
    HOST_rdSize,
    HOST_rden
    );
    
input         CLK;
input         RESET_IN;
output        RESET_OUT;

input  HTCK;
input  HTRSTn;
input  HTMS;
input  HTDI;
output HTDO;

input  [63:0] Instruction_q0;
output [63:0] Instruction_q0_del;
input  [`PCWIDTH-1:0] pre_PC;
input  [`PCWIDTH-1:0] PC;   
input  [`PCWIDTH-1:0] pc_q2;
input         done;    
input         discont;
output        break_q0;
output        break_q1;
output        break_q2;
output        event_det;
output        swbreakDetect;
output        ind_mon_read_q0; 
output        ind_mon_write_q2;
output [63:0] mon_write_reg;
input  [63:0] mon_read_reg;

output [31:0] mon_read_addrs; 
output [31:0] mon_write_addrs_q2;

input [4:0]  HOST_wraddrs;
input [63:0] HOST_wrdata;
input [1:0]  HOST_wrSize;
input        HOST_wren;

input [4:0]   HOST_rdaddrs;
output [63:0] HOST_rddata;
input [1:0]   HOST_rdSize;
input         HOST_rden;
             
parameter mon_read_addrs_addrs  = 8'h20;
parameter mon_write_addrs_addrs = 8'h21;
parameter mon_write_reg_addrs   = 8'h22; 
parameter mon_read_reg_addrs    = 8'h23;
parameter evnt_cntr_addrs       = 8'h24;   
parameter trigger_A_addrs       = 8'h25;
parameter trigger_B_addrs       = 8'h26;
parameter brk_cntrl_addrs       = 8'h27;
parameter brk_status_addrs      = 8'h28;
parameter sstep_addrs           = 8'h29;  
parameter trace_newest_addrs    = 8'h30;
parameter trace_1_addrs         = 8'h31;
parameter trace_2_addrs         = 8'h32;
parameter trace_oldest_addrs    = 8'h33;
parameter bypass                = 8'hFF;

parameter SWBREAK   = 64'h127FF30000000000;

reg [63:0] rddata;


//-- debug source from JTAG ---------------------------------
`ifdef CPU_HAS_JTAG   
reg DEBUG_SEL;    // 1=JTAG 0=host processor  
reg [31:0] mon_read_addrs_j;    
reg [31:0] mon_write_addrs_j;   
reg [2:0]  mon_read_size_j;
reg [2:0]  mon_write_size_j;
reg [63:0] mon_write_reg_j;

reg [`PCWIDTH-1:0] trigger_A_j;
reg [`PCWIDTH-1:0] trigger_B_j;

reg PC_EQ_BRKA_en_j;
reg PC_EQ_BRKB_en_j;
reg PC_GT_BRKA_en_j;
reg PC_LT_BRKB_en_j;
reg PC_AND_en_j;   
reg mon_req_j;   
reg sstep_j;     
reg frc_brk_j;  
reg FORCE_RESET_j; 

reg [31:0] evnt_cntr_j;
`else
wire DEBUG_SEL;
wire [31:0] mon_read_addrs_j;    
wire [31:0] mon_write_addrs_j;   
wire [2:0]  mon_read_size_j;
wire [2:0]  mon_write_size_j;
wire [63:0] mon_write_reg_j;

wire [`PCWIDTH-1:0] trigger_A_j;
wire [`PCWIDTH-1:0] trigger_B_j;

wire PC_EQ_BRKA_en_j;
wire PC_EQ_BRKB_en_j;
wire PC_GT_BRKA_en_j;
wire PC_LT_BRKB_en_j;
wire PC_AND_en_j;   
wire mon_req_j;   
wire sstep_j;     
wire frc_brk_j;  
wire FORCE_RESET_j; 
wire [31:0] evnt_cntr_j;

assign DEBUG_SEL = 0;
assign mon_read_addrs_j  = 0;  
assign mon_write_addrs_j = 0;  
assign mon_read_size_j   = 0;
assign mon_write_size_j  = 0;
assign mon_write_reg_j  = 0;
                         
assign trigger_A_j       = 0;
assign trigger_B_j       = 0;

assign PC_EQ_BRKA_en_j   = 0;
assign PC_EQ_BRKB_en_j   = 0;
assign PC_GT_BRKA_en_j   = 0;
assign PC_LT_BRKB_en_j   = 0;
assign PC_AND_en_j       = 0;
assign mon_req_j         = 0;
assign sstep_j           = 0;
assign frc_brk_j         = 0;
assign FORCE_RESET_j     = 0;
                         
assign evnt_cntr_j       = 0;
`endif
//-----------------------------------------------------------


//-- debug source from host processor -----------------------
reg [31:0] mon_read_addrs_h;    
reg [31:0] mon_write_addrs_h;   
reg [1:0]  mon_read_size_h;
reg [1:0]  mon_write_size_h;
reg [63:0] mon_write_reg_h;

reg [`PCWIDTH-1:0] trigger_A_h;
reg [`PCWIDTH-1:0] trigger_B_h;

reg PC_EQ_BRKA_en_h;
reg PC_EQ_BRKB_en_h;
reg PC_GT_BRKA_en_h;
reg PC_LT_BRKB_en_h;
reg PC_AND_en_h;   
reg mon_req_h;   
reg sstep_h;     
reg frc_brk_h;  
reg FORCE_RESET_h; 

reg [31:0] evnt_cntr_h;

wire  event_det;

//-----------------------------------------------------------

wire [4:0] hwr_regSel;
assign hwr_regSel = HOST_wraddrs[4:0];
always @(posedge CLK) begin
    if (RESET_IN) begin
        mon_read_addrs_h  <= 0;   
        mon_write_addrs_h <= 0;
        mon_read_size_h   <= 0;
        mon_write_size_h  <= 0;
        mon_write_reg_h   <= 0;
        trigger_A_h       <= 0;
        trigger_B_h       <= 0;
        PC_EQ_BRKA_en_h   <= 0;
        PC_EQ_BRKB_en_h   <= 0;
        PC_GT_BRKA_en_h   <= 0;
        PC_LT_BRKB_en_h   <= 0;
        PC_AND_en_h       <= 0;
        mon_req_h         <= 0;
        sstep_h           <= 0;
        frc_brk_h         <= 1'b1; //assert force break when external reset is active
        FORCE_RESET_h     <= 0;
        evnt_cntr_h       <= 0;
    end
    else if (HOST_wren && ~(hwr_regSel==5'b11001))                      
        case(hwr_regSel)
            5'b00000 : {sstep_h, frc_brk_h, FORCE_RESET_h} <= HOST_wrdata[2:0]; 
            5'b00001 : {mon_req_h, mon_write_size_h[1:0], mon_read_size_h[1:0]} <= HOST_wrdata[4:0]; 
            5'b00010 : {PC_AND_en_h, PC_GT_BRKA_en_h, PC_LT_BRKB_en_h, PC_EQ_BRKA_en_h, PC_EQ_BRKB_en_h}  <= HOST_wrdata[4:0];  
            5'b00100 : trigger_A_h <= HOST_wrdata[`PCWIDTH-1:0];
            5'b01000 : trigger_B_h <= HOST_wrdata[`PCWIDTH-1:0];
            5'b01100 : mon_read_addrs_h <= HOST_wrdata[31:0];
            5'b10000 : mon_write_addrs_h <= HOST_wrdata[31:0];
            5'b10100 : evnt_cntr_h <= HOST_wrdata[31:0];
            5'b11000 : begin
                           if (HOST_wrSize[1:0]==2'b11) mon_write_reg_h[63:0] <= HOST_wrdata[63:0]; 
                           else if (HOST_wrSize[1:0]==2'b10) mon_write_reg_h[63:0] <= {32'b0, HOST_wrdata[31:0]};
                           else if (HOST_wrSize[1:0]==2'b01) mon_write_reg_h[63:0] <= {48'b0, HOST_wrdata[15:0]};
                           else mon_write_reg_h[63:0] <= {56'b0, HOST_wrdata[7:0]};
                       end 
        endcase
    else if (HOST_wren && (hwr_regSel==5'b11001))  begin
        mon_write_addrs_h <= mon_write_addrs_h + (mon_write_addrs_h[31] ? 1'b1 : mon_write_size_h[1:0]);
        if (HOST_wrSize[1:0]==2'b11) mon_write_reg_h[63:0] <= HOST_wrdata[63:0]; 
        else if (HOST_wrSize[1:0]==2'b10) mon_write_reg_h[63:0] <= {32'b0, HOST_wrdata[31:0]};
        else if (HOST_wrSize[1:0]==2'b01) mon_write_reg_h[63:0] <= {48'b0, HOST_wrdata[15:0]};
        else mon_write_reg_h[63:0] <= {56'b0, HOST_wrdata[7:0]};
    end    
    else if (event_det && ~DEBUG_SEL && (evnt_cntr_h > 32'b00000001)) evnt_cntr_h <= evnt_cntr_h - 1'b1;                     
end

reg [63:0] HOST_rddata;                                   
reg swbreakDetect_q1, swbreakDetect_q2;
reg resetDel;

wire [31:0] mon_read_addrs;    
wire [31:0] mon_write_addrs;   
wire [2:0]  mon_read_size;
wire [2:0]  mon_write_size;
wire [63:0] mon_write_reg;

wire [`PCWIDTH-1:0] trigger_A;
wire [`PCWIDTH-1:0] trigger_B;

wire PC_EQ_BRKA_en;
wire PC_EQ_BRKB_en;
wire PC_GT_BRKA_en;
wire PC_LT_BRKB_en;
wire PC_AND_en;   
wire mon_req;   
wire sstep;     
wire frc_brk;  
wire FORCE_RESET; 
wire [31:0] evnt_cntr;
wire  broke;                                                                  
wire  skip_cmplt;
wire  [63:0] Instruction_q0_del;
wire  break_q0;                                                                   
wire  break_q1;                                                                   
wire  break_q2;                                                                   
wire [63:0] trace_newest;
wire [63:0] trace_1;
wire [63:0] trace_2;
wire [63:0] trace_oldest;
wire ind_mon_read_q0; 
wire ind_mon_write_q2;
wire swbreakDetect;
wire [63:0] brk_status_reg;
wire          RESET_OUT;
wire [4:0] hrd_regSel;

reg [31:0] mon_write_addrs_q0;
reg [31:0] mon_write_addrs_q1;
reg [31:0] mon_write_addrs_q2;
always @(posedge CLK) begin
    mon_write_addrs_q0 <= mon_write_addrs;    
    mon_write_addrs_q1 <= mon_write_addrs_q0;    
    mon_write_addrs_q2 <= mon_write_addrs_q1;    
end

assign hrd_regSel = HOST_rdaddrs[4:0];
always @(*) begin
    if (RESET_IN) HOST_rddata[63:0] <= 0;
    else if (HOST_rden)
        case(hrd_regSel) 
            5'b00000 : HOST_rddata[63:0] = {56'b0, done, skip_cmplt, sstep_h, swbreakDetect, broke, frc_brk_h, RESET_IN, FORCE_RESET_h}; 
            5'b00001 : HOST_rddata[63:0] = {59'b0, mon_req_h, mon_write_size_h[1:0], mon_read_size_h[1:0]}; 
            5'b00010 : HOST_rddata[63:0] = {59'b0,PC_AND_en_h, PC_GT_BRKA_en_h, PC_LT_BRKB_en_h, PC_EQ_BRKA_en_h, PC_EQ_BRKB_en_h}; 
            5'b00100 : HOST_rddata[63:0] = {{64-`PCWIDTH{1'b0}}, trigger_A_h};
            5'b01000 : HOST_rddata[63:0] = {{64-`PCWIDTH{1'b0}}, trigger_B_h};
            5'b01100 : HOST_rddata[63:0] = {32'b0, mon_read_addrs_h};
            5'b10000 : HOST_rddata[63:0] = {32'b0, mon_write_addrs_h};
            5'b10100 : HOST_rddata[63:0] = {32'b0, evnt_cntr_h};
            5'b11000 : begin
                           if (HOST_rdSize[1:0]==2'b11) HOST_rddata[63:0] = mon_read_reg[63:0];
                           else if (HOST_rdSize[1:0]==2'b10) HOST_rddata[63:0] = {32'b0, mon_read_reg[31:0]}; 
                           else if (HOST_rdSize[1:0]==2'b01) HOST_rddata[63:0] = {48'b0, mon_read_reg[15:0]}; 
                           else HOST_rddata[63:0] = {56'b0, mon_read_reg[7:0]}; 
                       end
             default : HOST_rddata[63:0] = 0;            
        endcase 
    else HOST_rddata[63:0] = 0;       
end            
            
assign mon_read_addrs  = DEBUG_SEL ? mon_read_addrs_j  : mon_read_addrs_h; 
assign mon_write_addrs = DEBUG_SEL ? mon_write_addrs_j : mon_write_addrs_h;
assign mon_read_size   = DEBUG_SEL ? mon_read_size_j   : mon_read_size_h;  
assign mon_write_size  = DEBUG_SEL ? mon_write_size_j  : mon_write_size_h; 
assign mon_write_reg   = DEBUG_SEL ? mon_write_reg_j   : mon_write_reg_h;  
                                                                          
assign trigger_A       = DEBUG_SEL ? trigger_A_j       : trigger_A_h;      
assign trigger_B       = DEBUG_SEL ? trigger_B_j       : trigger_B_h;      

assign PC_EQ_BRKA_en   = DEBUG_SEL ? PC_EQ_BRKA_en_j   : PC_EQ_BRKA_en_h;  
assign PC_EQ_BRKB_en   = DEBUG_SEL ? PC_EQ_BRKB_en_j   : PC_EQ_BRKB_en_h;  
assign PC_GT_BRKA_en   = DEBUG_SEL ? PC_GT_BRKA_en_j   : PC_GT_BRKA_en_h;  
assign PC_LT_BRKB_en   = DEBUG_SEL ? PC_LT_BRKB_en_j   : PC_LT_BRKB_en_h;  
assign PC_AND_en       = DEBUG_SEL ? PC_AND_en_j       : PC_AND_en_h;      
assign mon_req         = DEBUG_SEL ? mon_req_j         : mon_req_h || (HOST_wren && (hwr_regSel==5'b11001));        
assign sstep           = DEBUG_SEL ? sstep_j           : sstep_h;          
assign frc_brk         = DEBUG_SEL ? frc_brk_j         : frc_brk_h;        
assign FORCE_RESET     = DEBUG_SEL ? FORCE_RESET_j     : FORCE_RESET_h;    
assign evnt_cntr       = DEBUG_SEL ? evnt_cntr_j       : evnt_cntr_h;      

assign brk_status_reg = {`DESIGN_ID, 25'b0, done, skip_cmplt, sstep, swbreakDetect, broke, frc_brk, RESET_IN, FORCE_RESET};
assign swbreakDetect = ((Instruction_q0==SWBREAK) || swbreakDetect_q1 || swbreakDetect_q2) && ~resetDel;

always @(posedge CLK)
    if (RESET_OUT) begin
        swbreakDetect_q1 <= 0;
        swbreakDetect_q2 <= 0;
    end
    else begin        
        swbreakDetect_q1 <= (Instruction_q0==SWBREAK);
        swbreakDetect_q2 <= swbreakDetect_q1;
    end

always @(posedge CLK) resetDel <= RESET_OUT;
      
breakpoints breakpoints(                                                                                   
    .CLK           (CLK          ),                                                               
    .RESET         (RESET_OUT    ),                                                               
    .Instruction_q0(Instruction_q0),                                                               
    .Instruction_q0_del(Instruction_q0_del),                                                               
    .pre_PC        (pre_PC       ),                                                               
                                           
    .PC_EQ_BRKA_en (PC_EQ_BRKA_en),
    .PC_EQ_BRKB_en (PC_EQ_BRKB_en),
    .PC_GT_BRKA_en (PC_GT_BRKA_en),
    .PC_LT_BRKB_en (PC_LT_BRKB_en),
    .PC_AND_en     (PC_AND_en    ),
        
    .event_det     (event_det    ),
    
    .evnt_cntr     (evnt_cntr    ),

    .trigger_A     (trigger_A    ),
    .trigger_B     (trigger_B    ),
    
    .sstep         (sstep        ),
    .frc_brk       (frc_brk      ),                                     
    .broke         (broke        ),                                     
    .skip_cmplt    (skip_cmplt   ),                                     
    .break_q0      (break_q0     ),
    .break_q1      (break_q1     ),
    .break_q2      (break_q2     ),
    .ind_mon_read_q0 (ind_mon_read_q0), 
    .ind_mon_write_q2(ind_mon_write_q2),
    .mon_read_addrs (mon_read_addrs),   
    .mon_write_addrs(mon_write_addrs),
    .mon_read_size (mon_read_size),
    .mon_write_size(mon_write_size),
    .mon_req       (mon_req      )
    );                 

trace_buf trace_buf(
    .CLK       (CLK         ),
    .RESET     (RESET_OUT   ),
    .discont   (discont     ),
    .PC        (PC          ),
    .pc_q2     (pc_q2       ),
    .trace_reg0(trace_newest),
    .trace_reg1(trace_1     ),
    .trace_reg2(trace_2     ),
    .trace_reg3(trace_oldest)
    );  
          
`ifdef CPU_HAS_JTAG   
reg [63:0]    SHIFT_REG;
wire          UTDI_;
wire          UDRCAP_;
wire          UDRCK_;
wire          UDRSH_;
wire          UDRUPD_;
wire          URSTB_;
wire [7:0]    UIREG_;

wire          URST_;
assign        URST_        = ~URSTB_;

always @(posedge UDRCK_ or posedge URST_) begin
    if (URST_) begin
        SHIFT_REG         <= 64'b0;
        mon_read_addrs_j  <= 32'b0;   
        mon_read_size_j   <= 3'b0;                                                               
        mon_write_addrs_j <= 32'b0;                                                                   
        mon_write_size_j  <= 3'b0;                                                               
        mon_write_reg_j   <= 64'b0; 
        evnt_cntr_j       <= 32'h0000_0001;
        trigger_A_j       <= `PCWIDTH'b0;
        trigger_B_j       <= `PCWIDTH'b0;
        PC_EQ_BRKA_en_j   <= 1'b0;
        PC_EQ_BRKB_en_j   <= 1'b0;
        PC_GT_BRKA_en_j   <= 1'b0;
        PC_LT_BRKB_en_j   <= 1'b0;
        PC_AND_en_j       <= 1'b0;
        mon_req_j         <= 1'b0;
        sstep_j           <= 1'b0;
        frc_brk_j         <= 1'b0;
        FORCE_RESET_j     <= 1'b0;
        DEBUG_SEL         <= 1'b0;  //1=JTAG 0=HOST PROCESSOR
    end

    else begin

        if (UDRCAP_ && ~UDRSH_) begin  //data register capture
            case (UIREG_)
                mon_read_addrs_addrs  : SHIFT_REG <= {29'b0, mon_read_size, mon_read_addrs};
                mon_write_addrs_addrs : SHIFT_REG <= {29'b0, mon_write_size, mon_write_addrs};
                mon_write_reg_addrs   : SHIFT_REG <= mon_write_reg;     //data to be written during monitor write cycle
                mon_read_reg_addrs    : SHIFT_REG <= mon_read_reg;      //data captured during monitor read cycle
                evnt_cntr_addrs       : SHIFT_REG <= {32'b0, evnt_cntr};
                trigger_A_addrs       : SHIFT_REG <= {64-`PCWIDTH'b0, trigger_A};
                trigger_B_addrs       : SHIFT_REG <= {64-`PCWIDTH'b0, trigger_B};
                brk_cntrl_addrs       : SHIFT_REG <= {54'b0, 
                                                      DEBUG_SEL,       //a "1" here overrides Host CPU Real-Time Monitor/debug operation
                                                      PC_EQ_BRKA_en, 
                                                      PC_EQ_BRKB_en, 
                                                      PC_GT_BRKA_en, 
                                                      PC_LT_BRKB_en, 
                                                      PC_AND_en, 
                                                      mon_req,
                                                      sstep  ,
                                                      frc_brk, 
                                                      FORCE_RESET};
                brk_status_addrs      : SHIFT_REG <= brk_status_reg;
                sstep_addrs           : SHIFT_REG <= 64'h600DFEED600DFEED;
                trace_newest_addrs    : SHIFT_REG <= trace_newest;
                trace_1_addrs         : SHIFT_REG <= trace_1;     
                trace_2_addrs         : SHIFT_REG <= trace_2;     
                trace_oldest_addrs    : SHIFT_REG <= trace_oldest;
                bypass                : SHIFT_REG <= 64'hFFFF_FFFF_FFFF_FFFF;
                              default : SHIFT_REG <= 64'hBADFEED0BADFEED0;
            endcase 
        end
		else if (UDRSH_ && (UIREG_==bypass)) SHIFT_REG[0] <= UTDI_;
        else if (UDRSH_ ) SHIFT_REG <= {UTDI_, SHIFT_REG[63:1]};


        if (UDRUPD_) begin  //data register update
            case (UIREG_)
                mon_read_addrs_addrs  : begin
                                            {mon_read_size_j, mon_read_addrs_j} <= SHIFT_REG[49:15];
                                            mon_write_size_j  <= SHIFT_REG[49:47];
                                            mon_write_addrs_j <= {17'b0, SHIFT_REG[14:0]};
                                        end    
                mon_write_addrs_addrs : begin
                                            {mon_write_size_j, mon_write_addrs_j} <= SHIFT_REG[34:0];
                                            mon_read_size_j <= SHIFT_REG[34:32]; 
                                            mon_read_addrs_j <= {17'b0, SHIFT_REG[49:35]};
                                        end    
                mon_write_reg_addrs   : mon_write_reg_j   <= SHIFT_REG[63:0];  //data to be written
                evnt_cntr_addrs       : evnt_cntr_j <= SHIFT_REG[31:0];
                trigger_A_addrs       : trigger_A_j <= SHIFT_REG[`PCWIDTH-1:0];
                trigger_B_addrs       : trigger_B_j <= SHIFT_REG[`PCWIDTH-1:0];
                brk_cntrl_addrs       : {DEBUG_SEL,
                                         PC_EQ_BRKA_en_j, 
                                         PC_EQ_BRKB_en_j, 
                                         PC_GT_BRKA_en_j, 
                                         PC_LT_BRKB_en_j, 
                                         PC_AND_en_j,
                                         mon_req_j,
                                         sstep_j, 
                                         frc_brk_j, 
                                         FORCE_RESET_j} <= SHIFT_REG[9:0];
                              default :  SHIFT_REG <= SHIFT_REG;        

            endcase
        end
        else if (event_det && (evnt_cntr_j > 32'h0000_0001) && DEBUG_SEL) evnt_cntr_j <= evnt_cntr_j - 1'b1;
    end
end

HUJTAG hujtag(
                
                .TDI(HTDI),
                .TDO(HTDO),
                .TMS(HTMS),
                .TCK(HTCK),
                .TRSTB(HTRSTn),
                
                .UTDI(UTDI_),               // output
                .UTDO  (SHIFT_REG[0]),      // input
                .UDRCAP(UDRCAP_  ),
                .UDRCK (UDRCK_   ),
                .UDRSH (UDRSH_   ),
                .UDRUPD(UDRUPD_  ),
                .URSTB (URSTB_   ),
                .UIREG0(UIREG_[0]),
                .UIREG1(UIREG_[1]),
                .UIREG2(UIREG_[2]),
                .UIREG3(UIREG_[3]),
                .UIREG4(UIREG_[4]),
                .UIREG5(UIREG_[5]),
                .UIREG6(UIREG_[6]),
                .UIREG7(UIREG_[7]));
`else
assign HTDO  = 0;
wire URSTB_;
assign USTRB_ = 1'b1;
wire   URST_;
assign URST_  = ~URSTB_;

`endif              

assign        RESET_OUT = RESET_IN || FORCE_RESET;

endmodule
