;// Author:  Jerry D. Harthcock
;// Version:  1.02  November 28, 2019
;// Copyright (C) 2019.  All rights reserved.
;//
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                                                                                                                  //
;//                                                Open-Source                                                       //
;//                         SYMPL 64-Bit Universal Floating-point Compute Engine and                                 //
;//                               Fused Universal Neural Network (FuNN) eNNgine                                      //
;//                                Evaluation and Product Development License                                        //
;//                                                                                                                  //
;//                                                                                                                  //
;// Open-source means:  this source code and this instruction set ("this IP") may be freely downloaded, copied,      //
;// modified, distributed and used in accordance with the terms and conditons of the licenses provided herein.       //
;//                                                                                                                  // 
;// Provided that you comply with all the terms and conditions set forth herein, Jerry D. Harthcock ("licensor"),    //
;// the original author and exclusive copyright owner of this SYMPL 64-Bit Universal Floating-point Compute Engine   //
;// and Fused Universal Neural Network (FuNN) eNNgine, including related development software ("this IP"), hereby    //
;// grants recipient of this IP ("licensee"), a world-wide, paid-up, non-exclusive license to implement this IP      //
;// within the programmable fabric of Xilinx Kintex Ultra and Kintex Ultra+ brand FPGAs--only--and used only for the //
;// purposes of evaluation, education, and development of end products and related development tools.  Furthermore,  //
;// limited to the purposes of prototyping, evaluation, characterization and testing of implementations in a hard,   //
;// custom or semi-custom ASIC, any university or institution of higher education may have their implementation of   //
;// this IP produced for said limited purposes at any foundary of their choosing provided that such prototypes do    //
;// not ever wind up in commercial circulation, with this license extending to such foundary and is in connection    //
;// with said academic pursuit and under the supervision of said university or institution of higher education.      //                                                                           //            
;//                                                                                                                  //
;// Any copying, distribution, customization, modification, or derivative work of this IP must include an exact copy //
;// of this license and original copyright notice at the very top of each source file and any derived netlist, and,  //
;// in the case of binaries, a printed copy of this license and/or a text format copy in a separate file distributed //
;// with said netlists or binary files having the file name, "LICENSE.txt".  You, the licensee, also agree not to    //
;// remove any copyright notices from any source file covered or distributed under this Evaluation and Product       //
;// Development License.                                                                                             //
;//                                                                                                                  //
;// LICENSOR DOES NOT WARRANT OR GUARANTEE THAT YOUR USE OF THIS IP WILL NOT INFRINGE THE RIGHTS OF OTHERS OR        //
;// THAT IT IS SUITABLE OR FIT FOR ANY PURPOSE AND THAT YOU, THE LICENSEE, AGREE TO HOLD LICENSOR HARMLESS FROM      //
;// ANY CLAIM BROUGHT BY YOU OR ANY THIRD PARTY FOR YOUR SUCH USE.                                                   //
;//                                                                                                                  //
;// Licensor reserves all his rights, including, but in no way limited to, the right to change or modify the terms   //
;// and conditions of this Evaluation and Product Development License anytime without notice of any kind to anyone.  //
;// By using this IP for any purpose, licensee agrees to all the terms and conditions set forth in this Evaluation   //
;// and Product Development License.                                                                                 //
;//                                                                                                                  //
;// This Evaluation and Product Development License does not include the right to sell products that incorporate     //
;// this IP or any IP derived from this IP. If you would like to obtain such a license, please contact Licensor.     //           
;//                                                                                                                  //
;// Licensor can be contacted at:  SYMPL.gpu@gmail.com or Jerry.Harthcock@gmail.com                                  //
;//                                                                                                                  //
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;-------------------------------------
; Description
;-------------------------------------
; This short program comprises two independent threads that the emulated Host CPU can invoke from the test bench.
; The first is "classify", which employs the SOB's Fused Universal Neural Network to classify up to qty. (16)
; objects, with each object comprising qty. (16) inputs and qty. (16) weights.  Activations employed include
; TanH, SoftMax (i.e., exponential, summation, division) and HardMax.  This classify routine expects qty. (16)
; object X vectors in human-readable H=7 decimal character sequence format as input and residing at the locations
; in the SOB's Data-Pool buffer memory prescribed in the test bench.  It also expects qty. (16) weight W vectors in
; human-readable H=7 decimal character sequence format and residing at the locations prescribed in the test bench.
; Prior to invocation, in the test bench, the Host CPU must load the Data-Pool with the file containing the X and W vectors.  
; After that, the Host CPU must push into SOB Auxiliary Register 4 (AR4) the number of objects (up to 16) to classify.
; Next, the Host CPU simply pushes the thread entry point value into the SOB.  To learn how to do that, simply
; refer to the test bench source code, "symplSOB_tb.v"
;
; The second thread is a routine that employs the SOB's Pseudo-Random Number Generator to generate the specified number 
; of human-readable floating-point H=7 decimal character sequences and stores them in the SOB's Data-Pool memory at 
; the location prescribed in the test bench.  To learn how to do that, simply refer to the test bench source code, "symplSOB_tb.v"
; 
; Note:  the instruction table for this program is located in the same repository as this file.  The instruction table
; name is "SYMPL64.TBL"
;
; This is probably the shortest ANN classification program you will ever see that has TanH, SoftMax and HardMax layers.

           CPU  "SYMPL64.TBL"
           HOF  "bin32"
           WDLN 8
           
