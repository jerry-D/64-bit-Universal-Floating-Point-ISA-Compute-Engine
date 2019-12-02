// core.v
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

module core (
    CLK,           
    RESET,  
    q1_sel,
    q2_sel,
    wrsrcAdata,
    wrsrcBdata,
    rdSrcAdata,    
    rdSrcBdata,
    priv_RAM_rddataA,                      
    priv_RAM_rddataB,                      
    glob_RAM_rddataA,                      
    glob_RAM_rddataB,                      
    pre_PC,       
    PC,            
    pc_q1,
    pc_q2,
    ld_vector,
    vector,     
    rewind_PC,
    wrcycl,        
    discont_out,    
    OPsrcA_q0,
    OPsrcA_q1,        
    OPsrcA_q2,
    OPsrcB_q0,
    OPsrcB_q1,        
    OPsrcB_q2,     
    OPdest_q0,      
    OPdest_q1,      
    OPdest_q2, 
    immediate16_q0,
    RPT_not_z, 
    Dam_q0, 
    Dam_q1,        
    Dam_q2,      
    Ind_Dest_q2, 
    Ind_Dest_q1, 
    Ind_SrcA_q0,
    Ind_SrcA_q2,    
    Ind_SrcB_q0, 
    Imod_Dest_q0,   
    Imod_Dest_q2,
    Imod_SrcA_q0,   
    Imod_SrcB_q0,
    Ind_SrcB_q2,
    Size_SrcA_q1,
    Size_SrcB_q1,    
    Size_SrcA_q2,
    Size_SrcB_q2,
    Size_Dest_q2,
    SigA_q1,
    SigA_q2,   
    SigB_q2,
    SigD_q2,    
    OPsrc32_q0, 
    Ind_Dest_q0,
    Dest_addrs_q2,
    Dest_addrs_q0,
    SrcA_addrs_q0,
    SrcB_addrs_q0,
    SrcA_addrs_q1,
    SrcB_addrs_q1,
    V_q2,          
    N_q2,          
    C_q2,          
    Z_q2,          
    V,          
    N,          
    C,          
    Z,          
    IRQ,           
    done,          
    IRQ_IE,
    break_q0,
    rddataA_integer,             
    rddataB_integer,
    mon_write_reg, // data to be written by monitor R/W instruction
    mon_read_reg, //data captured by monitor R/W instruction
    ind_mon_read_q0, 
    ind_mon_write_q2,                            
    exc_codeA, 
    exc_codeB,
    float_rddataA, 
    float_rddataB,
    RM_q1,
    fp_ready_q1,
    fp_ready_q2,
    writeAbort,
    RM_Attribute_on,
    Away,           
    RM_Attribute,        
    int_in_service,
    statusRWcollision,
    write_disable,
    
    XCU_CNTRL_REG,
    XCU_STATUS_REG,
    XCU_monitorREADreq, 
    XCU_monitorWRITEreq,
    XCU_monitorWRITE_ALL_req,
    ACTM,
    PRNG_ready,
    ready_q0
    );

