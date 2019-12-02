// symplSOB_tb.v
//
// Example testbench for SYMPL 64-Bit Universal Floating-point ISA Compute Engine and Fused Universal Neural Network (FuNN) eNNgine
//
// Author:  Jerry D. Harthcock
// Version:  1.21  November 28, 2019
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
// with said academic pursuit and under the supervision of said university or institution of higher education.        //                                                                           //            
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

module symplSOB_tb();

//Some SOB internal register addresses accessed by this test bench
parameter PRNG_ADDRS = 32'h00007FF0;  //SOB Pseudo-Random Number Generator address
parameter AR4_ADDRS  = 32'h00007FFB;  //SOB Auxiliary Register 4 address
parameter AR1_ADDRS  = 32'h00007FF8;  //SOB Auxiliary Register 1 address
parameter AR0_ADDRS  = 32'h00007FF7;  //SOB Auxiliary Register 0 address
parameter PC_ADDRS   = 32'h00007FF5;  //SOB Program Counter address
parameter SOB_MON_ADDRS = 32'h00007FEB;

//JTAG-accessible debugger register addresses for access via JTAG debug port    
parameter JTAG_mon_read_addrs_addrs  = 8'h20;
parameter JTAG_mon_write_addrs_addrs = 8'h21;
parameter JTAG_mon_write_reg_addrs   = 8'h22; 
parameter JTAG_mon_read_reg_addrs    = 8'h23;
parameter JTAG_evnt_cntr_addrs       = 8'h24;   
parameter JTAG_trigger_A_addrs       = 8'h25;
parameter JTAG_trigger_B_addrs       = 8'h26;
parameter JTAG_brk_cntrl_addrs       = 8'h27;
parameter JTAG_brk_status_addrs      = 8'h28;
parameter JTAG_trace_newest_addrs    = 8'h30;
parameter JTAG_trace_1_addrs         = 8'h31;
parameter JTAG_trace_2_addrs         = 8'h32;
parameter JTAG_trace_oldest_addrs    = 8'h33;
parameter JTAG_bypass                = 8'hFF;

//brk_cntrl_reg bit identifiers
parameter JTAG_DEBUG_en      = 6'h09;        //this bit must be set=1 for the other enables here to have any effect
parameter JTAG_PC_EQ_BRKA_en = 6'h08;        //when JTAG_DEBUG_en is set, Host CPU debug transactions will be ignored
parameter JTAG_PC_EQ_BRKB_en = 6'h07;        //when done using the JTAG_DEBUG path, clear JTAG_DEBUG_en to re-enable Host CPU debug access
parameter JTAG_PC_GT_BRKA_en = 6'h06;
parameter JTAG_PC_LT_BRKB_en = 6'h05;
parameter JTAG_PC_AND_en     = 6'h04;
parameter JTAG_mon_req       = 6'h03;
parameter JTAG_sstep         = 6'h02;
parameter JTAG_frc_brk       = 6'h01;
parameter JTAG_frc_rst       = 6'h00;

//brk_status_reg bit identifiers
parameter JTAG_skip_cmplt    = 6'h05;
parameter JTAG_swbreakDetect = 6'h04;
parameter JTAG_broke         = 6'h03;
parameter JTAG_FRCE_BREAK    = 6'h02;
parameter JTAG_RESET_IN      = 6'h01;
parameter JTAG_FRCE_RESET    = 6'h00;
                               
parameter byte  = 3'b000;      
parameter hword = 3'b001;      
parameter word  = 3'b010;
parameter dword = 3'b011;

integer i, p, r, file;
integer clk_high_time;                       // high time for CPU clock  
integer tck_high_time;                       // high time for JTAG clock
integer tck_period;
integer bit_ptr, dr_width, ir_width;         // bit pointer of data to be scanned 
integer j, k;

reg clk;
reg reset;

reg [63:0] ProgBuff64[16383:0];       //64-bit memory initially loaded with "<prog>.hex" file
reg [1031:0] fatBuff_mem1032[255:0];  //1032-bit x 256 deep memory (1032 bits instead of 1024) because of LF character in the file
reg [1023:0] reform;                  //fat read register
reg [63:0] captureReadData;
reg ready_q1;
reg IRQ;
reg [8:0] x;
reg [5:0] objNo;

reg [63:0] JTAG_out_value, JTAG_in_value;              // JTAG data register out_value
reg [7:0]  JTAG_instr;

reg TCK;     
reg TMS;
reg TDI;
reg TRSTn;
   