;private dword storage
bitbucket:  EQU     0x0000             ;this dword location is the garbage collector.  Always reads as 0
work_1:     EQU     0x0008               
work_2:     EQU     0x0010
work_3:     EQU     0x0018
capt0_save: EQU     0x0020             ;alternate delayed exception capture register 0 save location
capt1_save: EQU     0x0028             ;alternate delayed exception capture register 1 save location
capt2_save: EQU     0x0030             ;alternate delayed exception capture register 2 save location
capt3_save: EQU     0x0038             ;alternate delayed exception capture register 3 save location

PROG_START: EQU     0x80000000         ;CPU and XCU program memory can be indirectly accessed as data memory starting here
                                            
                                       ;layer 0 of object 0 (layer00) of the neural network begins at location 0x4000 in the SOB's memory space
                                       ;in this instance, each layer comprises 16 nodes/cells and there are 5 layers (layers 0-4) per object
                                       ;note from the actual computation section below, some layers are actually intermediate layers

layer00:     equ 0x00004000            ;layer0 of each object is TanH result
layer01:     equ layer00+0x10          ;layer1 is exponential of layer0 to be used in SoftMax computation that follows
layer02:     equ layer01+0x10          ;layer2 is summation of layer1 for use in SoftMax
layer03:     equ layer02+0x10          ;layer3 is final step in SoftMax computation using a division operator 
layer04:     equ layer03+0x10          ;layer4 is the HardMax layer
                      
object0:     equ 0x00012880            ;object0  vector
object1:     equ object0+0x80          ;object1  vector
object2:     equ object1+0x80          ;object2  vector
object3:     equ object2+0x80          ;object3  vector
object4:     equ object3+0x80          ;object4  vector
object5:     equ object4+0x80          ;object5  vector
object6:     equ object5+0x80          ;object6  vector
object7:     equ object6+0x80          ;object7  vector
object8:     equ object7+0x80          ;object8  vector
object9:     equ object8+0x80          ;object9  vector
object10:    equ object9+0x80          ;object10 vector
object11:    equ object10+0x80         ;object11 vector
object12:    equ object11+0x80         ;object12 vector
object13:    equ object12+0x80         ;object13 vector
object14:    equ object13+0x80         ;object14 vector
object15:    equ object14+0x80         ;object15 vector
obj0Lay0Wt:  equ object15+0x80         ;object0  layer0 weight vector
obj1Lay0Wt:  equ obj0Lay0Wt+0x80       ;object1  layer0 weight vector
obj2Lay0Wt:  equ obj1Lay0Wt+0x80       ;object2  layer0 weight vector
obj3Lay0Wt:  equ obj2Lay0Wt+0x80       ;object3  layer0 weight vector
obj4Lay0Wt:  equ obj3Lay0Wt+0x80       ;object4  layer0 weight vector
obj5Lay0Wt:  equ obj4Lay0Wt+0x80       ;object5  layer0 weight vector
obj6Lay0Wt:  equ obj5Lay0Wt+0x80       ;object6  layer0 weight vector
obj7Lay0Wt:  equ obj6Lay0Wt+0x80       ;object7  layer0 weight vector
obj8Lay0Wt:  equ obj7Lay0Wt+0x80       ;object8  layer0 weight vector
obj9Lay0Wt:  equ obj8Lay0Wt+0x80       ;object9  layer0 weight vector
obj10Lay0Wt: equ obj9Lay0Wt+0x80       ;object10 layer0 weight vector
obj11Lay0Wt: equ obj10Lay0Wt+0x80      ;object11 layer0 weight vector
obj12Lay0Wt: equ obj11Lay0Wt+0x80      ;object12 layer0 weight vector
obj13Lay0Wt: equ obj12Lay0Wt+0x80      ;object13 layer0 weight vector
obj14Lay0Wt: equ obj13Lay0Wt+0x80      ;object14 layer0 weight vector
obj15Lay0Wt: equ obj14Lay0Wt+0x80      ;object15 layer0 weight vector