input  CLK;           
input  RESET; 
input  q1_sel;
input  q2_sel; 
input  [63:0] wrsrcAdata;      
input  [63:0] wrsrcBdata;      
output  ld_vector; 
output [`PCWIDTH-1:0] vector;    
input  rewind_PC;
input  wrcycl; 
output discont_out;

input  [14:0] OPsrcA_q0;
input  [14:0] OPsrcA_q1;        
input  [14:0] OPsrcA_q2;
input  [14:0] OPsrcB_q0;        
input  [14:0] OPsrcB_q1;        
input  [14:0] OPsrcB_q2;     
input  [14:0] OPdest_q0;      
input  [14:0] OPdest_q1;      
input  [14:0] OPdest_q2;
input  [15:0] immediate16_q0;
   
output RPT_not_z; 
output  [`PCWIDTH-1:0] pre_PC;       
input  [1:0]  Dam_q0;
input  [1:0]  Dam_q1;         
input  [1:0]  Dam_q2;      
input  Ind_Dest_q2; 
input  Ind_Dest_q1; 
input  Ind_SrcA_q0;    
input  Ind_SrcA_q2;
input  Ind_SrcB_q0; 
input  Imod_Dest_q0;   
input  Imod_Dest_q2;
input  Imod_SrcA_q0;   
input  Imod_SrcB_q0; 
input  Ind_SrcB_q2;
input [1:0] Size_SrcA_q1;
input [1:0] Size_SrcB_q1;
input [1:0] Size_SrcA_q2;
input [2:0] Size_SrcB_q2;
input [1:0] Size_Dest_q2;
input  SigA_q1;
input  SigA_q2;
input  SigB_q2;
input  SigD_q2;
input  [31:0] OPsrc32_q0; 
input  Ind_Dest_q0;   
output [31:0] Dest_addrs_q2; 
output [31:0] Dest_addrs_q0;       
output [31:0] SrcA_addrs_q0;        
output [31:0] SrcB_addrs_q0; 
input  [31:0] SrcA_addrs_q1;
input  [31:0] SrcB_addrs_q1;
output [`PCWIDTH-1:0] PC;                                                                                                         
input  V_q2;                                                            
input  N_q2;                                                            
input  C_q2;          
input  Z_q2;
output V;
output N;
output C;
output Z;
input  IRQ;                                                                 
output done;                                                           
output IRQ_IE;          
output [63:0] rdSrcAdata;
output [63:0] rdSrcBdata;
input  [63:0] priv_RAM_rddataA;
input  [63:0] priv_RAM_rddataB;
input  [63:0] glob_RAM_rddataA;
input  [63:0] glob_RAM_rddataB;
input  break_q0;  
input  [63:0] rddataA_integer;                   
input  [63:0] rddataB_integer;
input  [63:0] mon_write_reg;         //from monitor/break/debug block 
output [63:0] mon_read_reg;
input  ind_mon_read_q0; 
input  ind_mon_write_q2;                            
input  [4:0] exc_codeA;
input  [4:0] exc_codeB;
input [63:0] float_rddataA;
input [63:0] float_rddataB;
input [1:0] RM_q1; 
input [`PCWIDTH-1:0] pc_q1;
input [`PCWIDTH-1:0] pc_q2;
input fp_ready_q1;
input fp_ready_q2;
output writeAbort;     //from FP exception capture block
output RM_Attribute_on;
output Away;           
output [1:0] RM_Attribute;        
output int_in_service;
output statusRWcollision;
output write_disable; //from PC block
output XCU_CNTRL_REG;
input  XCU_STATUS_REG;
output XCU_monitorREADreq; 
output XCU_monitorWRITEreq;
output XCU_monitorWRITE_ALL_req;
output [3:0] ACTM;
output PRNG_ready;
input ready_q0;
       
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
parameter               PRNG_ADDRS = 32'h00007FF0;
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
parameter            actMode_ADDRS = 15'h7FCD;

parameter   XCU_MON_POKE_ALL_ADDRS = 15'h7FC0;  //one address for poking all XCUs simultaneously
parameter    XCU_MON_REQUEST_ADDRS = 15'h7FBx;  //unique address for each target XCU

parameter     FLOAT_ADDRS = 32'b0000_0000_0000_0000_0111_10xx_xxxx_xxxx;  //floating-point operator block 78xx--7Bxx
parameter    INTEGR_ADDRS = 32'b0000_0000_0000_0000_0111_1110_xxxx_xxxx;  // integer and logic operator block  7Exx
parameter  PRIV_RAM_ADDRS = 32'b0000_0000_0000_0000_0xxx_xxxx_xxxx_xxxx;    //first 32k bytes (since data memory is byte-addressable and smallest RAM for this in Kintex 7 is 2k x 64 bits using two blocks next to each other

parameter             is1985_ADDRS = 32'h00000000;  //read this to get 0 (false)

reg  [`PCWIDTH-1:0] pre_PC; 

reg [63:0] rdSrcAdata;
reg [63:0] rdSrcBdata;

reg [31:0] timer;
reg [31:0] timercmpr;

reg [`LPCNTRSIZE-1:0] LPCNT1;
reg [`LPCNTRSIZE-1:0] LPCNT0;

reg [3:0] sModes;
reg [2:0] roundDirection;
reg [4:0] flags;

reg [`PCWIDTH-1:0] NMI_VECTOR;      
reg [`PCWIDTH-1:0] IRQ_VECTOR;      
reg [`PCWIDTH-1:0] invalid_VECTOR;  
reg [`PCWIDTH-1:0] divby0_VECTOR;   
reg [`PCWIDTH-1:0] overflow_VECTOR; 
reg [`PCWIDTH-1:0] underflow_VECTOR;
reg [`PCWIDTH-1:0] inexact_VECTOR; 

reg [63:0] XCU_CNTRL_REG; 


reg [63:0] mon_read_reg;    //write-only and not qualified with wrcycl


wire [63:0] XCU_STATUS_REG;
wire XCU_monitorREADreq;
wire XCU_monitorWRITEreq;

assign XCU_monitorREADreq  = (SrcA_addrs_q0[14:4]==XCU_MON_REQUEST_ADDRS[14:4]) && ~|SrcA_addrs_q0[31:15];
assign XCU_monitorWRITEreq = (Dest_addrs_q0[14:4]==XCU_MON_REQUEST_ADDRS[14:4] )&& ~|Dest_addrs_q0[31:15];
assign XCU_monitorWRITE_ALL_req = (OPdest_q0[14:0]==XCU_MON_POKE_ALL_ADDRS[14:0]) && ~Ind_Dest_q0;

wire write_disable;

wire statusRWcollision;

wire [`LPCNTRSIZE-1:0] LPCNT1_dec;
wire [`LPCNTRSIZE-1:0] LPCNT0_dec;

wire LPCNT1_nz; 
wire LPCNT0_nz;

wire [`RPTSIZE-1:0] REPEAT; 