reg [31:0] HOST_wraddrs;
reg [31:0] HOST_rdaddrs;
reg [2:0]  HOST_wrsize;
reg [2:0]  HOST_rdsize;
reg        HOST_wren;
reg        HOST_rden;

reg [63:0] JTAG_debug_rd_data;
reg [63:0] JTAG_brk_cntrl_reg;
reg [31:0] JTAG_triggerA;
reg [31:0] JTAG_triggerB;
reg [63:0] JTAG_monitor_rd_data;

wire TDO;
wire all_done;

wire done;
wire event_det;

assign all_done = done;
assign (pull1, pull0) TDO  = 1'b1;

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
   wire [13:0] Aq;    
   wire [63:0] DQ;    
   wire OE;
   
   //bi-directional databus between CPU and synchronous SRAM
   assign (pull1, pull0) DQ = 64'hFFFF_FFFF_FFFF_FFFF; 
   assign Aq = A[16:3]; 
`else
`endif      
            
`ifdef  SOB_has_Fat_Bus       //for access sizes of 1, 2, 4, 8, 16, 32, 64, and 128 bytes
reg [1023:0] HOST_wrdata;     //this will not successfully place/route in smaller devices due to number of IOBs required
wire [1023:0] HOST_rddata;
`else
reg [63:0] HOST_wrdata;       //for access sizes of 1, 2, 4, 8 bytes only
wire [63:0] HOST_rddata;      //this will place/route successfully
`endif

`ifdef SOB_has_external_SRAM
//GSI Technology NBT (No Bus Turn Around) Flow Through Mode Synchronous x64-Bit SRAM (GSI8320ZxxAGT)
RAM64_byte #(.ADDRS_WIDTH(14)) sysMem( //14-bit address by 8 bytes = 16k x 8 bytes = 128k bytes  (can be increased to 4M Bytes)
    .CLK    (clk    ),
    .CEN    (CEN    ),       //clock enable active low
    .CE123  (CE123  ),       //chip enable active high
    .WE     (WE     ),       //active low write enable
    .BWh    (BWh    ),       //active low
    .BWg    (BWg    ),       //active low
    .BWf    (BWf    ),       //active low
    .BWe    (BWe    ),       //active low
    .BWd    (BWd    ),       //active low
    .BWc    (BWc    ),       //active low
    .BWb    (BWb    ),       //active low
    .BWa    (BWa    ),       //active low
    .adv_LD (adv_LD ),       //advance/load
    .A      (Aq     ),       //(dword) address
    .DQ     (DQ     ),       //data in/out (three-state)
    .OE     (OE     )        //active low output enable
);    
`else
`endif   
         
