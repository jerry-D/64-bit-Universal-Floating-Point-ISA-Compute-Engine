 // int_cntrl.v
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

module int_cntrl(
    CLK,
    RESET,
    PC,
    q2_sel,
    OPsrcA_q2,
    OPdest_q2,
    Ind_Dest_q2,
    Ind_SrcA_q2,
    SigD_q2,
    RPT_not_z,
    NMI,
    inexact_exc,  
    underflow_exc,
    overflow_exc, 
    divby0_exc,   
    invalid_exc,  
    IRQ,
    IRQ_IE,
    vector,
    ld_vector,
    NMI_ack,
    EXC_ack,
    IRQ_ack,
    EXC_in_service,
    invalid_in_service,
    divby0_in_service, 
    overflow_in_service, 
    underflow_in_service,
    inexact_in_service,
    wrcycl,
    int_in_service,
    NMI_VECTOR,
    IRQ_VECTOR,
    invalid_VECTOR,
    divby0_VECTOR,
    overflow_VECTOR,
    underflow_VECTOR,
    inexact_VECTOR
    );
    
input CLK; 
input RESET;
input NMI; 
input inexact_exc;  
input underflow_exc;
input overflow_exc; 
input divby0_exc;   
input invalid_exc;  
input IRQ; 
input IRQ_IE;
input [`PCWIDTH-1:0] PC;
input q2_sel; 
input RPT_not_z;         
input [14:0] OPsrcA_q2;
input [14:0] OPdest_q2;
input Ind_Dest_q2;
input Ind_SrcA_q2;
input SigD_q2;
output [`PCWIDTH-1:0] vector;
output ld_vector;
output NMI_ack;
output EXC_ack;
output IRQ_ack;
output EXC_in_service;
output invalid_in_service;
output divby0_in_service; 
output overflow_in_service; 
output underflow_in_service;
output inexact_in_service;
output int_in_service;
input wrcycl;
input [`PCWIDTH-1:0] NMI_VECTOR;
input [`PCWIDTH-1:0] IRQ_VECTOR;
input [`PCWIDTH-1:0] invalid_VECTOR;
input [`PCWIDTH-1:0] divby0_VECTOR;
input [`PCWIDTH-1:0] overflow_VECTOR;
input [`PCWIDTH-1:0] underflow_VECTOR;
input [`PCWIDTH-1:0] inexact_VECTOR;

parameter     BRAL_ =  15'h7FF6;   // branch relative long
parameter     JMPA_ =  15'h7FF5;   // jump absolute long
parameter     BTBS_ =  15'h7FF4;   // bit test and branch if set
parameter     BTBC_ =  15'h7FF3;   // bit test and branch if clear

parameter               BRAL_ADDRS = 32'h00007FF6;   // branch relative long
parameter               JMPA_ADDRS = 32'h00007FF5;   // jump absolute long
parameter               BTBS_ADDRS = 32'h00007FF4;   // bit test and branch if set
parameter               BTBC_ADDRS = 32'h00007FF3;   // bit test and branch if clear

parameter           GLOB_RAM_ADDRS = 32'b0000_0000_0000_0001_0xxx_xxxx_xxxx_xxxx; //globabl RAM address (in bytes)
parameter             SP_TOS_ADDRS = 32'h00007FFF;
parameter                 SP_ADDRS = 32'h00007FFE;
parameter                AR6_ADDRS = 32'h00007FFD;
parameter                AR5_ADDRS = 32'h00007FFC;
parameter                AR4_ADDRS = 32'h00007FFB;
parameter                AR3_ADDRS = 32'h00007FFA;
parameter                AR2_ADDRS = 32'h00007FF9;
parameter                AR1_ADDRS = 32'h00007FF8;
parameter                AR0_ADDRS = 32'h00007FF7;
parameter                 PC_ADDRS = 32'h00007FF5;
parameter            PC_COPY_ADDRS = 32'h00007FF2;
parameter                 ST_ADDRS = 32'h00007FF1;
parameter             REPEAT_ADDRS = 32'h00007FEF;
parameter             LPCNT1_ADDRS = 32'h00007FEE;
parameter             LPCNT0_ADDRS = 32'h00007FED;
parameter              TIMER_ADDRS = 32'h00007FEC;
parameter                MON_ADDRS = 32'h00007FEB;

parameter         SPARE_VEC1_ADDRS = 15'h7FE8;
parameter         SPARE_VEC0_ADDRS = 15'h7FE7;
parameter         NMI_VECTOR_ADDRS = 15'h7FE6;
parameter         IRQ_VECTOR_ADDRS = 15'h7FE5;
parameter     invalid_VECTOR_ADDRS = 15'h7FE4;
parameter      divby0_VECTOR_ADDRS = 15'h7FE3;
parameter    overflow_VECTOR_ADDRS = 15'h7FE2;
parameter   underflow_VECTOR_ADDRS = 15'h7FE1;
parameter     inexact_VECTOR_ADDRS = 15'h7FE0;

parameter      XCU_CNTRL_REG_ADDRS = 15'h7FDF;
parameter     XCU_STATUS_REG_ADDRS = 15'h7FDE;

parameter              CAPT3_ADDRS = 32'h00007FDD;
parameter              CAPT2_ADDRS = 32'h00007FDC;
parameter              CAPT1_ADDRS = 32'h00007FDB;
parameter              CAPT0_ADDRS = 32'h00007FDA;

parameter           SAVFLAGS_ADDRS = 32'h00007FD9; //store status register here to save flags, read here to get them
parameter             RNDDIR_ADDRS = 32'h00007FD8;
parameter           SAVMODES_ADDRS = 32'h00007FD7; //store status register here to save modes, read here to get them            
parameter              CLASS_ADDRS = 32'h00007FD6;
parameter              RADIX_ADDRS = 32'h00007FD5;

parameter        XCU_PREEMPT_ADDRS = 15'h7FD4;
parameter          XCU_SSTEP_ADDRS = 15'h7FD3;
parameter    XCU_FORCE_BREAK_ADDRS = 15'h7FD2;
parameter    XCU_FORCE_RESET_ADDRS = 15'h7FD1;
parameter             is2008_ADDRS = 15'h7FD0;
parameter        INTEGER_CMP_ADDRS = 15'h7FCF;     
parameter   XCU_MON_POKE_ALL_ADDRS = 15'h7FC0;  //one address for poking all XCUs simultaneously
parameter    XCU_MON_REQUEST_ADDRS = 15'h7FBx;  //unique address for each target XCU

parameter     FLOAT_ADDRS = 32'b0000_0000_0000_0000_0111_10xx_xxxx_xxxx;  //floating-point operator block 78xx--7Bxx
parameter    INTEGR_ADDRS = 32'b0000_0000_0000_0000_0111_1110_xxxx_xxxx;  // integer and logic operator block  7Exx
parameter  PRIV_RAM_ADDRS = 32'b0000_0000_0000_0000_0xxx_xxxx_xxxx_xxxx;    //first 32k bytes (since data memory is byte-addressable and smallest RAM for this in Kintex 7 is 2k x 64 bits using two blocks next to each other

parameter             is1985_ADDRS = 32'h00000000;  //read this to get 0 (false)

reg [`PCWIDTH-1:0] vector;
reg ld_vector;

