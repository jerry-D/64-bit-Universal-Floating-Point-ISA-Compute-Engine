// STATUS_REG.v
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

module STATUS_REG (
    CLK,
    RESET,
    wrcycl,           
    q2_sel,
    OPdest_q2,
    rdStatus_q1,
    statusRWcollision,
    Ind_Dest_q2,
    SigA_q2,
    SigB_q2,
    Size_SrcA_q2,
    Size_SrcB_q2,
    Size_Dest_q2,
    wrsrcAdata, 
    wrsrcBdata, 
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
    enAltImmInexactHandl,  
    enAltImmUnderflowHandl,
    enAltImmOverflowHandl, 
    enAltImmDivByZeroHandl,
    enAltImmInvalidHandl,  
    IRQ_IE,
    STATUS,
    class,
    exc_codeA, 
    exc_codeB, 
    rd_float_q1_selA ,
    rd_float_q1_selB ,
    rd_integr_q1_selA,
    rd_integr_q1_selB,
    ACTM,
    fp_ready_q2
);

input  CLK;
input  RESET;
input  wrcycl;           
input  q2_sel;
input  [14:0] OPdest_q2;
input rdStatus_q1;
input Ind_Dest_q2;
input SigA_q2;
input SigB_q2;
input [1:0] Size_SrcA_q2; 
input [1:0] Size_SrcB_q2;
input [1:0] Size_Dest_q2; 
input  [63:0] wrsrcAdata; 
input  [63:0] wrsrcBdata; 
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
output [63:0] STATUS;
output [3:0] class;
input  [4:0] exc_codeA; 
input  [4:0] exc_codeB; 
input  rd_float_q1_selA;
input  rd_float_q1_selB;
input  rd_integr_q1_selA;
input  rd_integr_q1_selB;
input  fp_ready_q2;
                                                      
output enAltImmInexactHandl;  
output enAltImmUnderflowHandl;
output enAltImmOverflowHandl; 
output enAltImmDivByZeroHandl;
output enAltImmInvalidHandl; 

output statusRWcollision; 

output [3:0] ACTM;


parameter ST_ADDRS        = 15'h7FF1;
parameter savFlags_ADDRS  = 15'h7FD9;     //reading this location will return all flags
parameter sgtRnDir_ADDRS  = 15'h7FD8;     //read/write this location to get/set current rounding direction here, including restore and default modes
parameter clas_ADDRS      = 15'h7FD6;     //class(x)--clas is a 2-byte readable register at this location
parameter compare_ADDRS   = 15'h7FCF;     //integer compare address
parameter tstSavFlg_ADDRS = 15'h7FCE;     //test "saved" flags  
parameter actMode_ADDRS   = 15'h7FCD;     // neural network activation Mode address                         

parameter cmpSE_ADDRS     = 15'h7CFF;     //cmpSE  byte address compareSignalingEqual(source1, source2)           
parameter cmpQE_ADDRS     = 15'h7CFE;     //cmpQE   byte address compareQuietEqual(source1, source2)               
parameter cmpSNE_ADDRS    = 15'h7CFD;     //cmpSNE  byte address compareSignalingNotEqual(source1, source2)        
parameter cmpQNE_ADDRS    = 15'h7CFC;     //cmpQNE  byte address compareQuietNotEqual(source1, source2)            
parameter cmpSG_ADDRS     = 15'h7CFB;     //cmpSG  byte address compareSignalingGreater(source1, source2)         
parameter cmpQG_ADDRS     = 15'h7CFA;     //cmpQG  byte address compareQuietGreater(source1, source2)             
parameter cmpSGE_ADDRS    = 15'h7CF9;     //cmpSGE  byte address compareSignalingGreaterEqual(source1, source2)    
parameter cmpQGE_ADDRS    = 15'h7CF8;     //cmpQGE  byte address compareQuietGreaterEqual(source1, source2)        
parameter cmpSL_ADDRS     = 15'h7CF7;     //cmpSL  byte address compareSignalingLess(source1, source2)            
parameter cmpQL_ADDRS     = 15'h7CF6;     //cmpQL  byte address compareQuietLess(source1, source2)                
parameter cmpSLE_ADDRS    = 15'h7CF5;     //cmpSLE  byte address compareSignalingLessEqual(source1, source2)       
parameter cmpQLE_ADDRS    = 15'h7CF4;     //cmpQLE  byte address compareQuietLessEqual(source1, source2)           
parameter cmpSNG_ADDRS    = 15'h7CF3;     //cmpSNG  byte address compareSignalingNotGreater(source1, source2)      
parameter cmpQNG_ADDRS    = 15'h7CF2;     //cmpQNG  byte address compareQuietNotGreater(source1, source2)          
parameter cmpSLU_ADDRS    = 15'h7CF1;     //cmpSLU  byte address compareSignalingLessUnordered(source1, source2)   
parameter cmpQLU_ADDRS    = 15'h7CF0;     //cmpQLU  byte address compareQuietLessUnordered(source1, source2)       
parameter cmpSNL_ADDRS    = 15'h7CEF;     //cmpSNL  byte address compareSignalingNotLess(source1, source2)         
parameter cmpQNL_ADDRS    = 15'h7CEE;     //cmpQNL  byte address compareQuietNotLess(source1, source2)             
parameter cmpSGU_ADDRS    = 15'h7CED;     //cmpSGU  byte address compareSignalingGreaterUnordered(source1, source2)
parameter cmpQGU_ADDRS    = 15'h7CEC;     //cmpQGU  byte address compareQuietGreaterUnordered(source1, source2)    
parameter cmpQU_ADDRS     = 15'h7CEB;     //cmpQU  byte address compareQuietUnordered(source1, source2) 
parameter cmpQO_ADDRS     = 15'h7CEA;     //cmpQO  byte address compareQuietOrdered(source1, source2)             
parameter tOrd_ADDRS      = 15'h7CE9;     //total order
parameter tOrdM_ADDRS     = 15'h7CE8;     //total order magnitude           
parameter razFlg_ADDRS    = 15'h7CE7;     
parameter lowFlg_ADDRS    = 15'h7CE6;                                      
parameter razNoFlag_ADDRS = 15'h7CE5;     
parameter lowNoFlag_ADDRS = 15'h7CE4;     
parameter tstFlg_ADDRS    = 15'h7CE3;                                
parameter rstrFlg_ADDRS   = 15'h7CE2;
parameter razSig_ADDRS    = 15'h7CE1;     
parameter lowSig_ADDRS    = 15'h7CE0;     
parameter setSubstt_ADDRS = 15'h7CDF;     
parameter clrSubstt_ADDRS = 15'h7CDE;     
parameter setDVNCZ_ADDRS  = 15'h7CDD;     
parameter clrDVNCZ_ADDRS  = 15'h7CDC;     
parameter setAltImm_ADDRS = 15'h7CDB;     
parameter clrAltImm_ADDRS = 15'h7CDA;     
parameter deflt_ADDRS     = 15'h7CD9;
parameter isCanonical     = 15'h7CD8;
parameter isSignaling     = 15'h7CD7;
parameter isNaN           = 15'h7CD6;
parameter isInfinite      = 15'h7CD5;
parameter isSubnormal     = 15'h7CD4;
parameter isZero          = 15'h7CD3;
parameter isFinite        = 15'h7CD2;
parameter isNormal        = 15'h7CD1;
parameter isSignMinus     = 15'h7CD0;

