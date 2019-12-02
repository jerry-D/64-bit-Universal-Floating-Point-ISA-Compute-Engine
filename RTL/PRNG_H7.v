// PRNG_H7.v
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

module PRNG_H7 (
    CLK,
    RESET,
    rden,
    wren,
    wrdata,
    rddata,
    SigA,
    SizeA,
    ready
    );
input CLK;
input RESET;
input rden;
input wren;
input [7:0] wrdata;   //writing a 0x00 to the generater shuts it down
output [63:0] rddata;
input SigA;
input [1:0] SizeA;   // only the two LSBs are used here
output ready;

// Range Select codes 

//    45 : < +100   all positive
//    44 : < +75.0
//    43 : < +50.0
//    42 : < +25.0 
//    41 : < +10.0       
//    40 : <  +7.5      
//    39 : <  +5.0                        
//    38 : <  +3.5 
//    37 : <  +2.0 
//    36 : <  +1.75
//    35 : <  +1.50
//    34 : <  +1.250 
//    33 : <  +1.0 
//    32 : <  +0.75                      
//    31 : <  +0.50                       
//    30 : <  +0.35 
//    29 : <  +0.20 
//    28 : <  +0.175
//    27 : <  +0.150                      
//    26 : <  +0.125 
//    25 : <  +0.10
//    24 : <  +0.075                       
//    23 : <  +0.05                       
//    22 : <  +0.035 
//    21 : <  +0.020                      
//    20 : <  +0.0175                     
//    19 : <  +0.0150                     
//    18 : <  +0.0125
//    17 : <  +0.01                       
//    16 : <  +0.0075  
//    15 : <  +0.005  
//    14 : <  +0.0035 
//    13 : <  +0.0020 
//    12 : <  +0.00175                    
//    11 : <  +0.0015                    
//    10 : <  +0.00125
//     9 : <  +0.001                       
//     8 : <  +0.00075  
//     7 : <  +0.0005  
//     6 : <  +0.00035 
//     5 : <  +0.00020 
//     4 : <  +0.000175                    
//     3 : <  +0.00015                    
//     2 : <  +0.000125
//     1 : <  +0.0001
//     0 : suspend                       
                                                         
//    109 : > -100    all negative
//    108 : > -75.0
//    107 : > -50.0
//    106 : > -25.0 
//    105 : > -10.0       
//    104 : >  -7.5      
//    103 : >  -5.0                        
//    103 : >  -3.5 
//    101 : >  -2.0 
//    100 : >  -1.75
//     99 : >  -1.50
//     98 : >  -1.250 
//     97 : >  -1.0 
//     96 : >  -0.75                      
//     95 : >  -0.50                       
//     94 : >  -0.35 
//     93 : >  -0.20 
//     92 : >  -0.175
//     91 : >  -0.150                      
//     90 : >  -0.125 
//     89 : >  -0.10
//     88 : >  -0.075                       
//     87 : >  -0.05                       
//     86 : >  -0.035 
//     85 : >  -0.020                      
//     84 : >  -0.0175                     
//     83 : >  -0.0150                     
//     82 : >  -0.0125
//     81 : >  -0.01                       
//     80 : >  -0.0075  
//     79 : >  -0.005  
//     78 : >  -0.0035 
//     77 : >  -0.0020 
//     76 : >  -0.00175                    
//     75 : >  -0.0015                    
//     74 : >  -0.00125
//     73 : >  -0.001                       
//     72 : >  -0.00075  
//     71 : >  -0.0005  
//     70 : >  -0.00035 
//     69 : >  -0.00020 
//     68 : >  -0.000175                    
//     67 : >  -0.00015                    
//     66 : >  -0.000125
//     65 : >  -0.0001
//      0 : suspend                       