_1.0:        equ obj15Lay0Wt+0x80      ;a weight vector comprising qty. (16) of constant "     1.0" decimal char sequences

outBuffer:   equ 0x00010080            ;output buffer start location


            org     0x0              

Constants:  DFL     0, load_vects      ;entry point for this program
prog_len:   DFL     0, progend         ;the present convention is location 0x00001 is the program/thread length

one:        dfb     "     1.0"
              
;           {act, acc}    siz:dest = (siz:srcA, siz:srcB)  note: mnemonic   "_" = no activation and no accumulate
                                                   ;                      "acc" = accumulate mode enabled
                                                   ;                      "act" = activate mode enabled
                                                   ;                      "aa"  = activate and accumulate mode are enabled

            org     0x00000100                     ;default interrupt vector locations
load_vects: 
            _   _2:NMI_VECT = _2:#NMI_             ;load of interrupt vectors for faster interrupt response
            _   _2:IRQ_VECT = _2:#IRQ_             ;these registers are presently not visible to app s/w for reading
            _   _2:INV_VECT = _2:#INV_             ;meaning you can only write to them
            _   _2:DIVx0_VECT = _2:#DIVx0_
            _   _2:OVFL_VECT = _2:#OVFL_
            _   _2:UNFL_VECT = _2:#UNFL_
            _   _2:INEXT_VECT = _2:#INEXT_
            
            _   _1:setDVNCZ = _1:#intEnable        ;set interrupt enable bit
                     
done:       _   _1:setDVNCZ = _1:#DoneBit          ;set Done bit
            _   _4:TIMER = _4:#60000               ;load time-out timer with sufficient time to process before timeout
            _   _4:PCC = (_1:0x00, 0, $)           ;s/w break here  (note: $ is current PC)
            _


classify:
;            This thread classifies from 1 to 16 object X vectors against 16 layer0 weight W vectors pushed into the data-pool
;            buffer memory by the Host CPU just prior to invocation by the Host CPU emulated by the test bench
;            Prior to invocation, the Host CPU must also push into the SOB's AR4 the number of objects to classify
;            This thread is invoked by the emulated Host CPU by simply pushing into the SOB's PC the program address of classify
;            Upon completion, the SOB jumps back to "done", which sets the SOB's "Done" bit in the SOB STATUS REGISTER, which
;            signals the Host CPU it is done and is ready accept another task
  
            _   _1:clrDVNCZ = _1:#DoneBit ;clear Done bit
            _   _4:AR0 = _4:#_1.0         ;get pointer to vector where the constant "     1.0" goes
            _   _2:REPEAT = _2:#15
            _   _8:*AR0++[8] = _8:@one    ;generate a vector of qty (16) "     1.0"  as constant
            _
            _   _4:AR6 = _4:#outBuffer    ;get pointer to output buffer location to spill results from NN result layers
            _   _2:LPCNT0 = _2:AR4        ;upon entry, AR4 already contains number of objects to classify, as Host CPU pushed it in from test bench
            _   _4:AR0 = _4:#object0      ;point to first object vector X    
            