reg NMI_ackq;
reg NMI_in_service;

reg EXC_ackq;
reg EXC_in_service;

reg IRQ_ackq;
reg IRQ_in_service;
 
reg [2:0] int_state;

reg [4:0] RESET_STATE;

reg NMIq;
reg IRQq;
          
wire NMIg;
wire NMI_ack;
wire NMI_RETI;
wire saving_NMI_PC_COPY;

wire EXCg;
wire EXC_ack;
wire EXC_RETI;
wire saving_EXC_PC_COPY;
wire [4:0] EXC_sel;

wire IRQg;
wire IRQ_ack;
wire IRQ_RETI;
wire saving_IRQ_PC_COPY;

wire invalid_RETI; 
wire divby0_RETI;  
wire overflow_RETI; 
wire underflow_RETI;
wire inexact_RETI; 

reg invalid_in_service;
reg divby0_in_service;
reg overflow_in_service;
reg underflow_in_service;
reg inexact_in_service;

wire int_in_service;

wire POP_PC_SigD;
wire PUSH_PC_SigD;

assign POP_PC_SigD  = (OPsrcA_q2[2:0]==3'b111) && (OPdest_q2==PC_ADDRS[14:0]) && Ind_SrcA_q2 && SigD_q2 && q2_sel && wrcycl;
assign PUSH_PC_SigD = (OPdest_q2[2:0]==3'b111) && (OPsrcA_q2==PC_COPY_ADDRS[14:0]) && SigD_q2 && Ind_Dest_q2 && q2_sel && wrcycl;

assign int_in_service = NMI_in_service || IRQ_in_service || EXC_in_service;
assign EXC_sel = {invalid_exc, divby0_exc, overflow_exc, underflow_exc, inexact_exc};  

assign NMI_ack = NMI_ackq && (PC==NMI_VECTOR);
assign EXC_ack = EXC_ackq && ((PC==invalid_VECTOR) || (PC==divby0_VECTOR) || (PC==overflow_VECTOR) || (PC==underflow_VECTOR) || (PC==inexact_VECTOR));
assign IRQ_ack = IRQ_ackq && (PC==IRQ_VECTOR);

assign invalid_RETI   = invalid_in_service   && POP_PC_SigD && ~IRQ_in_service && ~NMI_in_service;
assign divby0_RETI    = divby0_in_service    && POP_PC_SigD && ~IRQ_in_service && ~NMI_in_service;
assign overflow_RETI  = overflow_in_service  && POP_PC_SigD && ~IRQ_in_service && ~NMI_in_service;
assign underflow_RETI = underflow_in_service && POP_PC_SigD && ~IRQ_in_service && ~NMI_in_service;
assign inexact_RETI   = inexact_in_service   && POP_PC_SigD && ~IRQ_in_service && ~NMI_in_service;
assign NMI_RETI       = NMI_in_service       && POP_PC_SigD;     //POP stack into PC
assign IRQ_RETI       = IRQ_in_service       && POP_PC_SigD && ~NMI_in_service;
assign EXC_RETI       = invalid_RETI || divby0_RETI || overflow_RETI || underflow_RETI || inexact_RETI;

assign saving_NMI_PC_COPY = NMI_in_service && PUSH_PC_SigD;  // PUSH PC_COPY onto stack
assign saving_EXC_PC_COPY = EXC_in_service && PUSH_PC_SigD;
assign saving_IRQ_PC_COPY = IRQ_in_service && PUSH_PC_SigD;

assign NMIg = NMIq;                                                                                                                                              
assign IRQg = IRQq;                                                                                                                                               
assign EXCg = (inexact_exc || underflow_exc || overflow_exc || divby0_exc || invalid_exc) && ~EXC_ack && ~EXC_in_service;            
        
// interrupt prioritizer with corresponding IACK and IN_SERVICE generator
// this particular version does not accomodate nested interrupts--if an interrupt or exception is being processed, 
// the pending request must wait until the current one is completed

always @(posedge CLK or posedge RESET) 
 if (RESET) NMIq <= 1'b0;
 else if (NMI_ackq && (vector==NMI_VECTOR)) NMIq <= 1'b0;
 else NMIq <=  NMI && ~NMI_in_service;

always @(posedge CLK or posedge RESET) 
 if (RESET) IRQq <= 1'b0;
 else if (IRQ_ackq && (vector==IRQ_VECTOR)) IRQq <= 1'b0;
 else  IRQq <= ( IRQ && IRQ_IE && ~IRQ_in_service);

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        vector <= 0;
        ld_vector <= 1'b0;
        int_state <= 3'b000;
        
        NMI_ackq <= 1'b0;                                                                                           
        NMI_in_service <= 1'b0;                                                                                     
                                                                                                                    
        EXC_ackq <= 1'b0;                                                                                           
        EXC_in_service <= 1'b0;                                                                                     
                                                                                                                    
        IRQ_ackq <= 1'b0;                                                                                           
        IRQ_in_service <= 1'b0;  
        
        invalid_in_service   <= 1'b0;
        divby0_in_service    <= 1'b0;
        overflow_in_service  <= 1'b0;
        underflow_in_service <= 1'b0;
        inexact_in_service   <= 1'b0;                                                                                 
        
        RESET_STATE <= 5'b10000;
    end
//NMI    
    else begin
        RESET_STATE <= {1'b1, RESET_STATE[4:1]};    //rotate right 1 into msb  (shift right)
       if (&RESET_STATE) //block all interrupts until reset vector fetched and entered
            case(int_state)
                3'b000 : if (NMIg) begin
                            NMI_ackq <= 1'b1;
                            ld_vector <= 1'b1;
                            vector <= NMI_VECTOR;
                            int_state <= 3'b001;
                         end
                         else if (IRQg) begin
                            IRQ_ackq <= 1'b1;
                            ld_vector <= 1'b1;
                            vector <= IRQ_VECTOR;
                            int_state <= 3'b001;
                         end                                
                         else if (EXCg) begin
                            EXC_ackq <= 1'b1;
                            ld_vector <= 1'b1;
                            casex (EXC_sel)
                                5'b1xxxx : vector <= invalid_VECTOR;
                                5'b01xxx : vector <= divby0_VECTOR;
                                5'b001xx : vector <= overflow_VECTOR;
                                5'b0001x : vector <= underflow_VECTOR;
                                5'b00001 : vector <= inexact_VECTOR;
                                default  : vector <= invalid_VECTOR;
                            endcase    
                            int_state <= 3'b001;
                         end
                3'b001 : begin                                                                                         
                            ld_vector <= 1'b0;                                                                         
                            if (NMI_ackq) begin
                              NMI_ackq <= 1'b0;
                              NMI_in_service <= 1'b1;
                              int_state <= 3'b010;                
                            end
                            else if (IRQ_ackq) begin     
                                IRQ_ackq <= 1'b0;        
                                IRQ_in_service <= 1'b1;  
                                int_state <= 3'b010;           
                            end                          
                            else if (EXC_ackq) begin          
                                EXC_ackq <= 1'b0;        
                                EXC_in_service <= 1'b1; 
                                invalid_in_service   <= (vector==invalid_VECTOR  );
                                divby0_in_service    <= (vector==divby0_VECTOR   );
                                overflow_in_service  <= (vector==overflow_VECTOR );
                                underflow_in_service <= (vector==underflow_VECTOR);
                                inexact_in_service   <= (vector==inexact_VECTOR  );
                                int_state <= 3'b010;           
                            end                          
                         end
                3'b010 : begin
                            if (NMI_in_service && saving_NMI_PC_COPY) begin
                                int_state <= 3'b011;
                            end
                            else if (IRQ_in_service && saving_IRQ_PC_COPY) begin
                                int_state <= 3'b011;
                            end
                            else if (EXC_in_service && saving_EXC_PC_COPY) begin
                                int_state <= 3'b011;
                            end
                         end   
                3'b011 : begin
                            if (NMI_RETI) begin
                                NMI_in_service <= 1'b0;
                                int_state <= 3'b100;
                            end
                            else if (IRQ_RETI) begin
                                IRQ_in_service <= 1'b0;
                                int_state <= 3'b100;
                            end
                            else if (EXC_RETI) begin
                                EXC_in_service       <= 1'b0;
                                invalid_in_service   <= 1'b0;
                                divby0_in_service    <= 1'b0;
                                overflow_in_service  <= 1'b0;
                                underflow_in_service <= 1'b0;
                                inexact_in_service   <= 1'b0;
                                int_state <= 3'b100;
                            end
                         end
                3'b100 : int_state <= 3'b000;   //allow one fetch before allowing another interrupt
               default : int_state <= 3'b000;
             endcase        
    end                
end                     
                        
endmodule        
               
                