wire [63:0] capt_dataA;
wire [63:0] capt_dataB;
wire RPT_not_z;
wire discont_out;

wire [`PCWIDTH-1:0] PC;    
wire [`PCWIDTH-1:0] PC_COPY;
wire        done;  
wire        IRQ_IE;  
wire [63:0] STATUS;
wire [`PCWIDTH-1:0] vector;    

wire [31:0] SP;
wire [31:0] AR6;
wire [31:0] AR5;
wire [31:0] AR4;
wire [31:0] AR3;
wire [31:0] AR2;
wire [31:0] AR1;
wire [31:0] AR0;

wire [31:0] Dest_addrs_q0;


wire NMI_ack;
wire EXC_ack;
wire IRQ_ack;
wire EXC_in_service;   
wire invalid_in_service;   
wire divby0_in_service;   
wire overflow_in_service;   
wire underflow_in_service;   
wire inexact_in_service;  

wire TrapInvalid_q1;
wire TrapDivX0_q1;
wire TrapOverflow_q1;
wire TrapUnderflow_q1;
wire TrapInexact_q1;

wire V;
wire N;
wire C;
wire Z;

wire [3:0] ACTM;

wire [3:0] class;

wire [63:0] rddataA_integer;             
wire [63:0] rddataB_integer; 

wire writeAbort;

wire RM_Attribute_on;
wire Away;           
wire [1:0] RM_Attribute;

wire enAltImmInexactHandl  ;
wire enAltImmUnderflowHandl;
wire enAltImmOverflowHandl ;
wire enAltImmDivByZeroHandl;
wire enAltImmInvalidHandl  ; 

wire rd_float_q1_selA; 
wire rd_float_q1_selB; 
wire rd_integr_q1_selA;
wire rd_integr_q1_selB;

wire rdStatus_q1;
assign rdStatus_q1 = (OPsrcA_q1==ST_ADDRS[14:0]) || (OPsrcB_q1==ST_ADDRS[14:0]);

assign rd_float_q1_selA  = (SrcA_addrs_q1[31:12]==20'h0000E) && ~((Dam_q1[1:0]==2'b10) || ((Dam_q1[1:0]==2'b11) && (Size_SrcA_q1[1:0]==2'b11))); //don't enable if table-read or 32-bit immediate
assign rd_float_q1_selB  = (SrcA_addrs_q1[31:12]==20'h0000E) &&  ~(Dam_q1[1:0]==2'bx1); //don't enable if any kind of immediate
assign rd_integr_q1_selA = (SrcA_addrs_q1[31:12]==20'h0000D) && ~((Dam_q1[1:0]==2'b10) || ((Dam_q1[1:0]==2'b11) && (Size_SrcA_q1[1:0]==2'b11))); //don't enable if table-read or 32-bit immediate
assign rd_integr_q1_selB = (SrcA_addrs_q1[31:12]==20'h0000D) &&  ~(Dam_q1[1:0]==2'bx1); //don't enable if any kind of immediate

assign RM_Attribute_on = STATUS[63];
assign Away = STATUS[62];
assign RM_Attribute = STATUS[61:60];
 
assign LPCNT1_dec = LPCNT1 - 1'b1;
assign LPCNT0_dec = LPCNT0 - 1'b1;

assign LPCNT1_nz = |LPCNT1_dec;
assign LPCNT0_nz = |LPCNT0_dec;


wire [63:0] PRNG_rddataA;
wire PRNG_ready;
wire PRNG_rden;
assign PRNG_rden = (OPsrcA_q0[14:0]==PRNG_ADDRS[14:0]);
`ifdef SOB_HAS_PRNG
PRNG_H7 PRNG(
    .CLK(CLK),
    .RESET(RESET),
    .rden(PRNG_rden),
    .wren((Dest_addrs_q2==PRNG_ADDRS) && wrcycl),
    .wrdata(wrsrcAdata[7:0]),
    .rddata(PRNG_rddataA[63:0]),
    .SigA(SigA_q1),
    .SizeA(Size_SrcA_q1[1:0]),
    .ready(PRNG_ready)
    );
`else
assign PRNG_ready = 1'b1;
assign PRNG_rddataA = 0;
`endif

`ifdef CPU_HAS_EXC_CAPTURE
    exc_capture  exc_capt(     // quasi-trace buffer for capturing floating-point exceptions
        .CLK            (CLK        ),
        .RESET          (done   ),
        .srcA_q1        (SrcA_addrs_q1[31:0]    ),
        .srcB_q1        (SrcB_addrs_q1[31:0]    ),
        .Size_SrcA_q1   (Size_SrcA_q1 ),
        .Size_SrcB_q1   (Size_SrcB_q1 ),
        .dest_q2        (Dest_addrs_q2[31:0] ),
        .pc_q1          (pc_q1      ),
        .rdSrcAdata     (float_rddataA[63:0]),
        .rdSrcBdata     (float_rddataB[63:0]),
        .exc_codeA      (exc_codeA  ),
        .exc_codeB      (exc_codeB  ),
        .rdenA          (~Dam_q0[1] && (SrcA_addrs_q0[31:5]==CAPT3_ADDRS[31:5])),
        .rdenB          (~Dam_q0[0] && (SrcB_addrs_q0[31:5]==CAPT3_ADDRS[31:5])),
        .fp_ready_q1    (fp_ready_q1     ),
        .enAltImmInexactHandl  (enAltImmInexactHandl  ),
        .enAltImmUnderflowHandl(enAltImmUnderflowHandl),
        .enAltImmOverflowHandl (enAltImmOverflowHandl ),
        .enAltImmDivByZeroHandl(enAltImmDivByZeroHandl),
        .enAltImmInvalidHandl  (enAltImmInvalidHandl  ),
        .invalid_in_service  (invalid_in_service  ),
        .divby0_in_service   (divby0_in_service   ),
        .overflow_in_service (overflow_in_service ),
        .underflow_in_service(underflow_in_service),
        .inexact_in_service  (inexact_in_service  ),
        .TrapInexact_q1    (TrapInexact_q1   ),
        .TrapUnderflow_q1  (TrapUnderflow_q1 ),
        .TrapOverflow_q1   (TrapOverflow_q1  ),
        .TrapDivX0_q1      (TrapDivX0_q1     ),
        .TrapInvalid_q1    (TrapInvalid_q1   ),
        .capt_dataA     (capt_dataA      ),
        .capt_dataB     (capt_dataB      ),
        .writeAbort     (writeAbort      )
        );   
`else 
    assign TrapInexact_q1   = 1'b0;
    assign TrapUnderflow_q1 = 1'b0;
    assign TrapOverflow_q1  = 1'b0;
    assign TrapDivX0_q1     = 1'b0;
    assign TrapInvalid_q1   = 1'b0;
    assign capt_dataA       = 64'b0;
    assign capt_dataB       = 64'b0;
    assign writeAbort       = 1'b0;
`endif

PROG_ADDRS 
  prog_addrs (
    .CLK           (CLK         ),
    .RESET         (RESET       ),
    .q2_sel        (q2_sel      ),
    .Ind_Dest_q0   (Ind_Dest_q0 ),
    .Ind_Dest_q2   (Ind_Dest_q2 ),
    .Ind_SrcB_q2   (Ind_SrcB_q2 ),
    .Size_SrcB_q2  (Size_SrcB_q2),
    .SigB_q2       (SigB_q2),
    .OPdest_q0     (OPdest_q0   ),
    .OPdest_q2     (OPdest_q2   ),
    .wrsrcAdata    (wrsrcAdata  ),
    .ld_vector     (ld_vector   ),
    .vector        (vector      ),
    .rewind_PC     (rewind_PC   ),
    .wrcycl        (wrcycl      ),
    .discont_out   (discont_out ),
    .OPsrcB_q2     (OPsrcB_q2   ),
    .RPT_not_z     (RPT_not_z   ),
    .pre_PC        (pre_PC      ),
    .PC            (PC          ),
    .PC_COPY       (PC_COPY     ),
    .pc_q1         (pc_q1       ),
    .pc_q2         (pc_q2       ),
    .break_q0      (break_q0    ),
    .write_disable (write_disable)
    );

DATA_ADDRS data_addrs(
    .CLK           (CLK             ),          
    .RESET         (RESET           ),          
    .q2_sel        (q2_sel          ),          
    .wrcycl        (wrcycl          ),          
    .wrsrcAdata    (wrsrcAdata[31:0]),
    .Dam_q0        (Dam_q0[1:0]     ),          
    .Ind_Dest_q0   (Ind_Dest_q0     ),          
    .Ind_SrcA_q0   (Ind_SrcA_q0     ),                                                  
    .Ind_SrcB_q0   (Ind_SrcB_q0     ),                                                  
    .Imod_Dest_q2  (Imod_Dest_q2    ),                                                  
    .Imod_SrcA_q0  (Imod_SrcA_q0    ),                                                   
    .Imod_SrcB_q0  (Imod_SrcB_q0    ),                                                   
    .OPdest_q0     (OPdest_q0       ),                                                   
    .OPdest_q2     (OPdest_q2       ),          
    .OPsrcA_q0     (OPsrcA_q0       ),          
    .OPsrcB_q0     (OPsrcB_q0       ),          
    .OPsrc32_q0    (OPsrc32_q0      ), 
    .Ind_Dest_q2   (Ind_Dest_q2     ),        
    .Dest_addrs_q2 (Dest_addrs_q2   ), 
    .Dest_addrs_q0 (Dest_addrs_q0   ),         
    .SrcA_addrs_q0 (SrcA_addrs_q0   ),          
    .SrcB_addrs_q0 (SrcB_addrs_q0   ),           
    . AR0          ( AR0            ),
    . AR1          ( AR1            ),
    . AR2          ( AR2            ),
    . AR3          ( AR3            ),
    . AR4          ( AR4            ),
    . AR5          ( AR5            ),
    . AR6          ( AR6            ),
    . SP           ( SP             ),
    .discont       (discont_out     ),
    .ind_mon_read_q0 (ind_mon_read_q0 ),
    .ind_mon_write_q2(ind_mon_write_q2),
    .ready_q0      (ready_q0        )
    );                            

                                  
STATUS_REG status(
     .CLK              (CLK              ),
     .RESET            (RESET            ),
     .wrcycl           (wrcycl           ),
     .q2_sel           (q2_sel           ),
     .OPdest_q2        (OPdest_q2        ),
     .rdStatus_q1      (rdStatus_q1      ),
     .statusRWcollision(statusRWcollision),
     .Ind_Dest_q2      (Ind_Dest_q2      ),
     .SigA_q2          (SigA_q2     ),
     .SigB_q2          (SigB_q2     ),     
     .Size_SrcA_q2     (Size_SrcA_q2     ),
     .Size_SrcB_q2     (Size_SrcB_q2[1:0]),
     .Size_Dest_q2     (Size_Dest_q2     ),
     .wrsrcAdata       (wrsrcAdata       ),
     .wrsrcBdata       (wrsrcBdata       ),
     .V_q2             (V_q2             ),
     .N_q2             (N_q2             ),            
     .C_q2             (C_q2             ),
     .Z_q2             (Z_q2             ),
     .V                (V                ),
     .N                (N                ),
     .C                (C                ),
     .Z                (Z                ),
     .IRQ              (IRQ              ),
     .done             (done             ),
     .enAltImmInexactHandl  (enAltImmInexactHandl  ),
     .enAltImmUnderflowHandl(enAltImmUnderflowHandl),
     .enAltImmOverflowHandl (enAltImmOverflowHandl ),
     .enAltImmDivByZeroHandl(enAltImmDivByZeroHandl),
     .enAltImmInvalidHandl  (enAltImmInvalidHandl  ),
     .IRQ_IE           (IRQ_IE           ),
     .STATUS           (STATUS           ),
     .class            (class            ),
     .exc_codeA        (exc_codeA        ),
     .exc_codeB        (exc_codeB        ),
     .rd_float_q1_selA (rd_float_q1_selA ),
     .rd_float_q1_selB (rd_float_q1_selB ),
     .rd_integr_q1_selA(rd_integr_q1_selA),
     .rd_integr_q1_selB(rd_integr_q1_selB),
     .ACTM             (ACTM             ),
     .fp_ready_q2      (fp_ready_q2      )
     );

    
int_cntrl int_cntrl(
    .CLK                  (CLK          ),
    .RESET                (RESET        ),
    .PC                   (PC           ),
    .q2_sel               (q2_sel       ),
    .OPsrcA_q2            (OPsrcA_q2    ),
    .OPdest_q2            (OPdest_q2    ),
    .Ind_Dest_q2          (Ind_Dest_q2  ),
    .Ind_SrcA_q2          (Ind_SrcA_q2  ),
    .SigD_q2              (SigD_q2 ),
    .RPT_not_z            (RPT_not_z),
    .NMI                  ((timer==timercmpr) && ~done),
    .inexact_exc          (TrapInexact_q1),
    .underflow_exc        (TrapUnderflow_q1 ),
    .overflow_exc         (TrapOverflow_q1 ),
    .divby0_exc           (TrapDivX0_q1 ),
    .invalid_exc          (TrapInvalid_q1  ),
    .IRQ                  (IRQ          ),
    .IRQ_IE               (IRQ_IE       ),
    .vector               (vector       ),
    .ld_vector            (ld_vector    ),
    .NMI_ack              (NMI_ack      ),
    .EXC_ack              (EXC_ack      ),
    .IRQ_ack              (IRQ_ack      ),
    .EXC_in_service       (EXC_in_service      ),
    .invalid_in_service   (invalid_in_service  ),
    .divby0_in_service    (divby0_in_service   ),
    .overflow_in_service  (overflow_in_service ),
    .underflow_in_service (underflow_in_service),
    .inexact_in_service   (inexact_in_service  ),
    .wrcycl               (wrcycl              ),
    .int_in_service       (int_in_service      ),
    .NMI_VECTOR           (NMI_VECTOR          ),
    .IRQ_VECTOR           (IRQ_VECTOR          ),
    .invalid_VECTOR       (invalid_VECTOR      ),
    .divby0_VECTOR        (divby0_VECTOR       ),
    .overflow_VECTOR      (overflow_VECTOR     ),
    .underflow_VECTOR     (underflow_VECTOR    ),
    .inexact_VECTOR       (inexact_VECTOR      )
    );   
    
REPEAT_reg repeat_reg(
    .CLK           (CLK          ),
    .RESET         (RESET        ),
    .Ind_Dest_q0   (Ind_Dest_q0  ),
    .Ind_SrcA_q0   (Ind_SrcA_q0  ),
    .Ind_SrcB_q0   (Ind_SrcB_q0  ),
    .Imod_Dest_q0  (Imod_Dest_q0 ),
    .Imod_SrcA_q0  (Imod_SrcA_q0 ),
    .Imod_SrcB_q0  (Imod_SrcB_q0 ),
    .OPdest_q0     (OPdest_q0    ),
    .OPsrcA_q0     (OPsrcA_q0    ),
    .immediate16_q0(immediate16_q0),
 //   .wrcycl        (wrcycl       ),
    .RPT_not_z     (RPT_not_z    ),
    .break_q0      (break_q0     ),
    .Dam_q0        (Dam_q0[1:0]  ),
    .AR0           (AR0[`RPTSIZE-1:0]),
    .AR1           (AR1[`RPTSIZE-1:0]),
    .AR2           (AR2[`RPTSIZE-1:0]),
    .AR3           (AR3[`RPTSIZE-1:0]),
    .AR4           (AR4[`RPTSIZE-1:0]),
    .AR5           (AR5[`RPTSIZE-1:0]),
    .AR6           (AR6[`RPTSIZE-1:0]),
    .discont       (discont_out  ),
    .int_in_service(int_in_service),
    .REPEAT        (REPEAT       ),
    .ready_q0      (ready_q0 && ~discont_out)
);