SOB DUT(
    .CLK     (clk   ),
    .RESET_IN(reset),
    .HTCK    (TCK   ),
    .HTRSTn  (TRSTn ),
    .HTMS    (TMS   ),
    .HTDI    (TDI   ),
    .HTDO    (TDO   ),
    
`ifdef SOB_has_external_SRAM
    .CEN     (CEN   ),
    .CE123   (CE123 ),
    .WE      (WE    ),
    .BWh     (BWh   ),
    .BWg     (BWg   ),
    .BWf     (BWf   ),
    .BWe     (BWe   ),
    .BWd     (BWd   ),
    .BWc     (BWc   ),
    .BWb     (BWb   ),
    .BWa     (BWa   ),
    .adv_LD  (adv_LD),
    .A       (A     ),
    .DQ      (DQ    ),
    .OE      (OE    ),
`else
`endif
                      
    .ready_q1(ready_q1),
    
    .done    (done  ),
    
    .IRQ     (IRQ   ),
    .event_det(event_det),
    
    .HOST_wren   (HOST_wren   ),       //These are the host interface signals that access the SOB on-chip HOST real-time monitor/debug port and 5-port buffer memory
    .HOST_rden   (HOST_rden   ),       //The 5-port buffer memory is 64k bytes and can be accessed in sizes of 1, 2, 4, 8 bytes (default) and if defined, 16, 32, 64, and 128 bytes 
    .HOST_wrSize (HOST_wrsize ),
    .HOST_rdSize (HOST_rdsize ),
    .HOST_wraddrs(HOST_wraddrs[15:0]),
    .HOST_rdaddrs(HOST_rdaddrs[15:0]),
    .HOST_wrdata (HOST_wrdata),
    .HOST_rddata (HOST_rddata )
    );


   initial begin
        clk = 0;
        reset = 1;
        clk_high_time = 5;
        tck_high_time = 2;
        tck_period = 4;
        ir_width = 8;
        dr_width = 64;
        
        TDI     = 1'b1;
        TMS     = 1'b1;
        TCK = 1'b0;
        TRSTn = 1'b0;
                  
        ready_q1       = 1'b1;
        
        IRQ        = 1'b0;
        
        JTAG_brk_cntrl_reg  = 64'h0000_0000_0000_0000;
        JTAG_debug_rd_data  = 64'h0000_0000_0000_0000;
        JTAG_triggerA   = 32'b0;
        JTAG_triggerB   = 32'b0;
        
        captureReadData = 0;

        HOST_wrdata  = 0;
        HOST_wraddrs = 0;
        HOST_rdaddrs = 0;
        HOST_wrsize  = 3;
        HOST_rdsize  = 3;
        HOST_wren    = 0;
        HOST_rden    = 0;

       // when RESET is active, SOB internal ForceBreak is automatically set to active to allow for program memory loading
         @(posedge clk);
        #100 reset = 0;
             TRSTn = 1'b1;
         @(posedge clk);

        // load the program
        file = $fopen("FuNNtest2.hex", "rb");   
        r = $fread(ProgBuff64, file, 0);       
        $fclose(file); 
        
         @(posedge clk);
         
         HOST_LOAD_PROGRAM;
         HOST_CLEAR_FORCE_BREAK;
         HOST_SINGLE_STEP;        //Once cleared, the SOB must be single-stepped out of the breakpoint to resume executing the thread or program
         #200

//---------------------------------------------------
//  Generate a table of random numbers--demonstration
//---------------------------------------------------        //For more information on the PRNG, refer to the floating-point PRNG information sheet at this repository
         HOST_MONITOR_WRITE(2'b11, PRNG_ADDRS, 37);          //push Range Code 037 into PRNG Range Register, which selects < 2.0
         HOST_MONITOR_WRITE(2'b11, AR1_ADDRS, 255);          //push the number of numbers to generate into AR1  note: this is copied into REPEAT counter, thus must be 1 less
         HOST_MONITOR_WRITE(2'b11, AR0_ADDRS, 32'h00010080); //push into AR0 the address of the beginning of dataPool buffer to be used by SOB to store generated numbers       
         HOST_MONITOR_WRITE(2'b11, PC_ADDRS, 'h0136);        //push Generate Random Number routine start address into PC (refer at object listing file "FuNNtest2.lst"
         #10 wait (~all_done);
         #100 wait (all_done);
         @(posedge clk);
         #10
         
         //write the random human-readable floating-point decimal character representations to file, "randomNumbers.txt"
         r = 0;       
         file = $fopen("randomNumbers.txt", "wb");            
         while(r<16) begin
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[r+1]; //note that ram2 is 1024 bits wide, thus qty. (16) H=7 decimal character floating-point representations are read out with each access
             $fwrite(file, "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0], "\n");
             r = r + 1;
         end 
         $fclose(file);
         @(posedge clk);
         #10

//---------------------------------------------------
//16-object by 16 input classification--demonstration        
//---------------------------------------------------
         file = $fopen("objectsWeights.txt", "r");   //load 16 object X vectors and their corresponding layer0 weights into Data-Pool buffer
         r = $fread(fatBuff_mem1032, file);  
         $fclose(file);  
                                                                           
         k = 0;
         while(k<32) begin
         @(posedge clk);
             DUT.u1.CPU.ram2.DataRAM_A.RAM[k+81] = fatBuff_mem1032[k][1031:8];      //this is necessary to truncate the 0x0A line feed from the 129-byte record
             DUT.u1.CPU.ram2.DataRAM_B.RAM[k+81] = fatBuff_mem1032[k][1031:8];      //back into a 128-byte record.  Both sides of the RAM must have the same image
             k=k+1;
         end 
         @(posedge clk);
            
         HOST_MONITOR_WRITE(2'b11, AR4_ADDRS, 16);       //push the number of objects to classify into SOB AR4 
         HOST_MONITOR_WRITE(2'b11, PC_ADDRS, 'h010C);    //push classify routine start address into PC
         @(posedge clk);
         #10 wait (~all_done);
                                                      
 /*
 //------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 // This block, when visible to the compiler, simply demonstrates the JTAG h/w break triggers, single-steps, JTAG monitor-read and JTAG monitor-write and resume functions
 // It demonstrates how to use the JTAG TAP to set a h/w breakpoint trigger, poll for breakpoint encountered, single-step, do a monitor-write, and resume/run threads again
 //------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         JTAG_triggerA   = 20'h00131;    //trigger h/w breakpoint when SOB PC fetches from this address
         JTAG_SET_TRIGGER_A;
         JTAG_brk_cntrl_reg[JTAG_PC_EQ_BRKA_en] = 1'b1;
         JTAG_brk_cntrl_reg[JTAG_DEBUG_en] = 1'b1;
         JTAG_ENABLE_TRIGGERS;
         JTAG_READ_DEBUG_PORT(JTAG_brk_status_addrs, 64'b0);
         
         while(~JTAG_debug_rd_data[JTAG_broke]) JTAG_READ_DEBUG_PORT(JTAG_brk_status_addrs, 64'b0);  // wait for break on CPU to occur
         
         JTAG_SSTEP;
         JTAG_SSTEP;
         JTAG_SSTEP; 
              
         JTAG_MONITOR_WRITE(32'h00000100, dword, 64'hA5A5_5A5A_A5A5_5A5A);
         JTAG_MONITOR_READ(32'h00000100, dword); 
              
         JTAG_brk_cntrl_reg[JTAG_PC_EQ_BRKA_en] = 1'b0;
         JTAG_ENABLE_TRIGGERS;                                //disable JTAG_PC_EQ_BRKA_en before running threads again
         @(posedge clk);
     
         JTAG_RUN_THREADS;  
 
         JTAG_MONITOR_WRITE(32'h00000108, dword, 64'h600D_FEED_C001_FEED);     //demonstration of On-The-Fly of Real-Time Monitor write and read to location 0108 in zero-page memory        
         JTAG_MONITOR_READ(32'h00000108, dword);    
         @(posedge clk);
         JTAG_brk_cntrl_reg[JTAG_DEBUG_en] = 1'b0;
         JTAG_ENABLE_TRIGGERS;                    //actually, because JTAG_DEBUG_en will now be cleared to "0", nothing in JTAG Debug will be enabled, thus handing debug back to 
                                                  //Host CPU interface
 //------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
         #100 wait (all_done);

         @(posedge clk);

         //write each object X vector, its weight W vector, TanH (layer0), its Exponentials (layer1), Exponentials Summation (layer2), SoftMax/divides (layer3)
         //and HardMax (layer4) results formatted and in human-readable form to file, "assayPullForm.txt"
         #1 x = 1;
         r = 1;
         objNo = 0;       
         file = $fopen("assayPullForm.txt", "wb"); //save results of 16-object by 16 input classification to file, "assayPullForm.txt", in human-readable form            
         while(r<81) begin
             $fwrite(file, "Results for Object: %d", objNo, "\n");
             $fwrite(file, "  Input#:   XW15     XW14     XW13     XW12     XW11     XW10     XW9      XW8      XW7      XW6      XW5      XW4      XW3      XW2      XW1      XW0  ", "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[x+80]; //get object X input record
             $fwrite(file, "  Data X: ", "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0], "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[x+80+16]; //get object X weights record
             $fwrite(file, " Weights: ", "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0], "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[r];
             $fwrite(file, " TanH XW: ", "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0], "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[r+1];
             $fwrite(file, "     Exp: ", "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0],   "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[r+2];
             $fwrite(file, "Sum(Exp): ", "%s", reform[63:0],   "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[r+3];
             $fwrite(file, " SoftMax: ", "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0],   "\n");
             reform = DUT.u1.CPU.ram2.DataRAM_A.RAM[r+4];
             $fwrite(file, " HardMax: ", "%s", reform[1023:960], " ", "%s", reform[959:896], " ", "%s", reform[895:832], " ", "%s", reform[831:768], " ", "%s", reform[767:704], " ", "%s", reform[703:640], " ", "%s", reform[639:576], " ", "%s", reform[575:512], " ", "%s", reform[511:448], " ", "%s", reform[447:384], " ", "%s", reform[383:320], " ", "%s", reform[319:256], " ", "%s", reform[255:192], " ", "%s", reform[191:128], " ", "%s", reform[127:64], " ", "%s", reform[63:0],   "\n");
             $fwrite(file, "\n");
             r = r + 5;
             x = x + 1;
             objNo = objNo + 1;
             
         end 
         $fclose(file);
//--------------------------------------------------------------------------------------------------------------------------------------------------------------
// These operations are here only for the purpose of demonstrating how to use the Host CPU h/w Real-Time Monitor Read and Monitor write tasks in this test bench
// Included in the demonstraction are the Data-pool read and write operations that emulate a Host CPU accessing the data-pool buffer in this test bench
//--------------------------------------------------------------------------------------------------------------------------------------------------------------
         @(posedge clk);
         HOST_MONITOR_READ(2'b11, 32'h00010080, captureReadData);  //read from location 0x0080 in parameterDataBuffer of SOB
         @(posedge clk);
         HOST_MONITOR_WRITE(2'b11, 32'h00008000, captureReadData);   //performs a single write to SOB memory space at 0x00008000
         @(posedge clk);
         
         DATA_POOL_READ(2'b11, 16'h0080, captureReadData);
         @(posedge clk);
         DATA_POOL_WRITE(2'b11, 16'h3900, captureReadData);
         @(posedge clk);
         
         #200 $finish;                  
   end 

//------------------------------------------------------------------------------------------------------------------------------------------------------
// These tasks are used to emulate a Host CPU, such as a RISC-V, for the purpose of pushing and pulling data in and out of the SOB's 64k-byte data-pool 
// memory.  The first 0x80 locations are occupied by the Host CPU h/w Real-Time Monitor interface, therefore, the first usable location in the data-pool
// buffer starts at location 0x0080 (as seen from the Host side).  From the SOB's point of view, the data-pool buffer is mapped starting at location
// 0x00010080 in its indirect memory space.  The data-pool buffer is a general-purpose, fast, and convenient way to transfer raw data, parameters, 
// results, etc., between the Host environment to the SOB processing environment.
//
// Beware that when the SOB is idle with its "Done" bit set, the SOB cannot write to it, but the Host CPU can.  With the Done bit set active "1", the
// SOB can, however still read from the data-pool, but only from the A-side data bus.  With the Done bit set, the Host is free to read and write
// from/to the data-pool buffer anytime.
//
// With the Done bit = "0", the SOB has exclusive access to it for reads and writes, and the Host CPU cannot access it at all, except by forcing the 
// SOB to enter a "Done" state, or by the Host setting the SOB's Done bit indirectly by way of a real-time monitor write to the Done bit set location
// in the SOB's STATUS Register.  Thus, every SOB task/thread should start by clearing the Done bit to "0" to signal the Host CPU that it is now busy 
// processing, and then when it is finished processing, set the Done to "1" to signal the Host CPU that it has completed processing and results are
// available for reading by the Host CPU.
//------------------------------------------------------------------------------------------------------------------------------------------------------  
task DATA_POOL_READ;
    input [1:0] poolReadSize;
    input [15:0] poolReadAddress;   //current data/parameter pool is 64k-bytes.  It can be read 1, 2, 4 or 8 bytes per transaction, but this can be modified for up to 128 bytes per transaction
    output [63:0] poolReadData;
    reg [63:0] poolReadData;
    begin
        @(posedge clk);
         #1 HOST_rden = 1;
            HOST_rdsize = poolReadSize;
            HOST_rdaddrs = poolReadAddress; 
        @(posedge clk);
         #1 poolReadData = HOST_rddata;
        @(posedge clk);
         #1 HOST_rden = 0;
    end
endtask
            
task DATA_POOL_WRITE;
    input [1:0] poolWriteSize;
    input [15:0] poolWriteAddress;
    input [63:0] poolWriteData;
    begin
        @(posedge clk);
         #1 HOST_wren = 1;
            HOST_wrsize = poolWriteSize;
            HOST_wraddrs = poolWriteAddress;
            HOST_wrdata = poolWriteData; 
        @(posedge clk);
         #1 HOST_wren = 0;
    end
endtask
        
//------------------------------------------------------------------------------------------------------------------------------------------------------
//These are some of the h/w Real-Time Monitor and Data Exchange operations the Host System can issue to the SOB via the Host Real-Time Monitor Interface
//With these tasks, the HOST can access (read or write) to any location or register in the SOB's memory map, set breakpoints, single-step, etc.
//------------------------------------------------------------------------------------------------------------------------------------------------------  
task HOST_MONITOR_READ;     //performs a single read from SOB memory space       
    input [1:0]  monitorReadSize;
    input [31:0] monitorReadAddress;
    output [63:0] monitorReadData;
    reg [63:0] monitorReadData;
    begin
         @(posedge clk);
          #1 HOST_wren    = 1;
             HOST_wraddrs = 32'h00000010;    //point to monitor-write-to-address specifier register
             HOST_wrdata = SOB_MON_ADDRS;    //for monitor-read
         @(posedge clk);             
          #1 HOST_wraddrs = 32'h0000000C;    //point to monitor-read-from-address specifier register
             HOST_wrdata  = monitorReadAddress;    //for monitor-read --first in weight list
         @(posedge clk);             
          #1 HOST_wraddrs = 32'h00000001;    //point to transaction word size specifier and monitor request bit
             HOST_wrdata = {27'b0, 1'b1, monitorReadSize, monitorReadSize};    //point to read/write size bits as final step and set monitor request bit to 1 to initiate monitor request
         @(posedge clk);             
          #1 HOST_wraddrs = 32'h00000001;    //point to transaction word size specifier and monitor request bit
             HOST_wrdata = {27'b0, 1'b0, monitorReadSize, monitorReadSize};    //point to read/write size bits as final step and clear monitor request bit
         @(posedge clk);             
          #1 HOST_wren    = 0;
             HOST_wraddrs = 0;
             HOST_rden    = 1'b1;
             HOST_rdaddrs = 32'h00000018;    //read out monitor read capture register
         @(posedge clk);             
         @(posedge clk);             
         @(posedge clk);   //data appears here, after the rising edge of this clock 
          #1 monitorReadData = HOST_rddata;       
         @(posedge clk);             
          #1 HOST_rden    = 1'b0;
    end
endtask     
     
task HOST_MONITOR_WRITE;   //performs a single write to SOB memory space
    input [1:0]  monitorWriteSize;
    input [31:0] monitorWriteAddress;
    input [63:0] monitorWriteData;
    begin                                           
         @(posedge clk);             
          #1 HOST_wren    = 1;                   //bring SOB host interface write-enable high
             HOST_wraddrs = 32'h00000010;        //point to SOB host monitor-write-to-address specifier register
             HOST_wrdata  = monitorWriteAddress; //for monitor write load monitor write address pointer
         @(posedge clk);
          #1 HOST_wraddrs = 32'h0000000C;        //point to monitor-read-from-address specifier register
             HOST_wrdata  = SOB_MON_ADDRS;       //for monitor write the SOB will read the data to be written from location 0x00007FEB, SOB_MON_ADDRS
         @(posedge clk);             
          #1 HOST_wraddrs = 32'h00000001;        //point to transaction word size specifier and monitor request bit
             HOST_wrdata  = {28'b0, monitorWriteSize, monitorWriteSize};    //point to read/write size bits as final step, leaving manual monitor-request bit = 0
         @(posedge clk);             
          #1 HOST_wraddrs = 32'h00000019;       //point to SOB_monitor-write-data-register (burst mode--auto-increment write pointer)
             HOST_wrdata  = monitorWriteData;   //get data to be written
         @(posedge clk);             
          #1 HOST_wren    = 0;
             HOST_wraddrs = 32'h00000000;    
         @(posedge clk);             
         @(posedge clk);                        //monitor-write cycle complete
    end
endtask  
   

task HOST_LOAD_PROGRAM; //When this task is invoked, the program previously loaded by the host into ProgBuff64 is pushed into actual SOB pogram memory
    integer i, j;
    begin                                           
         @(posedge clk);             
          #1 j = ProgBuff64[1];                 //by convention, the length of the program is contained in location 0x0001 of the program file/memory being loaded
             i = 0;                             //i contains the current address in SOB program memory where the current data will be written
         @(posedge clk);             
          #1 HOST_wren    = 1;                  //bring SOB host interface write-enable high
             HOST_wraddrs = 32'h00000010;       //point to SOB host monitor-write-to-address specifier register
             HOST_wrdata  = i | 32'h80000000;   //for monitor write  (first monitor write address is location 0x00000000 in program memory, requiring MSB be set)
         @(posedge clk);
          #1 HOST_wraddrs = 32'h0000000C;       //point to monitor-read-from-address specifier register
             HOST_wrdata  = SOB_MON_ADDRS;      //for monitor write the SOB will read the data to be written from location 0x00007FEB, SOB_MON_ADDRS
         @(posedge clk);             
          #1 HOST_wraddrs = 32'h00000001;       //point to transaction word size specifier and monitor request bit
             HOST_wrdata  = {28'b0, 2'b11, 2'b11};    //point to read/write size bits as final step and leave manual monitor request bit alone
         @(posedge clk);             
         while(i < j) begin   //load program memory
             #1 HOST_wren    = 1;
                HOST_wraddrs = 32'h00000019;    //point to SOB_monitor-write-data-register (burst mode--auto-increment write pointer)
                HOST_wrdata  = ProgBuff64[i];   //get data to be written
                @(posedge clk);             
             #1 HOST_wren    = 0;
                HOST_wraddrs = 32'h00000000;    
                @(posedge clk);             
                @(posedge clk);             
                i = i + 1;
         end
    end
endtask

task HOST_CLEAR_FORCE_BREAK;
    begin    
         @(posedge clk);
          #1 HOST_wren    = 1;
             HOST_wraddrs = 32'h00000000; 
             HOST_wrdata  = 32'h00000000;  //clear force break that was automatically set at original reset
         @(posedge clk);
          #1 HOST_wren    = 0;
         @(posedge clk);
    end
endtask 

task HOST_FORCE_BREAK;
    begin
         @(posedge clk);
          #1 HOST_wren    = 1;
             HOST_wraddrs = 32'h00000000; 
             HOST_wrdata = 32'h000000002;  //set force h/w break bit
         @(posedge clk);
          #1 HOST_wren    = 0;
             HOST_wraddrs = 32'h00000000; 
             HOST_wrdata = 32'h000000000;  
         @(posedge clk);
    end
endtask    

task HOST_SINGLE_STEP;
    begin        
         @(posedge clk);
          #1 HOST_wren    = 1;
             HOST_wraddrs = 32'h00000000; 
             HOST_wrdata = 32'h000000004;  //set SSTEP to step out of breakpoint
         @(posedge clk);
          #1 HOST_wraddrs = 32'h00000000; 
             HOST_wrdata = 32'h000000000;  //clear SSTEP 
         @(posedge clk);
          #1 HOST_wren    = 0;
         @(posedge clk);
    end
endtask 
//------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------
//When defined and present in an implementation, this section is for the on-chip JTAG real-time debug function 
//------------------------------------------------------------------------------------------------------------  
task JTAG_SET_TRIGGER_A;
    begin
      JTAG_WRITE_DEBUG_PORT(JTAG_trigger_A_addrs, JTAG_triggerA);
    end
endtask

task JTAG_SET_TRIGGER_B;
    begin
      JTAG_WRITE_DEBUG_PORT(JTAG_trigger_B_addrs, JTAG_triggerB);    
    end
endtask
    
task JTAG_ENABLE_TRIGGERS;
    begin
        JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
    end
endtask    

task JTAG_SSTEP;     
    begin
      {JTAG_brk_cntrl_reg[JTAG_sstep], JTAG_brk_cntrl_reg[JTAG_frc_brk]} = 2'b11;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
      while (~JTAG_debug_rd_data[JTAG_skip_cmplt]) JTAG_READ_DEBUG_PORT(JTAG_brk_status_addrs,  64'b0);   //wait for CPU to step
      {JTAG_brk_cntrl_reg[JTAG_sstep], JTAG_brk_cntrl_reg[JTAG_frc_brk]} = 2'b01;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
      @(posedge clk);
      JTAG_debug_rd_data[3:0] = 4'b0000;
    end   
endtask

    
task JTAG_RUN_THREADS;  
    begin
      {JTAG_brk_cntrl_reg[JTAG_sstep], JTAG_brk_cntrl_reg[JTAG_frc_brk]} = 2'b10;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
      @(posedge clk);   
      {JTAG_brk_cntrl_reg[JTAG_sstep], JTAG_brk_cntrl_reg[JTAG_frc_brk]} = 2'b00;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
    end
endtask

task JTAG_FORCE_BREAK;   
    begin
      @(posedge clk);
      {JTAG_brk_cntrl_reg[JTAG_sstep], JTAG_brk_cntrl_reg[JTAG_frc_brk]} = 2'b01;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
    end
endtask    
    
task JTAG_MONITOR_READ;    //data is read-from the location specified in JTAG_monitor_rd_addrs and written to the SOB Monitor Register located at location 0x7FEB, which is directly visible to the JTAG port
    input [31:0] JTAG_monitor_rd_addrs;
    input  [2:0] JTAG_monitor_rd_size; 
    begin                                                                               //read-from   and  write-to
     JTAG_WRITE_DEBUG_PORT(JTAG_mon_read_addrs_addrs, {14'b0, JTAG_monitor_rd_size, JTAG_monitor_rd_addrs, 15'h7FEB});  //location 0x7FEB is a monitor read register visible to the debugger h/w
      JTAG_brk_cntrl_reg[JTAG_mon_req] = 1'b1;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
      JTAG_brk_cntrl_reg[JTAG_mon_req] = 1'b0;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
      JTAG_READ_DEBUG_PORT(JTAG_mon_read_reg_addrs, 64'b0);
      JTAG_monitor_rd_data = JTAG_debug_rd_data;
    end
endtask
      
task JTAG_MONITOR_WRITE; //The contents of JTAG_monitor_wr_data Register is always visible to the SOB and is mapped at loction 0x7FEB
    input [31:0] JTAG_monitor_wr_addrs; //JTAG_monitor_wr_addrs specifies where the data in JTAG_monitor_wr_data Register is to be written
    input [2:0] JTAG_monitor_wr_size;
    input [63:0] JTAG_monitor_wr_data;  //the data to be written  
    begin                                           
      JTAG_WRITE_DEBUG_PORT(JTAG_mon_write_reg_addrs, JTAG_monitor_wr_data);   //this is data to be written
                                                    //read-from       and        write-to
      JTAG_WRITE_DEBUG_PORT(JTAG_mon_write_addrs_addrs, {14'b0, 15'h7FEB, JTAG_monitor_wr_size, JTAG_monitor_wr_addrs});  //this specifies 0x7FEB as the read address and the destination (write) address for the write operation
      JTAG_brk_cntrl_reg[JTAG_mon_req] = 1'b1;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
      JTAG_brk_cntrl_reg[JTAG_mon_req] = 1'b0;
      JTAG_WRITE_DEBUG_PORT(JTAG_brk_cntrl_addrs, JTAG_brk_cntrl_reg);
    end
endtask

task JTAG_WRITE_DEBUG_PORT;            //writes to a JTAG data register
    input [7:0] JTAG_wraddrs;
    input [63:0] JTAG_wrdata;
    begin
       @(posedge clk);
        JTAG_instr = JTAG_wraddrs;            
        shift_ir;                       
        JTAG_out_value = JTAG_wrdata;
        shift_dr;                       
    end
endtask

task JTAG_READ_DEBUG_PORT;             //reads from a JTAG data register
    input [7:0] JTAG_rdaddrs;
    input [63:0] JTAG_wrdata;
    begin
       @(posedge clk);
        JTAG_instr = JTAG_rdaddrs;            
        shift_ir;                       
        JTAG_out_value = JTAG_wrdata;
        shift_dr;                       
        JTAG_debug_rd_data = JTAG_in_value;
    end
endtask        

task shift_ir;
    begin
        @(negedge TCK);
        #tck_period TMS = 0;         //Run_Test Idle
        #tck_period TMS = 1;         //select_dr_scan
        #tck_period TMS = 1;         //select_ir_scan
        #tck_period TMS = 0;         //capture_ir
        #tck_period TMS = 0;         //shift_ir
        load_inst_reg;
        TMS = 1;                     //exit1_ir
        #tck_period TMS = 1;         //update_ir
        #tck_period TMS = 0;         //Run_Test Idle
    end
endtask

task load_inst_reg;
    begin
        bit_ptr = 0;
        #tck_high_time;  
        repeat(ir_width)
            begin
                @(negedge TCK); 
                TDI = JTAG_instr[bit_ptr];
                bit_ptr = bit_ptr + 1;
            end
    end
endtask

task shift_dr;
    begin
        @(negedge TCK); 
        #tck_period TMS = 1;        //select_dr_scan
        #tck_period TMS = 0;        //capture_dr
        #tck_period TMS = 0;
        load_shift_reg;
        TMS = 1;                    //exit1_dr
        #tck_period TMS = 1;        //update_dr
        #tck_period TMS = 0;        //Run_test_idle
    end
endtask

task load_shift_reg;
    begin
        bit_ptr = 0;
        begin
             #tck_period;  

            repeat(dr_width)
                begin
                    
                    @(negedge TCK);
                        TDI = JTAG_out_value[bit_ptr];
                    @(posedge TCK);
                        JTAG_in_value[bit_ptr] = TDO;
                        bit_ptr = bit_ptr + 1;
                end
        end
    end
endtask
//--------------------------------------------------------------------------

always #clk_high_time clk = ~clk;

always #tck_high_time TCK = ~TCK;                   
        
    
endmodule 