parameter DP = 2'b11;
parameter SP = 2'b10;
parameter HP = 2'b01; 


reg invalid_q2;  
reg divby0_q2;   
reg overflow_q2; 
reg underflow_q2;
reg inexact_q2;

// is
reg Canonical;         
reg Signaling;         
reg NaN;               
reg Infinite;          
reg Subnormal;         
reg Zero;              
reg Finite;            
reg Normal;            
reg SignMinus; 

        
// alternate delayed substitution
reg subs_AbruptUndrFl;       //  bit 63
reg subs_X;                  //  bit 62
reg subs_Xor_X;              //  bit 61
reg subsInexact;             //  bit 60
reg subsUnderflow;           //  bit 59
reg subsOverflow;            //  bit 58
reg subsDivByZero;           //  bit 57
reg subsInvalid;             //  bit 56
                       

reg DEF_ONLY;                //  bit 55    when  = 1 then bits 53:51 are overridden such that only their default value is used and any RM bits in the instruction are also overridden
reg AWAY;                    //  bit 54
reg RM_ATR_EN;               //  bit 53
reg RM1;                     //  bit 52
reg RM0;                     //  bit 51

// total Order
reg compareTrue;             //  bit 50
reg isTrue;                  //  bit 49
reg aFlagRaised;             //  bit 48
reg totlOrderMag;            //  bit 47
reg totlOrder;               //  bit 46

// class
reg positiveInfinity;        //  bit 45
reg positiveNormal;          //  bit 44
reg positiveSubnormal;       //  bit 43
reg positiveZero;            //  bit 42
reg negativeZero;            //  bit 41
reg negativeSubnormal;       //  bit 40
reg negativeNormal;          //  bit 39
reg negativeInfinity;        //  bit 38
reg quietNaN;                //  bit 37
reg signalingNaN;            //  bit 36                       

reg enAltImmInexactHandl;    //  bit 35
reg enAltImmUnderflowHandl;  //  bit 34
reg enAltImmOverflowHandl;   //  bit 33
reg enAltImmDivByZeroHandl;  //  bit 32
reg enAltImmInvalidHandl;    //  bit 31

reg razNoInexactFlag;        //  bit 30
reg razNoUnderflowFlag;      //  bit 29
reg razNoOverflowFlag;       //  bit 28
reg razNoDivByZeroFlag;      //  bit 27
reg razNoInvalidFlag;        //  bit 26

reg inexact_flag;            //  bit 25
reg underflow_flag;          //  bit 24
reg overflow_flag;           //  bit 23
reg divby0_flag;             //  bit 22
reg invalid_flag;            //  bit 21

reg inexact_signal;          //  bit 20
reg underflow_signal;        //  bit 19
reg overflow_signal;         //  bit 18
reg divby0_signal;           //  bit 17
reg invalid_signal;          //  bit 16

wire spare4;                 //  bit 15
//wire spare3;                 //  bit 14
//wire spare2;                 //  bit 13
//wire spare1;                 //  bit 12
//wire spare0;                 //  bit 11
reg [3:0] ACTM;              // bits 14:11 are now neural network activation and accumulate mode

wire IRQ;                    //  bit 10
reg ExcSource_q2;            //  bit 9

wire A_GTE_B;                //  bit 8   ;1 = (A>=B)  notV_or_Z           read-only
wire A_LTE_B;                //  bit 7   ;1 = (A<=B)  ZorV                read-only
wire A_GT_B;                 //  bit 6   ;1 = (A>B)   notV_and_notZ       read-only

reg IRQ_IE;                  //  bit 5
reg done;                    //  bit 4
reg V;                       //  bit 3
reg N;                       //  bit 2
reg C;                       //  bit 1
reg Z;                       //  bit 0

reg [10:0] Xe; //X exponent
reg [10:0] Ye; //Y exponent
reg X_sign;
reg Y_sign;
reg [51:0] X_fraction;
reg [51:0] Y_fraction;

reg [3:0] class;

reg cmprEnable;

reg rd_float_q2_sel;
reg rd_integr_q2_sel;

wire statusRWcollision;
                                                                
wire [9:0] class_sel;

wire Status_wren;     

wire [63:0] STATUS;

wire [63:0] X;
wire [63:0] Y;

wire X_signalingNaN;     
wire X_quietNaN;         
wire X_negativeInfinity; 
wire X_negativeNormal;   
wire X_negativeSubnormal;
wire X_negativeZero;     
wire X_positiveZero;     
wire X_positiveSubnormal;
wire X_positiveNormal;   
wire X_positiveInfinity; 

wire X_SignMinus;         
wire X_Normal;            
wire X_Finite;            
wire X_Zero;              
wire X_Subnormal;         
wire X_Infinite;          
wire X_NaN;               
wire X_Signaling;         
wire X_Canonical; 
     
wire Y_SignMinus;         
wire Y_Normal;            
wire Y_Finite;            
wire Y_Zero;              
wire Y_Subnormal;         
wire Y_Infinite;          
wire Y_NaN;               
wire Y_Signaling;         
wire Y_Canonical;         
        
wire _totlOrder;         
wire _totlOrderMag;      

wire _compareTrue;  

wire X_LT_Y;
wire X_GT_Y;
wire X_EQ_Y;
wire UNORDERED; 

wire cmpSE; 
wire cmpQE; 
wire cmpSNE;
wire cmpQNE;
wire cmpSG; 
wire cmpQG; 
wire cmpSGE;
wire cmpQGE;
wire cmpSL; 
wire cmpQL; 
wire cmpSLE;
wire cmpQLE;
wire cmpSNG;
wire cmpQNG;
wire cmpSLU;
wire cmpQLU;
wire cmpSNL;
wire cmpQNL;                                                  
wire cmpSGU;                                                  
wire cmpQGU;                                                  
wire cmpQU;                                                   
wire cmpQO;                                                   

wire _aFlagRaised;

wire _aSFlagRaised;
                    
wire X_Invalid;
wire X_DivX0;
wire X_Overflow;
wire X_Underflow;
wire X_inexact;
                                                              
wire Y_Invalid;                                               
wire Y_DivX0;                                                 
wire Y_Overflow;                                              
wire Y_Underflow;                                             
wire Y_inexact;                            
wire [9:0] exc_sel;

wire cmprInvalid;  

wire signed [64:0] compareAdata;
wire signed [64:0] compareBdata;  

