`include "testProl16Model.sv"

module top;
        // logic clk = 0, rst;
        // wishbone_if wb(clk);
       
        ////clk generator
        // always #10 clk = ~clk;
 
        ////RAM instantiation
        // RAM TheRam(wb.clk, rst, wb.adr, wb.datM, wb.sel, wb.cyc, wb.stb, wb.we, wb.datS, wb.ack);
        ////test program instantiation
        // test TheTest(wb.master, rst);
		
		testProl16Model TheTest();
endmodule