wire BTB_;
wire [5:0] bit_number;
wire bitmatch;

assign bit_number = {SigB_q2, Size_SrcB_q2[2:0], Ind_SrcB_q2, OPsrcB_q2[14]};
assign BTB_  = ((OPdest_q2==BTBS_) || (OPdest_q2==BTBC_)) && ~Ind_Dest_q2 && wrcycl && q1_sel;
assign bitmatch = ((OPdest_q2==BTBC_) ? ~wrsrcAdata[bit_number] : wrsrcAdata[bit_number]) && BTB_;

always @(*) begin
   if (RESET) pre_PC = 'h100;
   else if (ld_vector) pre_PC = vector;
   else if (rewind_PC && ~break_q0) pre_PC = pc_q1;
   else if (bitmatch) pre_PC = pc_q2 + {{`PCWIDTH-13{OPsrcB_q2[12]}}, OPsrcB_q2[12:0]};
   else if ((OPdest_q2==PC_ADDRS) && wrcycl && ~Ind_Dest_q2) pre_PC = wrsrcAdata[`PCWIDTH-1:0];  //absolute jump
   else pre_PC = PC + ((RPT_not_z  || break_q0) ? 1'b0 : 1'b1);
end    

//A-side reads
always @(*) begin  
           casex (SrcA_addrs_q1)
           32'b0000_0000_0000_1111_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1110_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1101_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1100_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1011_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1010_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1001_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1000_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0111_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0110_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0101_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0100_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0011_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0010_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx
                        : rdSrcAdata = glob_RAM_rddataA[63:0]; //addresses are in bytes
               SP_ADDRS : rdSrcAdata = {32'b0, SP };                      
              AR6_ADDRS : rdSrcAdata = {32'b0, AR6};                      
              AR5_ADDRS : rdSrcAdata = {32'b0, AR5};
              AR4_ADDRS : rdSrcAdata = {32'b0, AR4};
              AR3_ADDRS : rdSrcAdata = {32'b0, AR3};                      
              AR2_ADDRS : rdSrcAdata = {32'b0, AR2};                      
              AR1_ADDRS : rdSrcAdata = {32'b0, AR1};
              AR0_ADDRS : rdSrcAdata = {32'b0, AR0};
               PC_ADDRS : rdSrcAdata = {{64-`PCWIDTH{1'b0}}, PC};
          PC_COPY_ADDRS : rdSrcAdata = {{64-`PCWIDTH{1'b0}}, PC_COPY};
               ST_ADDRS : rdSrcAdata = STATUS;
             PRNG_ADDRS : rdSrcAdata = PRNG_rddataA;
           REPEAT_ADDRS : rdSrcAdata = {{64-`RPTSIZE{1'b0}}, REPEAT};  
           LPCNT1_ADDRS : rdSrcAdata = {{63-`LPCNTRSIZE{1'b0}}, LPCNT1_nz, LPCNT1};
           LPCNT0_ADDRS : rdSrcAdata = {{63-`LPCNTRSIZE{1'b0}}, LPCNT0_nz, LPCNT0};
            TIMER_ADDRS : rdSrcAdata = {32'b0, timer};           //32-bit timer                    
             
            CAPT3_ADDRS,
            CAPT2_ADDRS,
            CAPT1_ADDRS,
            CAPT0_ADDRS : rdSrcAdata = capt_dataA;           //capture registers are 64-bits  
             
            CLASS_ADDRS : rdSrcAdata = {60'b0, class[3:0]};
         SAVFLAGS_ADDRS : rdSrcAdata = {59'b0, flags[4:0]};
           RNDDIR_ADDRS : rdSrcAdata = {61'b0, roundDirection[2:0]};
            RADIX_ADDRS : rdSrcAdata = {62'b0, 2'b10};
         SAVMODES_ADDRS : rdSrcAdata = {60'b0, sModes[3:0]};
              MON_ADDRS : rdSrcAdata = mon_write_reg[63:0];  //this data comes from the monitor/debugger/break block 
    XCU_CNTRL_REG_ADDRS : rdSrcAdata = XCU_CNTRL_REG[63:0];
   XCU_STATUS_REG_ADDRS : rdSrcAdata = XCU_STATUS_REG[63:0]; //{XCU_DONE[15:0], XCU_SWBRKDET[15:0], XCU_BROKE[15:0], XCU_SKIPCMPLT[15:0]}
            
            FLOAT_ADDRS : rdSrcAdata = float_rddataA[63:0];
           INTEGR_ADDRS : rdSrcAdata = rddataA_integer[63:0];
           
           
         PRIV_RAM_ADDRS : rdSrcAdata =  priv_RAM_rddataA[63:0];        //lowest 8k bytes of memory is RAM space               
               default  : rdSrcAdata = 64'b0;  
           endcase
end                                                                          

//B-side reads
always @(*) begin    //addresses are in bytes
           casex (SrcB_addrs_q1)
           32'b0000_0000_0000_1111_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1110_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1101_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1100_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1011_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1010_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1001_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_1000_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0111_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0110_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0101_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0100_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0011_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0010_xxxx_xxxx_xxxx_xxxx,
           32'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx
                        : rdSrcBdata = glob_RAM_rddataB[63:0];
               SP_ADDRS : rdSrcBdata = {32'b0, SP };                      
              AR6_ADDRS : rdSrcBdata = {32'b0, AR6};                      
              AR5_ADDRS : rdSrcBdata = {32'b0, AR5};
              AR4_ADDRS : rdSrcBdata = {32'b0, AR4};
              AR3_ADDRS : rdSrcBdata = {32'b0, AR3};                      
              AR2_ADDRS : rdSrcBdata = {32'b0, AR2};                      
              AR1_ADDRS : rdSrcBdata = {32'b0, AR1};
              AR0_ADDRS : rdSrcBdata = {32'b0, AR0};
               PC_ADDRS : rdSrcBdata = {{64-`PCWIDTH{1'b0}}, PC};
          PC_COPY_ADDRS : rdSrcBdata = {{64-`PCWIDTH{1'b0}}, PC_COPY};
               ST_ADDRS : rdSrcBdata = STATUS;
           REPEAT_ADDRS : rdSrcBdata = {{64-`RPTSIZE{1'b0}}, REPEAT};  
           LPCNT1_ADDRS : rdSrcBdata = {{63-`LPCNTRSIZE{1'b0}}, LPCNT1_nz, LPCNT1};
           LPCNT0_ADDRS : rdSrcBdata = {{63-`LPCNTRSIZE{1'b0}}, LPCNT0_nz, LPCNT0};
            TIMER_ADDRS : rdSrcBdata = {32'b0, timer};           //32-bit timer                    
             
            CAPT3_ADDRS,
            CAPT2_ADDRS,
            CAPT1_ADDRS,
            CAPT0_ADDRS : rdSrcBdata = capt_dataB[63:0];           //capture registers are 64-bits
            
            CLASS_ADDRS : rdSrcBdata = {60'b0, class[3:0]};
         SAVFLAGS_ADDRS : rdSrcBdata = {59'b0, flags[4:0]};
           RNDDIR_ADDRS : rdSrcBdata = {61'b0, roundDirection[2:0]};
            RADIX_ADDRS : rdSrcBdata = {62'b0, 2'b10};
         SAVMODES_ADDRS : rdSrcBdata = {60'b0, sModes[3:0]};
              MON_ADDRS : rdSrcBdata = mon_write_reg[63:0];  //this data comes from the monitor/debugger/break block 
    XCU_CNTRL_REG_ADDRS : rdSrcBdata = XCU_CNTRL_REG[63:0];
   XCU_STATUS_REG_ADDRS : rdSrcBdata = XCU_STATUS_REG[63:0];
  
            FLOAT_ADDRS : rdSrcBdata = float_rddataB[63:0];
           INTEGR_ADDRS : rdSrcBdata = rddataB_integer[63:0];
           
         PRIV_RAM_ADDRS : rdSrcBdata = priv_RAM_rddataB[63:0];        //lowest 16k bytes of memory is private RAM space               
               default  : rdSrcBdata = 64'b0;            
           endcase
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) mon_read_reg <= 64'b0;
    else if (Dest_addrs_q2==MON_ADDRS && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && q2_sel) mon_read_reg <= wrsrcAdata;
end    

//get Rounding Direction register simply makes a copy of status register bits [61:60] , the round mode bits
always @(posedge CLK or posedge RESET) begin
    if (RESET) roundDirection <= 3'b000;
    else if (Dest_addrs_q2==RNDDIR_ADDRS && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && q2_sel) roundDirection <= {wrsrcAdata[63], wrsrcAdata[63], wrsrcAdata[63]} & wrsrcAdata[62:60];
end    

//save Modes register simply makes a copy of status register bits [63:60] , the round mode bits
always @(posedge CLK or posedge RESET) begin
    if (RESET) sModes <= 4'h0;
    else if (Dest_addrs_q2==SAVMODES_ADDRS && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && q2_sel) sModes <= wrsrcAdata[63:60];
end    

//save flags register simply makes a copy of the exception bits in the status register   
always @(posedge CLK or posedge RESET) begin
    if (RESET) flags <= 5'b00000;
    else if (Dest_addrs_q2==SAVFLAGS_ADDRS && ~|Dam_q2[1:0] && ~Ind_Dest_q2 && q2_sel) flags <= wrsrcAdata[10:6];
end    

// timer--counts clocks 
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        timer <= 32'b0;
        timercmpr <= 32'b0;     //default time-out value
    end    
    else if ((OPdest_q2==TIMER_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && q2_sel) begin
        timer <= 0;
        timercmpr <= wrsrcAdata[31:0];
    end    
    else if (~done && ~(timer==timercmpr)) timer <= timer + 1'b1;                   
end

//loop counters
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        LPCNT1 <= 0;
        LPCNT0 <= 0;
    end
    else begin
        if ((OPdest_q2==LPCNT0_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && q2_sel) LPCNT0 <= wrsrcAdata[`LPCNTRSIZE-1:0];
        else if ((OPdest_q2==BTBS_) && wrcycl && ~Ind_Dest_q2 && (OPsrcA_q2==LPCNT0_ADDRS[15:0]) && q2_sel && LPCNT0_nz) LPCNT0 <= LPCNT0_dec;
        
        if ((OPdest_q2==LPCNT1_ADDRS[15:0]) && wrcycl && ~Ind_Dest_q2 && q2_sel) LPCNT1 <= wrsrcAdata[`LPCNTRSIZE-1:0];
        else if ((OPdest_q2==BTBS_) && wrcycl && ~Ind_Dest_q2 && (OPsrcA_q2==LPCNT1_ADDRS[15:0]) && q2_sel && LPCNT1_nz) LPCNT1 <= LPCNT1_dec;
   end     
end

//eXtra Compute Unit (XCU) control register
always @(posedge CLK or posedge RESET)  //preEmptReq_SSTEP_forceBreak_forceReset
    if (RESET) XCU_CNTRL_REG <= 64'h0000_0000_FFFF_0000;  
    else if ((OPdest_q2==XCU_CNTRL_REG_ADDRS)   && wrcycl && ~Ind_Dest_q2 && q2_sel) XCU_CNTRL_REG <= wrsrcAdata;
    else if ((OPdest_q2==XCU_FORCE_RESET_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) XCU_CNTRL_REG[15:0] <= wrsrcAdata[15:0];
    else if ((OPdest_q2==XCU_FORCE_BREAK_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) XCU_CNTRL_REG[31:16] <= wrsrcAdata[15:0];
    else if ((OPdest_q2==XCU_SSTEP_ADDRS)       && wrcycl && ~Ind_Dest_q2 && q2_sel) XCU_CNTRL_REG[47:32] <= wrsrcAdata[15:0];
    else if ((OPdest_q2==XCU_PREEMPT_ADDRS)     && wrcycl && ~Ind_Dest_q2 && q2_sel) XCU_CNTRL_REG[63:48] <= wrsrcAdata[15:0];
    
    
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        NMI_VECTOR       <= 0;
        IRQ_VECTOR       <= 0; 
        invalid_VECTOR   <= 0; 
        divby0_VECTOR    <= 0; 
        overflow_VECTOR  <= 0; 
        underflow_VECTOR <= 0;
        inexact_VECTOR   <= 0; 
    end
    else begin
        if ((OPdest_q2==NMI_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) NMI_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
        if ((OPdest_q2==IRQ_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) IRQ_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
        if ((OPdest_q2==invalid_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) invalid_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
        if ((OPdest_q2==divby0_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) divby0_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
        if ((OPdest_q2==overflow_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) overflow_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
        if ((OPdest_q2==underflow_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) underflow_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
        if ((OPdest_q2==inexact_VECTOR_ADDRS) && wrcycl && ~Ind_Dest_q2 && q2_sel) inexact_VECTOR <= wrsrcAdata[`PCWIDTH-1:0];
   end 
end
   
endmodule