assign statusRWcollision = rdStatus_q1 && &OPdest_q2[14:8] && (~|OPdest_q2[7:5] || (OPdest_q2[7:3]==5'b10001));

assign compareAdata = {(SigA_q2 && wrsrcAdata[63]), wrsrcAdata};            
assign compareBdata = {(SigB_q2 && wrsrcBdata[63]), wrsrcBdata};            

assign X = {X_sign, Xe, X_fraction};
assign Y = {Y_sign, Ye, Y_fraction};         

assign X_LT_Y = (X_Zero && Y_Zero) ? 1'b0 : ({~X[63], X[62:0]} < {~Y[63], Y[62:0]});
assign X_GT_Y = (X_Zero && Y_Zero) ? 1'b0 : ({~X[63], X[62:0]} > {~Y[63], Y[62:0]});                          
assign X_EQ_Y = (X_Zero && Y_Zero) ? 1'b1 : ({~X[63], X[62:0]}=={~Y[63], Y[62:0]});
assign UNORDERED = X_NaN || Y_NaN; 

assign cmpSE  = ((OPdest_q2[14:0]==cmpSE_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && X_EQ_Y);
assign cmpQE  = ((OPdest_q2[14:0]==cmpQE_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && X_EQ_Y);
assign cmpSNE = ((OPdest_q2[14:0]==cmpSNE_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && ~X_EQ_Y);
assign cmpQNE = ((OPdest_q2[14:0]==cmpQNE_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && ~X_EQ_Y);
assign cmpSG  = ((OPdest_q2[14:0]==cmpSG_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && X_GT_Y);
assign cmpQG  = ((OPdest_q2[14:0]==cmpQG_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && X_GT_Y);
assign cmpSGE = ((OPdest_q2[14:0]==cmpSGE_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_GT_Y || X_EQ_Y));
assign cmpQGE = ((OPdest_q2[14:0]==cmpQGE_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_GT_Y || X_EQ_Y));
assign cmpSL  = ((OPdest_q2[14:0]==cmpSL_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && X_LT_Y);
assign cmpQL  = ((OPdest_q2[14:0]==cmpQL_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && X_LT_Y);
assign cmpSLE = ((OPdest_q2[14:0]==cmpSLE_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_LT_Y || X_EQ_Y));
assign cmpQLE = ((OPdest_q2[14:0]==cmpQLE_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_LT_Y || X_EQ_Y));
assign cmpSNG = ((OPdest_q2[14:0]==cmpSNG_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && ~X_GT_Y);
assign cmpQNG = ((OPdest_q2[14:0]==cmpQNG_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && ~X_GT_Y);
assign cmpSLU = ((OPdest_q2[14:0]==cmpSLU_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_LT_Y || UNORDERED));
assign cmpQLU = ((OPdest_q2[14:0]==cmpQLU_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_LT_Y || UNORDERED));
assign cmpSNL = ((OPdest_q2[14:0]==cmpSNL_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && ~X_LT_Y);
assign cmpQNL = ((OPdest_q2[14:0]==cmpQNL_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && ~X_LT_Y);
assign cmpSGU = ((OPdest_q2[14:0]==cmpSGU_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_GT_Y || UNORDERED));
assign cmpQGU = ((OPdest_q2[14:0]==cmpQGU_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel && (X_GT_Y || UNORDERED));
assign cmpQU  = ((OPdest_q2[14:0]==cmpQU_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && UNORDERED);
assign cmpQO  = ((OPdest_q2[14:0]==cmpQO_ADDRS[14:0])  && ~Ind_Dest_q2 && wrcycl && q2_sel && ~UNORDERED);

assign _compareTrue = cmpSE  || 
                      cmpQE  || 
                      cmpSNE || 
                      cmpQNE || 
                      cmpSG  || 
                      cmpQG  || 
                      cmpSGE || 
                      cmpQGE || 
                      cmpSL  || 
                      cmpQL  || 
                      cmpSLE || 
                      cmpQLE || 
                      cmpSNG || 
                      cmpQNG || 
                      cmpSLU || 
                      cmpQLU || 
                      cmpSNL || 
                      cmpQNL || 
                      cmpSGU || 
                      cmpQGU || 
                      cmpQU  || 
                      cmpQO  ;


 always @(*)
    casex(OPdest_q2)
      cmpSE_ADDRS  ,
      cmpQE_ADDRS  ,
      cmpSNE_ADDRS ,
      cmpQNE_ADDRS ,
      cmpSG_ADDRS  ,
      cmpQG_ADDRS  ,
      cmpSGE_ADDRS ,
      cmpQGE_ADDRS ,
      cmpSL_ADDRS  ,
      cmpQL_ADDRS  ,
      cmpSLE_ADDRS ,
      cmpQLE_ADDRS ,
      cmpSNG_ADDRS ,
      cmpQNG_ADDRS ,
      cmpSLU_ADDRS ,
      cmpQLU_ADDRS ,
      cmpSNL_ADDRS ,
      cmpQNL_ADDRS ,
      cmpSGU_ADDRS ,
      cmpQGU_ADDRS ,
      cmpQU_ADDRS  ,
      cmpQO_ADDRS  : cmprEnable = 1'b1;
           default : cmprEnable = 1'b0;
    endcase 
                      
assign cmprInvalid =    (cmprEnable && (X_Signaling || Y_Signaling)) ||
                        ((X_NaN || Y_NaN) && 
                         (cmpSE          ||
                          cmpSNE         ||
                          cmpSG          ||
                          cmpSGE         ||
                          cmpSL          ||
                          cmpSLE         ||
                          cmpSNG         ||
                          cmpSLU         ||
                          cmpSNL         ||
                          cmpSGU)) ;
                         
assign X_signalingNaN      = (Xe==11'b111_1111_1111) && ~X_fraction[51] &&  |X_fraction[50:0];
assign X_quietNaN          = (Xe==11'b111_1111_1111) &&  X_fraction[51] &&  |X_fraction[50:0];
assign X_negativeInfinity  =  X_sign && (Xe==11'b111_1111_1111) && ~|X_fraction;
assign X_negativeNormal    =  X_sign &&  (Xe > 11'h000) && (Xe < 11'h7FF);
assign X_negativeSubnormal =  X_sign && (Xe==11'b0) && |X_fraction;
assign X_negativeZero      = ~X_sign && ~|Xe && ~|X_fraction;
assign X_positiveZero      =  X_sign && ~|Xe && ~|X_fraction;
assign X_positiveSubnormal = ~X_sign && (Xe==11'b0) && |X_fraction;
assign X_positiveNormal    = ~X_sign &&  (Xe > 11'h000) && (Xe < 11'h7FF);
assign X_positiveInfinity  = ~X_sign && (Xe==11'b111_1111_1111) && ~|X_fraction;

assign X_SignMinus    =  X_sign;   
assign X_Normal       =  (Xe > 11'h000) && (Xe < 11'h7FF);   
assign X_Finite       =  X_Normal || X_Subnormal || X_Zero;    
assign X_Zero         = ~|Xe && ~|X_fraction;    
assign X_Subnormal    = (Xe==11'b0) && |X_fraction;    
assign X_Infinite     = (Xe==11'b111_1111_1111) && ~|X_fraction;    
assign X_NaN          = (Xe==11'b111_1111_1111) &&  |X_fraction[50:0];     
assign X_Signaling    = (Xe==11'b111_1111_1111) && ~X_fraction[51] &&  |X_fraction[50:0];    
assign X_Canonical    = X_Finite || X_Infinite || X_NaN; 
       
assign Y_SignMinus   =  Y_sign;   
assign Y_Normal      =  (Ye > 11'h000) && (Ye < 11'h7FF);   
assign Y_Finite      =  Y_Normal || Y_Subnormal || Y_Zero;    
assign Y_Zero        = ~|Ye && ~|Y_fraction;    
assign Y_Subnormal   = (Ye==11'b0) && |Y_fraction;    
assign Y_Infinite    = (Ye==11'b111_1111_1111) && ~|Y_fraction;    
assign Y_NaN         = (Ye==11'b111_1111_1111) &&  |Y_fraction[50:0];     
assign Y_Signaling   = (Ye==11'b111_1111_1111) && ~Y_fraction[51] &&  |Y_fraction[50:0];    
assign Y_Canonical   = Y_Finite || Y_Infinite || Y_NaN; 

assign _totlOrder    = ({~X[63], X[62:0]} <= {~Y[63], Y[62:0]}) && Y_Canonical && X_Canonical;
                       
assign _totlOrderMag = (X[62:0] <= Y[62:0]) && Y_Canonical && X_Canonical;

assign Status_wren = ((OPdest_q2[14:0]==ST_ADDRS[14:0]) && ~Ind_Dest_q2 && wrcycl && q2_sel);

assign _aFlagRaised = (inexact_flag && wrsrcAdata[4]) || (underflow_flag && wrsrcAdata[3]) || (overflow_flag && wrsrcAdata[2]) || (divby0_flag && wrsrcAdata[1]) || (invalid_flag && wrsrcAdata[0]);

//a saved flag is raised test
assign _aSFlagRaised = (wrsrcBdata[4] && wrsrcAdata[4]) || (wrsrcBdata[3] && wrsrcAdata[3]) || (wrsrcBdata[2] && wrsrcAdata[2]) || (wrsrcBdata[1] && wrsrcAdata[1]) || (wrsrcBdata[0] && wrsrcAdata[0]);

assign class_sel = {X_signalingNaN,     
                    X_quietNaN,         
                    X_negativeInfinity, 
                    X_negativeNormal,   
                    X_negativeSubnormal,
                    X_negativeZero,     
                    X_positiveZero,     
                    X_positiveSubnormal,
                    X_positiveNormal,   
                    X_positiveInfinity};
                    


assign  STATUS = {subs_AbruptUndrFl     , //bit 63
                  subs_X                , //bit 62
                  subs_Xor_X            , //bit 61
                  subsInexact           , //bit 60
                  subsUnderflow         , //bit 59
                  subsOverflow          , //bit 58
                  subsDivByZero         , //bit 57
                  subsInvalid           , //bit 56
                  
                  DEF_ONLY              , //bit 55
                  AWAY                  , //bit 54
                  RM_ATR_EN             , //bit 53
                  RM1                   , //bit 52
                  RM0                   , //bit 51
        
                  compareTrue           , //bit 50
                  isTrue                , //bit 49  single flag for all the "Is"(es)
                  aFlagRaised           , //bit 48
        
                  // total Order   
                  totlOrderMag          , //bit 47
                  totlOrder             , //bit 46
                
                   // class        
                  positiveInfinity      , //bit 45
                  positiveNormal        , //bit 44
                  positiveSubnormal     , //bit 43
                  positiveZero          , //bit 42
                  negativeZero          , //bit 41
                  negativeSubnormal     , //bit 40
                  negativeNormal        , //bit 39
                  negativeInfinity      , //bit 38
                  quietNaN              , //bit 37
                  signalingNaN          , //bit 36
                                    
                  enAltImmInexactHandl  , //bit 35
                  enAltImmUnderflowHandl, //bit 34
                  enAltImmOverflowHandl , //bit 33
                  enAltImmDivByZeroHandl, //bit 32
                  enAltImmInvalidHandl  , //bit 31
                  
                  razNoInexactFlag      , //bit 30  
                  razNoUnderflowFlag    , //bit 29
                  razNoOverflowFlag     , //bit 28
                  razNoDivByZeroFlag    , //bit 27
                  razNoInvalidFlag      , //bit 26
        
                  inexact_flag          , //bit 25
                  underflow_flag        , //bit 24
                  overflow_flag         , //bit 23
                  divby0_flag           , //bit 22
                  invalid_flag          , //bit 21
                  
                  inexact_signal        , //bit 20
                  underflow_signal      , //bit 19
                  overflow_signal       , //bit 18
                  divby0_signal         , //bit 17
                  invalid_signal        , //bit 16
                                                 
                  spare4                , //bit 15     (read-only)
//                  spare3                , //bit 14     (read-only)
//                  spare2                , //bit 13     (read-only)
//                  spare1                , //bit 12     (read-only)
//                  spare0                , //bit 11     (read-only)
                  ACTM[3:0]             , //neural network activation mode
                  
                  IRQ                   , //bit 10  interrupt request (read-only)
                  ExcSource_q2          , //bit 9          
        
                  A_GTE_B               , //bit 8   1 = (A>=B)  notV_or_Z           read-only
                  A_LTE_B               , //bit 7   1 = (A<=B)  ZorV                read-only
                  A_GT_B                , //bit 6   1 = (A>B)   notV_and_notZ       read-only
                  
                  IRQ_IE                , //bit 5   interrupt enable
                  done                  , //bit 4
                  V                     , //bit 3   1 = (A<B)
                  N                     , //bit 2
                  C                     , //bit 1
                  Z                       //bit 0   1 = (A==B)
                  }; 
                             
assign A_GTE_B = ~V ||  Z;
assign A_LTE_B =  V ||  Z;
assign A_GT_B  = ~V && ~Z;

assign spare4 = 0;
//assign spare3 = 0;
//assign spare2 = 0;
//assign spare1 = 0;
//assign spare0 = 0;

// exception codes for five MSBs [68:64] of final result
parameter _no_excpt_   = 5'b00000;  
parameter _inexact_    = 5'b00001;
parameter _underflow_  = 5'b00010;                     
parameter _overflow_   = 5'b00100;                                                        
parameter _invalid_    = 5'b01000;  
parameter _div_x_0_    = 5'b10000;  

assign X_Invalid   = X_NaN && (exc_codeA[3]==1'b1) && fp_ready_q2;
assign X_DivX0     = X_Infinite && (exc_codeA[4]==1'b1) && fp_ready_q2;
assign X_Overflow  = X_Infinite && (exc_codeA[2]==1'b1) && fp_ready_q2;
assign X_Underflow = X_Subnormal && ( ((exc_codeA[1:0]==2'b10) && enAltImmUnderflowHandl) || (exc_codeA[1:0]==2'b11) ) && fp_ready_q2;
assign X_inexact   = ((exc_codeA==_inexact_) || X_Overflow || (exc_codeA[1:0]==2'b11)) && fp_ready_q2; //under default exc handling, Underflow is not signaled unless it is also inexact
                                                   
assign Y_Invalid   = Y_NaN && (exc_codeB[3]==1'b1) && fp_ready_q2;
assign Y_DivX0     = Y_Infinite && (exc_codeB[4]==1'b1) && fp_ready_q2;
assign Y_Overflow  = Y_Infinite && (exc_codeB[2]==1'b1) && fp_ready_q2;
assign Y_Underflow = Y_Subnormal && ( ((exc_codeB[1:0]==2'b10) && enAltImmUnderflowHandl) || (exc_codeB[1:0]==2'b11) ) && fp_ready_q2;
assign Y_inexact   = ((exc_codeB==_inexact_) || Y_Overflow || (exc_codeB[1:0]==2'b11)) && fp_ready_q2; //under default exc handling, Underflow is not signaled unless it is also inexact

assign exc_sel = {X_Invalid, X_DivX0, X_Overflow, X_Underflow, X_inexact, Y_Invalid, Y_DivX0, Y_Overflow, Y_Underflow, Y_inexact}; 

always @(*)
    casex(exc_sel)
        10'b1xxxx_xxxxx : begin
                              invalid_q2   =  1'b1;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b0;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b01xxx_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b1;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b0;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b001xx_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b1;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b1;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b0001x_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b1;
                              inexact_q2   =  X_inexact;
                              ExcSource_q2 =  1'b0;
                          end   
        10'b00001_xxxxx : begin
                              invalid_q2   =  1'b0;
                              divby0_q2    =  1'b0;
                              overflow_q2  =  1'b0;
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b1;
                              ExcSource_q2 =  1'b0;
                          end   
                              
                              
        10'b00000_1xxxx : begin                                                
                              invalid_q2   =  1'b1;                            
                              divby0_q2    =  1'b0;                            
                              overflow_q2  =  1'b0;                            
                              underflow_q2 =  1'b0;                            
                              inexact_q2   =  1'b0;                            
                              ExcSource_q2 =  1'b1;                            
                          end                                                 
        10'b00000_01xxx : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b1;                            
                              overflow_q2  =  1'b0;                            
                              underflow_q2 =  1'b0;                            
                              inexact_q2   =  1'b0;                            
                              ExcSource_q2 =  1'b1;                            
                          end                                                 
        10'b00000_001xx : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                            
                              overflow_q2  =  1'b1;                            
                              underflow_q2 =  1'b0;                            
                              inexact_q2   =  1'b1;                            
                              ExcSource_q2 =  1'b1;                            
                          end                                                 
        10'b00000_0001x : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                            
                              overflow_q2  =  1'b0;                            
                              underflow_q2 =  1'b1;                            
                              inexact_q2   =  Y_inexact;                            
                              ExcSource_q2 =  1'b1;                            
                           end                                                 
        10'b00000_00001 : begin                                                
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                                  
                              overflow_q2  =  1'b0;                                  
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b1;
                              ExcSource_q2 =  1'b1;
                          end
                default : begin
                              invalid_q2   =  1'b0;                            
                              divby0_q2    =  1'b0;                                  
                              overflow_q2  =  1'b0;                                  
                              underflow_q2 =  1'b0;
                              inexact_q2   =  1'b0;
                              ExcSource_q2 =  1'b0;
                          end         
    endcase

                              
always @(*)
    casex(OPdest_q2)
        cmpSE_ADDRS  ,   
        cmpQE_ADDRS  ,
        cmpSNE_ADDRS ,
        cmpQNE_ADDRS ,
        cmpSG_ADDRS  ,
        cmpQG_ADDRS  ,
        cmpSGE_ADDRS ,
        cmpQGE_ADDRS ,
        cmpSL_ADDRS  ,
        cmpQL_ADDRS  ,
        cmpSLE_ADDRS ,
        cmpQLE_ADDRS ,
        cmpSNG_ADDRS ,
        cmpQNG_ADDRS ,
        cmpSLU_ADDRS ,
        cmpQLU_ADDRS ,
        cmpSNL_ADDRS ,
        cmpQNL_ADDRS ,
        cmpSGU_ADDRS ,
        cmpQGU_ADDRS ,
        cmpQU_ADDRS  ,
        cmpQO_ADDRS  : cmprEnable = 1'b1;
    default : cmprEnable = 1'b0;               
    endcase

always @(posedge CLK or posedge RESET)
    if (RESET) class <= 4'b0;
    else if ((OPdest_q2[14:0]==clas_ADDRS) && ~Ind_Dest_q2 && wrcycl && q2_sel)
        casex(class_sel)
            10'b1xxxxxxxxx : class <= 4'h1;
            10'b01xxxxxxxx : class <= 4'h2;
            10'b001xxxxxxx : class <= 4'h3;
            10'b0001xxxxxx : class <= 4'h4;
            10'b00001xxxxx : class <= 4'h5;
            10'b000001xxxx : class <= 4'h6;
            10'b0000001xxx : class <= 4'h7;
            10'b00000001xx : class <= 4'h8;
            10'b000000001x : class <= 4'h9;
            10'b0000000001 : class <= 4'hA;
                   default : class <= 4'h0;   //4'hB = undefined
        endcase    
    

always @(*)
    if (Size_SrcA_q2==DP) {X_sign, Xe, X_fraction} =  wrsrcAdata[63:0];  // convert to DP
    else if (Size_SrcA_q2==SP) begin   
        X_sign     = wrsrcAdata[31];
        Xe[10:0]   = &wrsrcAdata[30:23] ? {3'b111, wrsrcAdata[30:23]} : (wrsrcAdata[30:23] + 10'h380);
        X_fraction = {wrsrcAdata[22:0], 32'b0};
    end    
    else begin   
        X_sign     = wrsrcAdata[15];
        Xe[10:0]   = &wrsrcAdata[14:10] ? {6'b111111, wrsrcAdata[14:10]} : (wrsrcAdata[14:10] + 10'h3F0);
        X_fraction = {wrsrcAdata[9:0], 48'b0};
    end    

always @(*)
    if (Size_SrcB_q2==DP) {Y_sign, Ye, Y_fraction} =  wrsrcBdata[63:0];  // convert to DP
    else if (Size_SrcB_q2==SP) begin   
        Y_sign     = wrsrcBdata[31];
        Ye[10:0]   = &wrsrcBdata[30:23] ? {3'b111, wrsrcBdata[30:23]} : (wrsrcBdata[30:23] + 10'h380);
        Y_fraction = {wrsrcBdata[22:0], 32'b0};
    end    
    else begin  
        Y_sign     = wrsrcBdata[15];
        Ye[10:0]   = &wrsrcBdata[14:10] ? {6'b111111, wrsrcBdata[14:10]} : (wrsrcBdata[14:10] + 10'h3F0);
        Y_fraction = {wrsrcBdata[9:0], 48'b0};
    end    

wire [14:0] opAddrs_q2;
assign opAddrs_q2 = OPdest_q2[14:0];
always@(posedge CLK or posedge RESET) begin
    if (RESET) begin
        
        subs_AbruptUndrFl <= 1'b0;         //bit 63
        subs_X            <= 1'b0;         //bit 62
        subs_Xor_X        <= 1'b0;         //bit 61
        subsInexact       <= 1'b0;         //bit 50
        subsUnderflow     <= 1'b0;         //bit 59
        subsOverflow      <= 1'b0;         //bit 58
        subsDivByZero     <= 1'b0;         //bit 57
        subsInvalid       <= 1'b0;         //bit 56
        
        DEF_ONLY          <= 1'b0;         //bit 55
        AWAY              <= 1'b0;         //bit 54
        RM_ATR_EN         <= 1'b0;         //bit 53
        RM1               <= 1'b0;         //bit 52
        RM0               <= 1'b0;         //bit 51
        
        compareTrue       <= 1'b0;         //bit 50
        isTrue            <= 1'b0;         //bit 49  single flag for all the "Is"(es)
        aFlagRaised       <= 1'b0;         //bit 48
        
        // total Order            
        totlOrderMag      <= 1'b0;         //bit 47
        totlOrder         <= 1'b0;         //bit 46
        
         // class         
        positiveInfinity  <= 1'b0;         //bit 45
        positiveNormal    <= 1'b0;         //bit 44
        positiveSubnormal <= 1'b0;         //bit 43
        positiveZero      <= 1'b0;         //bit 42
        negativeZero      <= 1'b0;         //bit 41
        negativeSubnormal <= 1'b0;         //bit 40
        negativeNormal    <= 1'b0;         //bit 39
        negativeInfinity  <= 1'b0;         //bit 38
        quietNaN          <= 1'b0;         //bit 37
        signalingNaN      <= 1'b0;         //bit 36
                           
        enAltImmInexactHandl   <= 1'b0;    //bit 35
        enAltImmUnderflowHandl <= 1'b0;    //bit 34
        enAltImmOverflowHandl  <= 1'b0;    //bit 33
        enAltImmDivByZeroHandl <= 1'b0;    //bit 32
        enAltImmInvalidHandl   <= 1'b0;    //bit 31

        razNoInexactFlag   <= 1'b1;        //bit 30  
        razNoUnderflowFlag <= 1'b0;        //bit 29
        razNoOverflowFlag  <= 1'b0;        //bit 28
        razNoDivByZeroFlag <= 1'b0;        //bit 27
        razNoInvalidFlag   <= 1'b0;        //bit 26

        inexact_flag      <= 1'b0;         //bit 25
        underflow_flag    <= 1'b0;         //bit 24
        overflow_flag     <= 1'b0;         //bit 23
        divby0_flag       <= 1'b0;         //bit 22
        invalid_flag      <= 1'b0;         //bit 21
        
        inexact_signal    <= 1'b0;         //bit 20
        underflow_signal  <= 1'b0;         //bit 19
        overflow_signal   <= 1'b0;         //bit 18
        divby0_signal     <= 1'b0;         //bit 17
        invalid_signal    <= 1'b0;         //bit 16
        
        ACTM[3:0]         <= 4'b0000;      //bits 14:11
        
        IRQ_IE            <= 1'b0;         //bit 5
        done   <= 1'b1;                    //bit 4                                                                                  
        V      <= 1'b0;                    //bit 3                                                                                  
        N      <= 1'b0;                    //bit 2                                                                                  
        C      <= 1'b0;                    //bit 1                                                                                  
        Z      <= 1'b1;                    //bit 0                                                                                  
                                                                                                                                    
        rd_float_q2_sel  <= 1'b0;                                                                                                   
        rd_integr_q2_sel <= 1'b0;                                                                                                   
    end                                                                                            
    else begin                                                                                     

       rd_float_q2_sel  <= rd_float_q1_selA || rd_float_q1_selB;
       rd_integr_q2_sel <= rd_integr_q1_selA;

//these five bits can be used as general-purpose status bits if not used as substitution attribute bits, since such function is optional according to the IEEE 754-2008 spec
       if (Status_wren) {subs_AbruptUndrFl, 
                         subs_X, 
                         subs_Xor_X, 
                         subsInexact, 
                         subsUnderflow, 
                         subsOverflow, 
                         subsDivByZero, 
                         subsInvalid} <= wrsrcAdata[63:56];
                         
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrSubstt_ADDRS) && ~Ind_Dest_q2)
            {subs_AbruptUndrFl,
             subs_X, 
             subs_Xor_X, 
             subsInexact, 
             subsUnderflow, 
             subsOverflow, 
             subsDivByZero, 
             subsInvalid} <= {(wrsrcAdata[7] ? 1'b0 : subs_AbruptUndrFl),
                              (wrsrcAdata[6] ? 1'b0 : subs_X           ),
                              (wrsrcAdata[5] ? 1'b0 : subs_Xor_X       ),
                              (wrsrcAdata[4] ? 1'b0 : subsInexact      ),
                              (wrsrcAdata[3] ? 1'b0 : subsUnderflow    ),
                              (wrsrcAdata[2] ? 1'b0 : subsOverflow     ),
                              (wrsrcAdata[1] ? 1'b0 : subsDivByZero    ),
                              (wrsrcAdata[0] ? 1'b0 : subsInvalid      )};
                              
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setSubstt_ADDRS) && ~Ind_Dest_q2)
            {subs_AbruptUndrFl,
             subs_X, 
             subs_Xor_X, 
             subsInexact, 
             subsUnderflow, 
             subsOverflow, 
             subsDivByZero, 
             subsInvalid} <= {(wrsrcAdata[7] ? 1'b1 : subs_AbruptUndrFl),
                              (wrsrcAdata[6] ? 1'b1 : subs_X           ),
                              (wrsrcAdata[5] ? 1'b1 : subs_Xor_X       ),
                              (wrsrcAdata[4] ? 1'b1 : subsInexact      ),
                              (wrsrcAdata[3] ? 1'b1 : subsUnderflow    ),
                              (wrsrcAdata[2] ? 1'b1 : subsOverflow     ),
                              (wrsrcAdata[1] ? 1'b1 : subsDivByZero    ),
                              (wrsrcAdata[0] ? 1'b1 : subsInvalid      )};
       
//these five bits are the "flags"              
       if (Status_wren) inexact_flag <= wrsrcAdata[25];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowFlg_ADDRS)  && ~Ind_Dest_q2) inexact_flag <= wrsrcAdata[4] ? 1'b0 : inexact_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razFlg_ADDRS)  && ~Ind_Dest_q2) inexact_flag <= wrsrcAdata[4] ? 1'b1 : inexact_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==rstrFlg_ADDRS) && ~Ind_Dest_q2) inexact_flag <= (wrsrcAdata[4] && wrsrcBdata[4]);                                                                  
       else if (inexact_q2 && ~enAltImmInexactHandl && ~razNoInexactFlag && rd_float_q2_sel && q2_sel) inexact_flag <= 1'b1;   //note: ~razNoInexactFlag is set to "1" on reset, which is default setting for this flag

       if (Status_wren) underflow_flag <= wrsrcAdata[24];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowFlg_ADDRS)  && ~Ind_Dest_q2) underflow_flag <= wrsrcAdata[3] ? 1'b0 : underflow_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razFlg_ADDRS)  && ~Ind_Dest_q2) underflow_flag <= wrsrcAdata[3] ? 1'b1 : underflow_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==rstrFlg_ADDRS) && ~Ind_Dest_q2) underflow_flag <=(wrsrcAdata[3] && wrsrcBdata[3]);                                                                  
       else if (underflow_q2 && ~enAltImmUnderflowHandl && ~razNoUnderflowFlag && rd_float_q2_sel && q2_sel) underflow_flag <= 1'b1;

       if (Status_wren) overflow_flag <= wrsrcAdata[23];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowFlg_ADDRS)  && ~Ind_Dest_q2) overflow_flag <= wrsrcAdata[2] ? 1'b0 : overflow_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razFlg_ADDRS)  && ~Ind_Dest_q2) overflow_flag <= wrsrcAdata[2] ? 1'b1 : overflow_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==rstrFlg_ADDRS) && ~Ind_Dest_q2) overflow_flag <= (wrsrcAdata[2] && wrsrcBdata[2]);                                                                  
       else if (overflow_q2 && ~enAltImmOverflowHandl && ~razNoOverflowFlag && rd_float_q2_sel && q2_sel) overflow_flag <= 1'b1;

       if (Status_wren) divby0_flag <= wrsrcAdata[22];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowFlg_ADDRS)  && ~Ind_Dest_q2) divby0_flag <= wrsrcAdata[1] ? 1'b0 : divby0_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razFlg_ADDRS)  && ~Ind_Dest_q2) divby0_flag <= wrsrcAdata[1] ? 1'b1 : divby0_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==rstrFlg_ADDRS) && ~Ind_Dest_q2) divby0_flag <= (wrsrcAdata[1] && wrsrcBdata[1]);                                                                  
       else if (divby0_q2 && ~enAltImmDivByZeroHandl && ~razNoDivByZeroFlag && rd_float_q2_sel && q2_sel) divby0_flag <= 1'b1;

       if (Status_wren) invalid_flag <= wrsrcAdata[21];                                 
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowFlg_ADDRS)  && ~Ind_Dest_q2) invalid_flag <= wrsrcAdata[0] ? 1'b0 : invalid_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razFlg_ADDRS)  && ~Ind_Dest_q2) invalid_flag <= wrsrcAdata[0] ? 1'b1 : invalid_flag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==rstrFlg_ADDRS) && ~Ind_Dest_q2) invalid_flag <= (wrsrcAdata[0] && wrsrcBdata[0]);                                                                  
       else if ((invalid_q2 && ~enAltImmInvalidHandl && ~razNoInvalidFlag && rd_float_q2_sel && q2_sel) || (cmprInvalid && ~enAltImmInvalidHandl && ~razNoInvalidFlag)) invalid_flag <= 1'b1; 

//these next five bits are "signals"
       if (Status_wren) inexact_signal <= wrsrcAdata[20];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowSig_ADDRS) && ~Ind_Dest_q2) inexact_signal <= wrsrcAdata[4] ? 1'b0 : inexact_signal;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razSig_ADDRS) && ~Ind_Dest_q2) inexact_signal <= wrsrcAdata[4] ? 1'b1 : inexact_signal;                                                                  
       else if (inexact_q2 && rd_float_q2_sel && q2_sel && (enAltImmInexactHandl || razNoInexactFlag)) inexact_signal <= 1'b1;

       if (Status_wren) underflow_signal <= wrsrcAdata[19];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowSig_ADDRS) && ~Ind_Dest_q2) underflow_signal <= wrsrcAdata[3] ? 1'b0 : underflow_signal;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razSig_ADDRS) && ~Ind_Dest_q2) underflow_signal <= wrsrcAdata[3] ? 1'b1 : underflow_signal;                                                                  
       else if (underflow_q2 && rd_float_q2_sel && q2_sel && (enAltImmUnderflowHandl || razNoUnderflowFlag)) underflow_signal <= 1'b1;

       if (Status_wren) overflow_signal <= wrsrcAdata[18];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowSig_ADDRS) && ~Ind_Dest_q2) overflow_signal <= wrsrcAdata[2] ? 1'b0 : overflow_signal;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razSig_ADDRS) && ~Ind_Dest_q2) overflow_signal <= wrsrcAdata[2] ? 1'b1 : overflow_signal;                                                                  
       else if (overflow_q2 && rd_float_q2_sel && q2_sel && (enAltImmOverflowHandl || razNoOverflowFlag)) overflow_signal <= 1'b1;

       if ( Status_wren) divby0_signal <= wrsrcAdata[17];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowSig_ADDRS) && ~Ind_Dest_q2) divby0_signal <= wrsrcAdata[1] ? 1'b0 : divby0_signal;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razSig_ADDRS) && ~Ind_Dest_q2) divby0_signal <= wrsrcAdata[1] ? 1'b1 : divby0_signal;                                                                  
       else if (divby0_q2 && rd_float_q2_sel && q2_sel && (enAltImmDivByZeroHandl || razNoDivByZeroFlag)) divby0_signal <= 1'b1;

       if (Status_wren) invalid_signal <= wrsrcAdata[16];                                 
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowSig_ADDRS) && ~Ind_Dest_q2) invalid_signal <= wrsrcAdata[0] ? 1'b0 : invalid_signal;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razSig_ADDRS) && ~Ind_Dest_q2) invalid_signal <= wrsrcAdata[0] ? 1'b1 : invalid_signal;                                                                  
       else if (((invalid_q2 && rd_float_q2_sel && q2_sel) || cmprInvalid) && (enAltImmInvalidHandl || razNoInvalidFlag)) invalid_signal <= 1'b1;                                                                                                                                                           
                                                                                                                                                          
//alternate Immediate Handler enables    
       if (Status_wren) enAltImmInexactHandl <= wrsrcAdata[35];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmInexactHandl <= wrsrcAdata[4] ? 1'b0 : enAltImmInexactHandl;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmInexactHandl <= wrsrcAdata[4] ? 1'b1 : enAltImmInexactHandl;                                                                  
 
       if (Status_wren) enAltImmUnderflowHandl <= wrsrcAdata[34];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmUnderflowHandl <= wrsrcAdata[3] ? 1'b0 : enAltImmUnderflowHandl;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmUnderflowHandl <= wrsrcAdata[3] ? 1'b1 : enAltImmUnderflowHandl;                                                                  
 
       if (Status_wren) enAltImmOverflowHandl <= wrsrcAdata[33];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmOverflowHandl <= wrsrcAdata[2] ? 1'b0 : enAltImmOverflowHandl;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmOverflowHandl <= wrsrcAdata[2] ? 1'b1 : enAltImmOverflowHandl;                                                                  
 
       if (Status_wren) enAltImmDivByZeroHandl <= wrsrcAdata[32];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmDivByZeroHandl <= wrsrcAdata[1] ? 1'b0 : enAltImmDivByZeroHandl;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmDivByZeroHandl <= wrsrcAdata[1] ? 1'b1 : enAltImmDivByZeroHandl;                                                                  
 
       if (Status_wren) enAltImmInvalidHandl <= wrsrcAdata[31];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmInvalidHandl <= wrsrcAdata[0] ? 1'b0 : enAltImmInvalidHandl;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setAltImm_ADDRS) && ~Ind_Dest_q2) enAltImmInvalidHandl <= wrsrcAdata[0] ? 1'b1 : enAltImmInvalidHandl;                                                                  

//Raise No Flag
       if (Status_wren) razNoInexactFlag <= wrsrcAdata[30];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowNoFlag_ADDRS) && ~Ind_Dest_q2) razNoInexactFlag <= wrsrcAdata[4] ? 1'b0 : razNoInexactFlag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razNoFlag_ADDRS) && ~Ind_Dest_q2) razNoInexactFlag <= wrsrcAdata[4] ? 1'b1 : razNoInexactFlag;                                                                  
                                                                                                                                                                
       if (Status_wren) razNoUnderflowFlag <= wrsrcAdata[29];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowNoFlag_ADDRS) && ~Ind_Dest_q2) razNoUnderflowFlag <= wrsrcAdata[3] ? 1'b0 : razNoUnderflowFlag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razNoFlag_ADDRS) && ~Ind_Dest_q2) razNoUnderflowFlag <= wrsrcAdata[3] ? 1'b1 : razNoUnderflowFlag;                                                                  

       if (Status_wren) razNoOverflowFlag <= wrsrcAdata[28];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowNoFlag_ADDRS) && ~Ind_Dest_q2) razNoOverflowFlag <= wrsrcAdata[2] ? 1'b0 : razNoOverflowFlag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razNoFlag_ADDRS) && ~Ind_Dest_q2) razNoOverflowFlag <= wrsrcAdata[2] ? 1'b1 : razNoOverflowFlag;                                                                  

       if (Status_wren) razNoDivByZeroFlag <= wrsrcAdata[27];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowNoFlag_ADDRS) && ~Ind_Dest_q2) razNoDivByZeroFlag <= wrsrcAdata[1] ? 1'b0 : razNoDivByZeroFlag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razNoFlag_ADDRS) && ~Ind_Dest_q2) razNoDivByZeroFlag <= wrsrcAdata[1] ? 1'b1 : razNoDivByZeroFlag;                                                                  

       if (Status_wren) razNoInvalidFlag <= wrsrcAdata[26];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==lowNoFlag_ADDRS) && ~Ind_Dest_q2) razNoInvalidFlag <= wrsrcAdata[0] ? 1'b0 : razNoInvalidFlag;                                                                  
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==razNoFlag_ADDRS) && ~Ind_Dest_q2) razNoInvalidFlag <= wrsrcAdata[0] ? 1'b1 : razNoInvalidFlag;                                                                  

//"is(es)" 
       if (Status_wren) isTrue <= wrsrcAdata[49];
       else if (wrcycl && q2_sel && ~Ind_Dest_q2 ) 
            case(opAddrs_q2) 
                isCanonical : isTrue <= X_Canonical;
                isSignaling : isTrue <= X_Signaling;
                isNaN       : isTrue <= X_NaN;
                isInfinite  : isTrue <= X_Infinite;
                isSubnormal : isTrue <= X_Subnormal;
                isZero      : isTrue <= X_Zero;
                isFinite    : isTrue <= X_Finite;
                isNormal    : isTrue <= X_Normal;
                isSignMinus : isTrue <= X_SignMinus;
            endcase                
       
//class                                                                 
       if (Status_wren) begin                                           
              positiveInfinity  <= wrsrcAdata[45];                      
              positiveNormal    <= wrsrcAdata[44];                      
              positiveSubnormal <= wrsrcAdata[43];                      
              positiveZero      <= wrsrcAdata[42];                      
              negativeZero      <= wrsrcAdata[41];                      
              negativeSubnormal <= wrsrcAdata[40];                      
              negativeNormal    <= wrsrcAdata[39];                      
              negativeInfinity  <= wrsrcAdata[38];                                           
              quietNaN          <= wrsrcAdata[37];
              signalingNaN      <= wrsrcAdata[36];       
       end               
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clas_ADDRS) && ~Ind_Dest_q2) begin      
              positiveInfinity  <= X_positiveInfinity  ;
              positiveNormal    <= X_positiveNormal    ;
              positiveSubnormal <= X_positiveSubnormal ;
              positiveZero      <= X_positiveZero      ;
              negativeZero      <= X_negativeZero      ;
              negativeSubnormal <= X_negativeSubnormal ;
              negativeNormal    <= X_negativeNormal    ;
              negativeInfinity  <= X_negativeInfinity  ;                                           
              quietNaN          <= X_quietNaN          ;                                   
              signalingNaN      <= X_signalingNaN      ;                                                      
       end

       if (Status_wren) totlOrder <= wrsrcAdata[46]; 
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==tOrd_ADDRS) && ~Ind_Dest_q2) totlOrder <= _totlOrder;
       
       if (Status_wren) totlOrderMag <= wrsrcAdata[47]; 
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==tOrdM_ADDRS) && ~Ind_Dest_q2) totlOrderMag <= _totlOrderMag;      
                                                        
       if (Status_wren) compareTrue <= wrsrcAdata[50]; 
       else if (wrcycl && q2_sel && ~Ind_Dest_q2 && cmprEnable) compareTrue <= _compareTrue;  
       
       if (Status_wren) aFlagRaised <= wrsrcAdata[48];       
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==tstFlg_ADDRS) && ~Ind_Dest_q2) aFlagRaised <= _aFlagRaised;      
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==tstSavFlg_ADDRS) && ~Ind_Dest_q2) aFlagRaised <= _aSFlagRaised;      

//this handles SetBinRndDir, DefaultModes, RestoreModes
       if (Status_wren) {DEF_ONLY, AWAY, RM_ATR_EN, RM1, RM0} <= wrsrcAdata[55:51]; //ordinary writes to STATUS
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==sgtRnDir_ADDRS)  && ~Ind_Dest_q2) {AWAY, RM_ATR_EN, RM1, RM0} <= wrsrcAdata[3:0]; //writes to just the RMode  bits  (write 4'b0000 to restore defaults)
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==deflt_ADDRS)     && ~Ind_Dest_q2) DEF_ONLY <= wrsrcAdata[0];    // DEF_ONLY (default mode only) overrides RM bits without changing them  

// neural network activation mode bits [14:11] of STATUS register
       if (Status_wren) {ACTM[3:0]} <= wrsrcAdata[14:11]; //ordinary writes to STATUS
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==actMode_ADDRS)  && ~Ind_Dest_q2) ACTM[3:0] <=  wrsrcAdata[3:0];
       
//integer & logical status bits
       if (Status_wren) {IRQ_IE, done, V, N, C, Z} <=  wrsrcAdata[5:0];
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==compare_ADDRS) && ~Ind_Dest_q2) begin  //compare presently only affects Z and V flags
          Z <= (compareAdata==compareBdata);
          V <= (compareAdata < compareBdata);
       end
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==setDVNCZ_ADDRS) && ~Ind_Dest_q2)
          {IRQ_IE,
           done, 
           V,       
           N,       
           C,       
           Z} <= {(wrsrcAdata[5] ? 1'b1 : IRQ_IE),
                  (wrsrcAdata[4] ? 1'b1 : done),
                  (wrsrcAdata[3] ? 1'b1 : V),
                  (wrsrcAdata[2] ? 1'b1 : N),
                  (wrsrcAdata[1] ? 1'b1 : C),
                  (wrsrcAdata[0] ? 1'b1 : Z)};
       else if (wrcycl && q2_sel && (OPdest_q2[14:0]==clrDVNCZ_ADDRS) && ~Ind_Dest_q2)
          {IRQ_IE,
           done, 
           V,       
           N,       
           C,       
           Z} <= {(wrsrcAdata[5] ? 1'b0 : IRQ_IE),
                  (wrsrcAdata[4] ? 1'b0 : done),
                  (wrsrcAdata[3] ? 1'b0 : V),
                  (wrsrcAdata[2] ? 1'b0 : N),
                  (wrsrcAdata[1] ? 1'b0 : C),
                  (wrsrcAdata[0] ? 1'b0 : Z)};
       else if (wrcycl && q2_sel && rd_integr_q2_sel) {V, N, C, Z} <= {V_q2, N_q2, C_q2, Z_q2};
              
    end  
 end  
    
  endmodule