;---------------------------------------
; input layer (layer0) computation using TanH activation
;---------------------------------------
 loop:     
            _   _4:AR1 = _4:#obj0Lay0Wt   ;point to first weight vector W
            _   _4:AR2 = _4:#layer00      ;point to first layer results (layer0)
            _   _1:actMode = _1:#TanH     ;set activation mode 
            _   _2:REPEAT = _2:#15
            act  s8:*AR2++[1] = (s128:*AR0++[0], s128:*AR1++[128])  ;run all the weight W vectors against the current object X vector 
            _
            _   _4:0 = _4:*AR0++[128]     ;bump AR1 by 128 to point to next weight
;---------------------------------------
; SoftMax process
;---------------------------------------
    ;---------------------------------------
    ; second layer (layer1) is intermediate output layer where exponentials are computed and stored 
    ;---------------------------------------
            _   _4:AR1 = _4:#layer00      ;point to first layer results (layer0)
            _   _4:AR3 = _4:#_1.0         ;point to vector of 1.0s to be used as weights for exponental calculations  
            _   _1:actMode = _1:#Exp      ;set activation mode to exponential for this layer
            _   _2:REPEAT = _2:#15        ;AR2 is already pointing to layer1 as result of previous REPEAT operation
            act  s8:*AR2++[1] = (s8:*AR1++[1], s8:*AR3++[0]) ;exponentiate all the results in layer0 and store in layer1
            _
    ;---------------------------------------
    ; summation of all the exponentials 
    ;---------------------------------------
                                          ;AR1 is already pointing to layer1 from previous REPEAT
                                          ;AR3 is already pointing to 1.0 vector
                                          ;AR2 is already pointing to layer2 
            _   s8:*AR2++[16] = (s128:*AR1++[16], s128:*AR3++[0]) ;store single result in position 0 of layer 2 (the 3rd layer)  
            _
    ;---------------------------------------
    ; divide each exponential by the sum 
    ;---------------------------------------
                                          ;AR1 is already pointing to layer2
            _   _4:AR3 = _4:#layer01      ;point to the first exponentiated result/node in layer 1
                                          ;AR2 is already pointing to layer3
            _   _1:actMode = _1:#SoftMax  ;division e^xi/sum(e^xi)    note: SoftMax is actually just a division operation
            _   _2:REPEAT = _2:#15
            act  s8:*AR2++[1] = (s8:*AR3++[1], s8:*AR1++[0]) ;divide each exponential of layer 1 by the sum of all of the exponentials
            _
;---------------------------------------
; HardMax process
;---------------------------------------
            _   _4:AR1 = _4:#layer03      ;point to start of SoftMax result vector
            _   _4:AR3 = _4:#_1.0         ;use weight of 1.0 for each node
                                          ;AR2 is already pointing to layer4 from previous REPEAT
            _   _1:actMode = _1:#HardMax  ;use HardMax activation mode
            act s128:*AR2++[0] = (s128:*AR1++[0], s128:*AR3++[0])
            _
            _   _4:AR5 = _4:#layer00      ;spill the 5 layers of each pass into the output buffer
            _   _2:REPEAT = _2:#4         ;for retrieval by the host when process is done
            _   _128:*AR6++[128] = _128:*AR5++[16]
            _
            _  _4:PCS = (_2:LPCNT0, 16, loop)   ;NEXT continue until done--conditional load of PC with relative address if        
            _                                   ;specified bit is set
            
            _  s2:PC = _4:#done           ;go back to done--unconditional load of PC with absolute address
            _
            _
            
generate: 
;            This short thread generates a list of human-readable pseudo-random floating-point numbers
;            that can be used for initializing weights for NN training.  Refer to the PRNG information sheet
;            for a list of available ranges.
;            PRNG Range Register must be loaded with desired range before entry here
;            AR1 must be loaded with the number of numbers to generate before entry here
;            AR0 must be loaded with desired destination before entry here
            _   _1:clrDVNCZ = _1:#DoneBit       ;clear Done bit to signal Host CPU the SOB is now busy
            _   _2:REPEAT = _2:AR1              ;copy contents of AR1 into REPEAT Counter
            _   _8:*AR0++[8] = s8:PRNG
            _
            _   s2:PC = _4:#done                ;go back to "done"
            _