//    173 : > -100    randomly positive or negative
//    172 : > -75.0
//    171 : > -50.0
//    170 : > -25.0 
//    169 : > -10.0       
//    168 : >  -7.5      
//    167 : >  -5.0                        
//    166 : >  -3.5 
//    165 : >  -2.0 
//    164 : >  -1.75
//    163 : >  -1.50
//    162 : >  -1.250 
//    161 : >  -1.0 
//    160 : >  -0.75                      
//    159 : >  -0.50                       
//    158 : >  -0.35 
//    157 : >  -0.20 
//    156 : >  -0.175
//    155 : >  -0.150                      
//    154 : >  -0.125 
//    153 : >  -0.10
//    152 : >  -0.075                       
//    151 : >  -0.05                       
//    150 : >  -0.035 
//    149 : >  -0.020                      
//    148 : >  -0.0175                     
//    147 : >  -0.0150                     
//    146 : >  -0.0125
//    145 : >  -0.01                       
//    144 : >  -0.0075  
//    143 : >  -0.005  
//    142 : >  -0.0035 
//    141 : >  -0.0020 
//    140 : >  -0.00175                    
//    139 : >  -0.0015                    
//    138 : >  -0.00125
//    137 : >  -0.001                       
//    136 : >  -0.00075  
//    135 : >  -0.0005  
//    134 : >  -0.00035 
//    133 : >  -0.00020 
//    132 : >  -0.000175                    
//    131 : >  -0.00015                    
//    130 : >  -0.000125
//    129 : >  -0.0001
//     0 : suspend                       

reg [27:1] LFSR;
reg [12:1] LFSR_SGN;
reg [7:0] range_sel;
reg [63:0] PRNG_DCS8;
reg [15:0] divisr; 
reg [63:0] rddata;     
reg ready_q1, 
    ready_q2,
    ready_q3,
    ready_q4,
    ready_q5,
    ready_q6,
    ready_q7,
    ready_q8,
    ready_q9,
    ready_q10,
    ready_q11,
    ready_q12,
    ready_q13,
    ready_q14,
    ready_q15,
    ready_q16,
    ready_q17,
    ready_q18,
    ready_q19;

wire ready;
wire [7:0] EXP8;
wire [10:0] EXP11;
wire [15:0] Rdiv;      
wire sign;
wire [1:0] sign_sel;
wire [5:0] range;
wire [15:0] bin78out;
wire enable;
wire [2:0] GRSout;
wire [63:0] ascOut;
wire [3:0] decDigit8;
wire [3:0] decDigit7;
wire [3:0] decDigit6;
wire [3:0] decDigit5;
wire [3:0] decDigit4;
wire [3:0] decDigit3;
wire [3:0] decDigit2;
wire [3:0] decDigit1;
wire [3:0] decDigit0;

assign sign = LFSR_SGN[11];
assign sign_sel = range_sel[7:6];
assign range = range_sel[5:0];
assign EXP8 = Rdiv[14:8]+64;
assign EXP11 = Rdiv[14:8]+960;
assign ready = rden ? ready_q16 : 1'b1;   //for reciprocal multiply
assign enable = |range_sel[7:0];

always @(posedge CLK)
    if (RESET) range_sel <= 8'D33;     // +1.0
    else if (wren) range_sel <= wrdata[7:0];  //wrdata == 0x00 suspends generation

always @(posedge CLK) begin
    if (RESET) begin
        LFSR <= 27'h060D_FEED;
        LFSR_SGN <= 12'h947;
    end    
    else if (enable) begin
        LFSR[27:1] <= {LFSR[1], LFSR[27] ^ LFSR[1], LFSR[26] ^ LFSR[1], LFSR[25] ^ LFSR[1], LFSR[24:23], LFSR[22] ^ LFSR[1], LFSR[21:2]}; 
         LFSR_SGN[12:1] <= {LFSR_SGN[1], LFSR_SGN[12] ^ LFSR_SGN[1], LFSR_SGN[11] ^ LFSR_SGN[1], LFSR_SGN[10:9], LFSR_SGN[8] ^ LFSR_SGN[1], LFSR_SGN[7], LFSR_SGN[6] ^ LFSR_SGN[1], LFSR_SGN[5:2]};

    end
end

binToBCD27 bcd(            // 3 clocks
    .RESET    (RESET    ),
    .CLK      (CLK      ),
    .binIn    (LFSR     ),
    .decDigit8(decDigit8),
    .decDigit7(decDigit7),
    .decDigit6(decDigit6),
    .decDigit5(decDigit5),
    .decDigit4(decDigit4),
    .decDigit3(decDigit3),
    .decDigit2(decDigit2),
    .decDigit1(decDigit1),
    .decDigit0(decDigit0)
    );
    
