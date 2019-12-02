//SOB_HAS_NO_XCUs.v
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

module SOB_HAS_NO_XCUs (
   CLK,
   RESET_IN,

   HTCK,  
   HTRSTn,
   HTMS,  
   HTDI,  
   HTDO,  

`ifdef SOB_has_external_SRAM
   CEN,   
   CE123, 
   WE,    
   BWh,   
   BWg,   
   BWf,   
   BWe,   
   BWd,   
   BWc,   
   BWb,   
   BWa,   
   adv_LD,
   A,     
   DQ,    
   OE,    
`else
`endif
   
   ready_q1,
   done,                                                            
   IRQ,
   event_det,
   
   HOST_wren,   
   HOST_rden,   
   HOST_wrSize, 
   HOST_rdSize, 
   HOST_wraddrs,
   HOST_rdaddrs,
   HOST_wrdata, 
   HOST_rddata 
   );

input  CLK;
input  RESET_IN;
input  HTCK;  
input  HTRSTn;
input  HTMS;
input  HTDI;  
output HTDO;  

output done;
output event_det;
input IRQ;
input ready_q1;

`ifdef SOB_has_external_SRAM
output CEN;   
output CE123; 
output WE;    
output BWh;   
output BWg;   
output BWf;   
output BWe;   
output BWd;   
output BWc;   
output BWb;   
output BWa;   
output adv_LD;
output [31:0] A;     
inout  [63:0] DQ;                                                 
output OE;
`else
`endif
 
input  HOST_wren;
input  HOST_rden;
input  [2:0] HOST_wrSize;
input  [2:0] HOST_rdSize;
input  [15:0] HOST_wraddrs;
input  [15:0] HOST_rdaddrs;

`ifdef SOB_has_Fat_Bus
input  [1023:0] HOST_wrdata;
output [1023:0] HOST_rddata;
`else
input  [63:0] HOST_wrdata;
output [63:0] HOST_rddata;
`endif

`ifdef SOB_has_Fat_Bus
wire [1023:0] HOST_rddata;
`else  
wire [63:0] HOST_rddata;
`endif

wire HTDO;  

`ifdef SOB_has_external_SRAM
wire CEN;   
wire CE123; 
wire WE;    
wire BWh;   
wire BWg;   
wire BWf;   
wire BWe;   
wire BWd;   
wire BWc;   
wire BWb;   
wire BWa;   
wire adv_LD;
wire [31:0] A;     
wire [63:0] DQ;                                                 
wire OE; 
`else
`endif

wire done;  
wire event_det;

wire [63:0] XCU_STATUS_REG;

assign XCU_STATUS_REG[63:0] = 64'b0;
                               
CPU CPU(
    .CLK   (CLK    ),
    .RESET_IN(RESET_IN),
    .HTCK  (HTCK   ),
    .HTRSTn(HTRSTn ),
    .HTMS  (HTMS   ),
    .HTDI  (HTDI   ),
    .HTDO  (HTDO   ),

`ifdef SOB_has_external_SRAM
    .CEN   (CEN   ),
    .CE123 (CE123 ),
    .WE    (WE    ),
    .BWh   (BWh   ),
    .BWg   (BWg   ),
    .BWf   (BWf   ),
    .BWe   (BWe   ),
    .BWd   (BWd   ),
    .BWc   (BWc   ),
    .BWb   (BWb   ),
    .BWa   (BWa   ),
    .adv_LD(adv_LD),
    .A     (A     ),
    .DQ    (DQ    ),
    .OE    (OE    ),
`else
`endif
                      
    .ready_q1(ready_q1),    
    .done  (done  ),
    .IRQ   (IRQ   ),
    .event_det(event_det),
    
    .XCU_CNTRL_REG           ( ),              
    .XCU_STATUS_REG          (XCU_STATUS_REG), //{XCU_DONE[15:0], XCU_SWBRKDET[15:0], XCU_BROKE[15:0], XCU_SKIPCMPLT[15:0]}
    .XCU_readSel_q0          ( ),
    .XCU_writeSel_q0         ( ),
    .XCU_monitorREADreq      ( ),
    .XCU_monitorWRITEreq     ( ),
    .XCU_monitorWRITE_ALL_req( ),
    .XCU_monitorRWaddrs_q0   ( ),
    .XCU_monitorRWsize_q0    ( ),
    .XCU_monitorREADdata_q1  (64'b0),   //comes from selected XCU rdSrcBdata  
    .XCU_monitorWRITEdata_q1 ( ),

    .HOST_wren   (HOST_wren   ),
    .HOST_rden   (HOST_rden   ),
    .HOST_wrSize (HOST_wrSize ),
    .HOST_rdSize (HOST_rdSize ),
    .HOST_wraddrs(HOST_wraddrs),
    .HOST_rdaddrs(HOST_rdaddrs),
    .HOST_wrdata (HOST_wrdata ),
    .HOST_rddata (HOST_rddata )
    );


endmodule
