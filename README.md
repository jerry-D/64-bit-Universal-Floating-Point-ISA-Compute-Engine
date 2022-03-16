![](https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/SYMPL_logo_med.png)
## RISC-V Rocket Chip Strap-on-Booster with Fused Universal Neural Network (FuNN) eNNgine
(March 16, 2022) The Universal Floating-Point ISA has issued as US Patent No. US11275584B2.  It can be downloaded using the following link:

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/US-11275584-B2_I.pdf

There are now two divisional (child) applications spawned from the original (parent) application.  The official filing receipts for the two divisionals can be downloaded using the following links:

https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/17555408_Filing_Receipt.pdf
https://github.com/jerry-D/HedgeHog-Fused-Spiking-Neural-Network-Emulator-Compute-Engine/blob/master/17591963-Filing_Receipt.pdf

(March 13, 2021) The Universal Floating-Point ISA specification specification is now published. It can be downloaded using the following link:

https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/Universal_ISA_Publication.pdf

(December 1, 2019) It's finally here.  Written entirely in Verilog RTL, the new 64-bit Universal Floating-Point ISA with the new FuNN eNNgine installed is finally here for free download.  At this repository you will find everything you need to begin development of your own Artificial Neural Network application using the SYMPL Strap-on-Booster (SOB) for RISC-V.  Interfacing the SOB to RISC-V is no different than interfacing to an embedded FPGA block RAM, either directly or by way of an AXI4 interface for higher speed transactions. 
Here is a .pdf information sheet on the SYMPL SOB:

https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/RISC_V_SOB.pdf

Here is a .pdf information sheet on the SYMPL FuNN eNNgine:

https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/SYMPL_neuron16c.pdf

Here is a .pdf information sheet on the SYMPL human-readable floating-point Pseudo-Random Number Generator for generating initial weight values for training the FuNN eNNgine:

https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/PRNG_H7.pdf

Finally, here is detailed documentation on the underlying 64-bit Universal Floating-Point ISA Compute Engine on which the SOB is based.  This document does not, per se, contain any information on the FuNN eNNgine because it had not been created at the time this document was written. Within the next few weeks I will be updating this document to include more information on the FuNN eNNgine and the  PRNG.  Until then, refer to .pdfs provided at this repository and also study the Verilog source code.

https://github.com/jerry-D/64-bit-Universal-Floating-Point-ISA-Compute-Engine/blob/master/UFP_ISA.pdf

It should be understood that the SOB utilizes the exact same ISA as the original compute engine described in the above document.  The only thing that has changed is three more mnemonics, which are just aliases of the original, have been added to support activation and accumulation modes of the FuNN eNNgine.  For more information on the activate and accumulate modes, refer to the demo assembly language source file or object listing and the documentation in the SYMPL64 instruction table used by the assembler.  These files can be found in the “ASM” folder at this repository. 

## Simulating in Xilinx Vivado IDE
All the Verilog RTL source files that you will need are located in the “RTL", "ASM", "test bench", and "input" folders at this repository.  The top level module is “SOB.v”.  It is suggested that when creating your project in Vivado the first time, you select the Xilinx Kintex Ultra+ xcku5p-ffvd-900-3-e as your target device.  After creating your project in Vivado, you will need to click on the “Compile Order” tab, click on “SOB” and slide it up to the top.  “CPU” should be slid immediately under “SOB” because most of the “tick” defines are in the “CPU” module.  Under the "Sources" tab, at the bottom of the panel, click "hierarchy", then right-click on "SOB" and select "Set as Top" if not already in bold font.  

The next step is to pull the “symplSOB_tb.v” test bench file into Vivado as your stimulus.  Then slide down to "Simulation Sources">"sim_1" and do the same thing for the test bench, "symplSOB_tb" as you did for "SOB", setting it as "top" in the simulation sources. 

Once you've done that, click on “Run Simulation”.  After doing that, you will notice that the simulation fails.  This is because the simulation requires the “FuNNtest2.HEX” program for the SOB to execute. So to fix that, paste the “FuNNtest2.HEX” file into the simulation working directory at:  C:\projectName\projectName .sim\sim_1\behav\xsim  .  “FuNNtest2.HEX” and assembly language source and object listing can be found in the “ASM” folder.  At this time you may want to copy the file, "symplSOB_tb_behav.wcfg" into your project root folder.  It's a rudimentary waveform configuration file you can load in after the simulation completes, because the default you will see then will have a bunch of seemingly meaningless multi-colored straight lines that don't seem to do anything.  This is because some of them are constants and buses that have not been initialized or driven in this demo.  So, to quickly make the eye-sore go away, use the .wcfg file I just mentioned, as it references internal signals that actually wiggle.  You will have to re-run the simulation to refresh once you do that.  At that point, you can explore the hierarchy and drag whatever buses/signals etc. you want to look at.  When looking at data buses that carry data into and out of the FuNN module, you should right-right click on those and select "Radix>ASCII".  Once you do that, you will be able to see the floating-point data in human-readable decimal character representation.

Next, the demonstration simulation, which is an object classification routine, requires a file of 16-input X object vectors and corresponding weight W vectors.  The name of this human-readable file is “objectsWeights.txt” and can be found in the “input” folder.  This file comprises qty. (16) 16-element vectors of human-readable decimal character sequences with token exponents.  The first record/vector is X0 object, the second record is X1 object, and so on, until you get to X15 object.  After that is W0 weight vector for object X0, and the one after that is W1 vector for object X1, and so on.  This “objectsWeights.txt” file must be pasted in the same working directory that you placed the “FuNNtest2.HEX” file.

Once you've done that, click on the “Run Simulation” button again to launch the simulation.

When the simulation is complete, you should be able to find two new .txt files in the same working directory as a result of the simulation.  One file is “randomNumbers.txt” and the other is “assayPullForm.txt”.  “randomNumbers” is just a table of qty. (16) vectors of H=7 human-readable decimal-character floating-point representation generated by the SOB as a result of the Host CPU emulated in the test bench issuing the SOB instructions to do so.  “ assayPullForm” is a formatted listing of all the values in all the layers that resulted from program execution.  Because these outputs are decimal character representations, you can load them into your favorite text editor or spread sheet.  Exact copies of these outputs can be found in the “input” and “output” folder, so you can compare your results with what is expected.

For information on what the demonstration does, refer to the assembly language object listing in the “ASM” folder and the “symplSOB_tb.v” test bench source code.

## Packages Omitted
You may quickly notice that the IEEE754-2008 floating-point operators, integer and logical operators, and XCUs have been omitted from this publication.  I omitted them mainly because the FuNN eNNgine does not require them and I didn't want those evaluating the underlying ISA architecture to get lost in the details.  However, if you would like to evaluate them, please let me know and I'll see what I can do to get you set up with that.

Enjoy!