;---------------------------------------
; interrupt/exception trap service routines          
;---------------------------------------
NMI_:       _  s4:*SP--[8] = _4:PC_COPY         ;save return address from non-maskable interrupt 
                                                ;(time-out timer in this instance)
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _
            _  s4:PC = _4:*SP++[8]              ;return from interrupt
              
INV_:       _  s4:*SP--[8] = _4:PC_COPY         ;save return address from maskable invalid operation exception
            _  _8:capt0_save = _8:CAPTURE0      ;read out CAPTURE0 register and save it
            _  _8:capt1_save = _8:CAPTURE1      ;read out CAPTURE1 register and save it
            _  _8:capt2_save = _8:CAPTURE2      ;read out CAPTURE2 register and save it
            _  _8:capt3_save = _8:CAPTURE3      ;read out CAPTURE3 register and save it
            _  _1:lowSig = _1:#invalid          ;lower invalid signal
            _  _1:razFlg = _1:#invalid          ;raise invalid flag
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _  s4:PC = _4:*SP++[8]              ;return from interrupt

DIVx0_:     _  s4:*SP--[8] = _4:PC_COPY         ;save return address from maskable divide by 0 exception
            _  _8:capt0_save = _8:CAPTURE0      ;read out CAPTURE0 register and save it
            _  _8:capt1_save = _8:CAPTURE1      ;read out CAPTURE1 register and save it
            _  _8:capt2_save = _8:CAPTURE2      ;read out CAPTURE2 register and save it
            _  _8:capt3_save = _8:CAPTURE3      ;read out CAPTURE3 register and save it
            _  _1:lowSig = _1:#divByZero        ;lower divByZero signal
            _  _1:razFlg = _1:#divByZero        ;raise divByZero flag
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _  s4:PC = _4:*SP++[8]              ;return from interrupt

OVFL_:      _  s4:*SP--[8] = _4:PC_COPY         ;save return address from maskable overflow exception
            _  _8:capt0_save = _8:CAPTURE0      ;read out CAPTURE0 register and save it
            _  _8:capt1_save = _8:CAPTURE1      ;read out CAPTURE1 register and save it
            _  _8:capt2_save = _8:CAPTURE2      ;read out CAPTURE2 register and save it
            _  _8:capt3_save = _8:CAPTURE3      ;read out CAPTURE3 register and save it
            _  _1:lowSig = _1:#overflow         ;lower overflow signal
            _  _1:razFlg = _1:#overflow         ;raise overflow flag
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _  s4:PC = _4:*SP++[8]              ;return from interrupt

UNFL_:      _  s4:*SP--[8] = _4:PC_COPY         ;save return address from maskable underflow exception
            _  _8:capt0_save = _8:CAPTURE0      ;read out CAPTURE0 register and save it
            _  _8:capt1_save = _8:CAPTURE1      ;read out CAPTURE1 register and save it
            _  _8:capt2_save = _8:CAPTURE2      ;read out CAPTURE2 register and save it
            _  _8:capt3_save = _8:CAPTURE3      ;read out CAPTURE3 register and save it
            _  _1:lowSig = _1:#underflow        ;lower underflow signal
            _  _1:razFlg = _1:#underflow        ;raise underflow flag
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _  s4:PC = _4:*SP++[8]              ;return from interrupt

INEXT_:     _  s4:*SP--[8] = _4:PC_COPY         ;save return address from maskable inexact exception
            _  _8:capt0_save = _8:CAPTURE0      ;read out CAPTURE0 register and save it
            _  _8:capt1_save = _8:CAPTURE1      ;read out CAPTURE1 register and save it
            _  _8:capt2_save = _8:CAPTURE2      ;read out CAPTURE2 register and save it
            _  _8:capt3_save = _8:CAPTURE3      ;read out CAPTURE3 register and save it
            _  _1:lowSig = _1:#inexact          ;lower inexact signal
            _  _1:razFlg = _1:#inexact          ;raise inexact flag
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _  s4:PC = _4:*SP++[8]              ;return from interrupt

IRQ_:       _  s4:*SP--[8] = _4:PC_COPY
            _  _4:TIMER = _4:#60000             ;put a new value in the timer
            _
            _  s4:PC = _4:*SP++[8]              ;return from interrupt
            
progend:
            end