always @(posedge CLK)
    if (RESET) PRNG_DCS8 <= {8{"0"}};
    else if (sign_sel==2'b00) PRNG_DCS8 <= {4'h3, decDigit7, 4'h3, decDigit6, ".", 4'h3, decDigit5, 4'h3, decDigit4, 4'h3, decDigit3, 4'h3, decDigit2, 4'h3, decDigit1}; // +
    else if (sign_sel==2'b01) PRNG_DCS8 <= {"-", 4'h3, decDigit7, 4'h3, decDigit6, ".", 4'h3, decDigit5, 4'h3, decDigit4, 4'h3, decDigit3, 4'h3, decDigit2};             // -
    else  PRNG_DCS8 <= sign ? {"-", 4'h3, decDigit7, 4'h3, decDigit6, ".", 4'h3, decDigit5, 4'h3, decDigit4, 4'h3, decDigit3, 4'h3, decDigit2}                           // randomly + or -
                            : {4'h3, decDigit7, 4'h3, decDigit6, ".", 4'h3, decDigit5, 4'h3, decDigit4, 4'h3, decDigit3, 4'h3, decDigit2, 4'h3, decDigit1};

decCharToBinH8 DCStoBinH8_in(    // 6 clocks
    .RESET (RESET ),
    .CLK   (CLK   ),
    .wren  (1'b1  ),
    .wrdata(PRNG_DCS8),
    .binOut(bin78out),
    .GRS ()
    );

always @(*) 
    case(range)                      // reciprocal      yields
        6'd45 : divisr = 16'h3F00;   //    1          : < 100         
        6'd44 : divisr = 16'h3E80;   //    0.75       : < 75.0        
        6'd43 : divisr = 16'h3E00;   //    0.5        : < 50.0        
        6'd42 : divisr = 16'h3D00;   //    0.25       : < 25.0        
        6'd41 : divisr = 16'h3B99;   //    0.1        : < 10.0        
        6'd40 : divisr = 16'h3B33;   //    0.075      : <  7.5        
        6'd39 : divisr = 16'h3A99;   //    0.05       : <  5.0        
        6'd38 : divisr = 16'h3A1E;   //    0.035      : <  3.5        
        6'd37 : divisr = 16'h3947;   //    0.02       : <  2.0        
        6'd36 : divisr = 16'h391E;   //    0.0175     : <  1.75       
        6'd35 : divisr = 16'h38EB;   //    0.015      : <  1.50       
        6'd34 : divisr = 16'h3899;   //    0.0125     : <  1.250      
        6'd33 : divisr = 16'h3847;   //    0.01       : <  1.0        
        6'd32 : divisr = 16'h37EB;   //    0.0075     : <  0.75       
        6'd31 : divisr = 16'h3747;   //    0.005      : <  0.50       
        6'd30 : divisr = 16'h36CA;   //    0.0035     : <  0.35       
        6'd29 : divisr = 16'h3606;   //    0.002      : <  0.20       
        6'd28 : divisr = 16'h35CA;   //    0.00175    : <  0.175      
        6'd27 : divisr = 16'h3589;   //    0.0015     : <  0.150      
        6'd26 : divisr = 16'h3547;   //    0.00125    : <  0.125      
        6'd25 : divisr = 16'h3506;   //    0.001      : <  0.10       
        6'd24 : divisr = 16'h3489;   //    0.00075    : <  0.075      
        6'd23 : divisr = 16'h3406;   //    0.0005     : <  0.05       
        6'd22 : divisr = 16'h336F;   //    0.00035    : <  0.035   
        6'd21 : divisr = 16'h32A3;   //    0.0002     : <  0.020   
        6'd20 : divisr = 16'h326F;   //    0.000175   : <  0.0175  
        6'd19 : divisr = 16'h323A;   //    0.00015    : <  0.0150  
        6'd18 : divisr = 16'h3206;   //    0.000125   : <  0.0125  
        6'd17 : divisr = 16'h31A3;   //    0.0001     : <  0.01    
        6'd16 : divisr = 16'h313A;   //    0.000075   : <  0.0075  
        6'd15 : divisr = 16'h30A3;   //    0.00005    : <  0.005   
        6'd14 : divisr = 16'h3025;   //    0.000035   : <  0.0035  
        6'd13 : divisr = 16'h2F4F;   //    0.00002    : <  0.0020  
        6'd12 : divisr = 16'h2F25;   //    0.0000175  : <  0.00175 
        6'd11 : divisr = 16'h2EF7;   //    0.000015   : <  0.0015  
        6'd10 : divisr = 16'h2EA3;   //    0.0000125  : <  0.00125 
        6'd09 : divisr = 16'h2E4F;   //    0.00001    : <  0.001   
        6'd08 : divisr = 16'h2DF7;   //    0.0000075  : <  0.00075 
        6'd07 : divisr = 16'h2D4F;   //    0.000005   : <  0.0005  
        6'd06 : divisr = 16'h2CD5;   //    0.0000035  : <  0.00035 
        6'd05 : divisr = 16'h2C0C;   //    0.000002   : <  0.00020 
        6'd04 : divisr = 16'h2BD5;   //    0.00000175 : <  0.000175
        6'd03 : divisr = 16'h2B92;   //    0.0000015  : <  0.00015 
        6'd02 : divisr = 16'h2B4F;   //    0.00000125 : <  0.000125
        6'd01 : divisr = 16'h2B0C;   //    0.000001   : <  0.0001  
      default : divisr = 16'h3847;   // div x 100 
    endcase  
                     
FMUL711 fmul(        // 1 clock
    .CLK(CLK),
    .A(bin78out),  
    .GRSinA(3'b0),
    .B(divisr),     //recirocal
    .GRSinB(3'b0),
    .R(Rdiv),
    .GRSout(GRSout),
    .except()
    );

binToDecCharH8 binToDec(   //6 clocks
    .RESET (RESET),
    .CLK   (CLK  ),
    .wren  (1'b1 ),
    .wrdata(Rdiv ),
    .ascOut(ascOut)
    );  
     
always @(*)
    case(SizeA)
        2'b00,
        2'b01 : rddata = {48'b0, Rdiv[15], EXP8, Rdiv[7:1]};
        2'b10 : rddata = {32'b0, Rdiv[15], EXP8, Rdiv[7:0], GRSout, 12'b0};
        2'b11 : rddata = SigA ? ascOut : {Rdiv[15], EXP11, Rdiv[7:0], GRSout, 41'b0};
    endcase

always @(posedge CLK)
    if(RESET) begin
        ready_q1  <= 0;
        ready_q2  <= 0;
        ready_q3  <= 0;
        ready_q4  <= 0;
        ready_q5  <= 0;
        ready_q6  <= 0;
        ready_q7  <= 0;
        ready_q8  <= 0;
        ready_q9  <= 0;
        ready_q10 <= 0;
        ready_q11 <= 0;
        ready_q12 <= 0;
        ready_q13 <= 0;
        ready_q14 <= 0;
        ready_q15 <= 0;
        ready_q16 <= 0;    
    end
    else begin
        ready_q1  <= ~wren;
        ready_q2  <= ready_q1 && ~wren;
        ready_q3  <= ready_q2 && ~wren;
        ready_q4  <= ready_q3 && ~wren;
        ready_q5  <= ready_q4 && ~wren;
        ready_q6  <= ready_q5 && ~wren;
        ready_q7  <= ready_q6 && ~wren;
        ready_q8  <= ready_q7 && ~wren;
        ready_q9  <= ready_q8 && ~wren;
        ready_q10 <= ready_q9 && ~wren;
        ready_q11 <= ready_q10 && ~wren;
        ready_q12 <= ready_q11 && ~wren;
        ready_q13 <= ready_q12 && ~wren;
        ready_q14 <= ready_q13 && ~wren;
        ready_q15 <= ready_q14 && ~wren;
        ready_q16 <= ready_q15 && ~wren;
    end

endmodule                              
                                       
                                       
                                       
                                       