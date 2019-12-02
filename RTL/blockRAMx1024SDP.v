//blockRAMx1024SDP.v
`timescale 1ns/100ps

//this module is derived from the "block" Simple Dual Port RAM template provided under Vivado "Tools"-->Language Templates
//modifications by: Jerry D. Harthcock, November 23, 2018

//simple dual-port block RAM
module blockRAMx1024SDP #(parameter ADDRS_WIDTH = 12)(
    CLK,
    wren,
    bwren,
    wraddrs,
    wrdata,
    rden,
    rdaddrs,
    rddata
    );    

input  CLK;
input  wren;
input  [127:0] bwren;
input  [ADDRS_WIDTH-1:0] wraddrs;                  
input  [1023:0] wrdata;
input  rden;
input  [ADDRS_WIDTH-1:0] rdaddrs;
output [1023:0] rddata;


  parameter NB_COL = 128;                     // Specify number of columns (number of bytes)
  parameter COL_WIDTH = 8;                    // Specify column width (byte width, typically 8 or 9)
  parameter RAM_PERFORMANCE = "LOW_LATENCY";  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = "";                   // Specify name/location of RAM initialization file if using one (leave blank if not)

  wire [ADDRS_WIDTH-1:0] wraddrs;             // Port A address bus, width determined from RAM_DEPTH
  wire [ADDRS_WIDTH-1:0] rdaddrs;             // Port B address bus, width determined from RAM_DEPTH
  wire [NB_COL-1:0] wea;                      // Port A write enable
  assign wea = {bwren[127] && wren, 
                bwren[126] && wren, 
                bwren[125] && wren, 
                bwren[124] && wren, 
                bwren[123] && wren, 
                bwren[122] && wren, 
                bwren[121] && wren, 
                bwren[120] && wren, 
                bwren[119] && wren, 
                bwren[118] && wren, 
                bwren[117] && wren, 
                bwren[116] && wren, 
                bwren[115] && wren, 
                bwren[114] && wren, 
                bwren[113] && wren, 
                bwren[112] && wren, 
                bwren[111] && wren, 
                bwren[110] && wren, 
                bwren[109] && wren, 
                bwren[108] && wren, 
                bwren[107] && wren, 
                bwren[106] && wren, 
                bwren[105] && wren, 
                bwren[104] && wren, 
                bwren[103] && wren, 
                bwren[102] && wren, 
                bwren[101] && wren, 
                bwren[100] && wren, 
                bwren[ 99] && wren, 
                bwren[ 98] && wren, 
                bwren[ 97] && wren, 
                bwren[ 96] && wren, 
                bwren[ 95] && wren, 
                bwren[ 94] && wren, 
                bwren[ 93] && wren, 
                bwren[ 92] && wren, 
                bwren[ 91] && wren, 
                bwren[ 90] && wren, 
                bwren[ 89] && wren, 
                bwren[ 88] && wren, 
                bwren[ 87] && wren, 
                bwren[ 86] && wren, 
                bwren[ 85] && wren, 
                bwren[ 84] && wren, 
                bwren[ 83] && wren, 
                bwren[ 82] && wren, 
                bwren[ 81] && wren, 
                bwren[ 80] && wren, 
                bwren[ 79] && wren, 
                bwren[ 78] && wren, 
                bwren[ 77] && wren, 
                bwren[ 76] && wren, 
                bwren[ 75] && wren, 
                bwren[ 74] && wren, 
                bwren[ 73] && wren, 
                bwren[ 72] && wren, 
                bwren[ 71] && wren, 
                bwren[ 70] && wren, 
                bwren[ 69] && wren, 
                bwren[ 68] && wren, 
                bwren[ 67] && wren, 
                bwren[ 66] && wren, 
                bwren[ 65] && wren, 
                bwren[ 64] && wren, 
                bwren[ 63] && wren, 
                bwren[ 62] && wren, 
                bwren[ 61] && wren, 
                bwren[ 60] && wren, 
                bwren[ 59] && wren, 
                bwren[ 58] && wren, 
                bwren[ 57] && wren, 
                bwren[ 56] && wren, 
                bwren[ 55] && wren, 
                bwren[ 54] && wren, 
                bwren[ 53] && wren, 
                bwren[ 52] && wren, 
                bwren[ 51] && wren, 
                bwren[ 50] && wren, 
                bwren[ 49] && wren, 
                bwren[ 48] && wren, 
                bwren[ 47] && wren, 
                bwren[ 46] && wren, 
                bwren[ 45] && wren, 
                bwren[ 44] && wren, 
                bwren[ 43] && wren, 
                bwren[ 42] && wren, 
                bwren[ 41] && wren, 
                bwren[ 40] && wren, 
                bwren[ 39] && wren, 
                bwren[ 38] && wren, 
                bwren[ 37] && wren, 
                bwren[ 36] && wren, 
                bwren[ 35] && wren, 
                bwren[ 34] && wren, 
                bwren[ 33] && wren, 
                bwren[ 32] && wren, 
                bwren[ 31] && wren, 
                bwren[ 30] && wren, 
                bwren[ 29] && wren, 
                bwren[ 28] && wren, 
                bwren[ 27] && wren, 
                bwren[ 26] && wren, 
                bwren[ 25] && wren, 
                bwren[ 24] && wren, 
                bwren[ 23] && wren, 
                bwren[ 22] && wren, 
                bwren[ 21] && wren, 
                bwren[ 20] && wren, 
                bwren[ 19] && wren, 
                bwren[ 18] && wren, 
                bwren[ 17] && wren, 
                bwren[ 16] && wren, 
                bwren[ 15] && wren, 
                bwren[ 14] && wren, 
                bwren[ 13] && wren, 
                bwren[ 12] && wren, 
                bwren[ 11] && wren, 
                bwren[ 10] && wren, 
                bwren[  9] && wren, 
                bwren[  8] && wren,
                bwren[  7] && wren, 
                bwren[  6] && wren, 
                bwren[  5] && wren, 
                bwren[  4] && wren, 
                bwren[  3] && wren, 
                bwren[  2] && wren, 
                bwren[  1] && wren, 
                bwren[  0] && wren
                };
  wire enb;                                   // Port B RAM Enable, for additional power savings, disable BRAM when not in use
  assign enb = wren || rden;
  wire rstb;                                  // Port B output reset (does not affect memory contents)
  assign rstb = 1'b0;                         // Port B output reset (does not affect memory contents)
  wire regceb;                                // Port B output register enable
  assign regceb = 1'b0;                       // Port B output register enable

  reg [(NB_COL*COL_WIDTH)-1:0] RAM [(2**ADDRS_WIDTH)-1:0];
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data = {(NB_COL*COL_WIDTH){1'b0}};
  reg [(NB_COL*COL_WIDTH)-1:0] rddata_reg;
  

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, RAM, 0, (2**ADDRS_WIDTH)-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < (2**ADDRS_WIDTH); ram_index = ram_index + 1)
          RAM[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
    end
  endgenerate


  always @(posedge CLK) if (enb) ram_data <= RAM[rdaddrs];
        
  generate
  genvar i;
     for (i = 0; i < NB_COL; i = i+1) begin: byte_write
       always @(posedge CLK)
           if (wea[i]) RAM[wraddrs][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= wrdata[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
     end
  endgenerate


  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign rddata = ram_data;

    end 
    else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [(NB_COL*COL_WIDTH)-1:0] rddata_reg = {(NB_COL*COL_WIDTH){1'b0}};


      always @(posedge CLK)
        if (rstb) rddata_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        else if (regceb) rddata_reg <= ram_data;

      assign rddata = rddata_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1) depth = depth >> 1;
  endfunction





endmodule