class wishbone_bfm #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8, parameter debugMode = 0);
        virtual wishbone_if.master sigs;
 
        function new(virtual wishbone_if.master _sigs);
                sigs = _sigs;
 
                sigs.cb.adr <= 0;
                sigs.cb.datM <= 0;
                sigs.cb.we <= 0;
                sigs.cb.sel <= '0;
                sigs.cb.cyc <= 0;
                sigs.cb.stb <= 0;
        endfunction
 
        // ------------------------------------------------------------------------
 
        virtual task singleRead(input logic [gAddrWidth-1:0] addr, output logic [gDataWidth-1:0] data);
          if(debugMode)
                  $display("singleRead @%0tns", $time);
               
                sigs.cb.adr <= addr;
                sigs.cb.we <= 0;
                sigs.cb.sel <= '1;
                sigs.cb.cyc <= 1;
                sigs.cb.stb <= 1;
               
                @(posedge sigs.cb.ack)
                data = sigs.cb.datS;
                sigs.cb.stb <= 0;
                sigs.cb.cyc <= 0;              
        endtask
 
        // ------------------------------------------------------------------------
 
        virtual task singleWrite(input logic [gAddrWidth-1:0] addr, logic [gDataWidth-1:0] data);
          if(debugMode)
                  $display("singleWrite @%0tns", $time);
                 
                sigs.cb.adr <= addr;
                sigs.cb.datM <= data;
                sigs.cb.we <= 1;
                sigs.cb.sel <= '1;
                sigs.cb.cyc <= 1;
                sigs.cb.stb <= 1;
               
                @(posedge sigs.cb.ack)
                sigs.cb.stb <= 0;
                sigs.cb.cyc <= 0;      
        endtask
 
        // ------------------------------------------------------------------------
 
        virtual task blockRead(input logic [gAddrWidth-1:0] addr, ref logic [gDataWidth-1:0] data[]);
          if(debugMode)
                  $display("blockRead @%0tns", $time);
                 
                for (int i = 0; i < $size(data); i = i + 1) begin
                        sigs.cb.adr <= addr + i;
                        sigs.cb.we <= 0;
                        sigs.cb.sel <= '1;
                        sigs.cb.cyc <= 1;
                        sigs.cb.stb <= 1;
                       
                        @(posedge sigs.cb.ack)
                        data[i] = sigs.cb.datS;
                end
                sigs.cb.stb <= 0;
                sigs.cb.cyc <= 0;
        endtask
 
        // ------------------------------------------------------------------------
 
        virtual task blockWrite(input logic [gAddrWidth-1:0] addr, const ref logic [gDataWidth-1:0] data[]);
          if(debugMode)
                  $display("blockWrite @%0tns", $time);
               
                for (int i = 0; i < $size(data); i = i + 1) begin
                        sigs.cb.adr <= addr + i;
                        sigs.cb.datM <= data[i];
                        sigs.cb.we <= 1;
                        sigs.cb.sel <= '1;
                        sigs.cb.cyc <= 1;
                        sigs.cb.stb <= 1;
                        @(posedge sigs.cb.ack);
                end
                sigs.cb.stb <= 0;
                sigs.cb.cyc <= 0;
        endtask
 
        // ------------------------------------------------------------------------
 
        virtual task idle();
                $display("idle @%0tns", $time);
 
                @sigs.cb;
        endtask
endclass
 
module top;
        logic clk = 0, rst;
        wishbone_if wb(clk);
       
        // clk generator
        always #10 clk = ~clk;
 
        // RAM instantiation
        RAM TheRam(wb.clk, rst, wb.adr, wb.datM, wb.sel, wb.cyc, wb.stb, wb.we, wb.datS, wb.ack);
        // test program instantiation
        test TheTest(wb.master, rst);
endmodule
 
class rnd_values #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8);
  randc logic [gAddrWidth-1:0] addr;
  randc logic [gDataWidth-1:0] data; 
endclass

class rnd_values_block #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8);
  randc logic [gAddrWidth-1:0] addr;
  randc logic [gDataWidth-1:0] dataBlock [];
  function new (integer gBlockSize);
    dataBlock = new[gBlockSize];
  endfunction
endclass
 
program test #(parameter int gDataWidth = 32, parameter int gAddrWidth = 8)(wishbone_if.master wb, output logic rst);
        initial begin : stimuli
                wishbone_bfm#(gDataWidth, gAddrWidth) bfm = new(wb);
                rnd_values#(gDataWidth, gAddrWidth) rndValues = new();
                const integer cBlockSize = 10;
                rnd_values_block#(gDataWidth, gAddrWidth) rndValuesBlock = new(cBlockSize);
               
                const integer gEndAddress = (2**gAddrWidth)-1;
                const logic [gDataWidth-1:0] testInput1 = 32'hAAAAAAAA;
                const logic [gDataWidth-1:0] testInput2 = 32'h55555555;
                const integer cNumRandTests = 2000;
               
                logic [gAddrWidth-1:0] addr = '1;
                logic [gDataWidth-1:0] data = '0;      
 
                logic [gDataWidth-1:0] dataBlock[] = new [gEndAddress];
                logic [gDataWidth-1:0] readDataBlock[] = new [gEndAddress];
                logic [gDataWidth-1:0] rndDataBlock[] = new [cBlockSize];
               
                // generate reset -----------------------------------------------------
                rst = 0;
                #10 rst = 1;
                #20 rst = 0;
 
                // stimuli ------------------------------------------------------------        
                //test Single Read Write with data 10101...
                for (integer i=0; i<gEndAddress; i++) begin
                        addr = i;
                        bfm.singleWrite(addr, testInput1);
                        bfm.singleRead(addr, data);
               
                        assert (data == testInput1)
                                else $error("SingleTest: TestInput1 is wrong" );
                end
               
               
                //test Single Read Write with data 010101...
                for (integer i=0; i<gEndAddress; i++) begin
                        addr = i;
                        bfm.singleWrite(addr, testInput2);
                        bfm.singleRead(addr, data);
               
                        assert (data == testInput2)
                                else $error("SingleTest: TestInput2 is wrong" );
                end
               
               
                //test Block Read Write with data 1010101...
                for (integer i=0; i<gEndAddress; i++) begin                    
                        dataBlock[i]    = testInput1;
                end;
               
                bfm.blockWrite(0, dataBlock);          
                bfm.blockRead(0, readDataBlock);
                       
                for (integer i=0; i<gEndAddress; i++) begin
                        assert (readDataBlock[i] == testInput1)
                                else $error("BlockTest: TestInput1 is wrong");         
                end;
               
               
                //test Block Read Write with data 01010101...
                for (integer i=0; i<gEndAddress; i++) begin
                        dataBlock[i]    = testInput2;
                end;
               
                bfm.blockWrite(0, dataBlock);          
                bfm.blockRead(0, readDataBlock);
                       
                for (integer i=0; i<gEndAddress; i++) begin
                        assert (readDataBlock[i] == testInput2)
                                else $error("BlockTest: TestInput2 is wrong");         
                end;
               
                //control test
                assert (readDataBlock[0] == testInput1)
                        else $error("ControlTest: This test is supposed to be wrong");         
               
                
                //random test singleWrite and singleRead
                for (integer i=0; i<gEndAddress; i++) begin
                  if(rndValues.randomize())
                    begin
                      bfm.singleWrite(rndValues.addr, rndValues.data);
                      bfm.singleRead(rndValues.addr, data);
                      assert (data == rndValues.data)
                        else $error("RandomTestSingle: Value is wrong" );
                    end
                  else
                    $display("Error in randomize");
                end
               
                //random test blockWrite and blockRead
                for (integer i=0; i<cNumRandTests; i++) begin
                  if(rndValuesBlock.randomize())
                    begin
                      bfm.blockWrite(rndValuesBlock.addr, rndValuesBlock.dataBlock);
                      bfm.blockRead(rndValuesBlock.addr, rndDataBlock);
                      assert (rndDataBlock == rndValuesBlock.dataBlock)
                        else $error("RandomTestBlock: Value is wrong" );
                    end
                  else
                    $display("Error in randomize().");
                end

                $stop;         
               
        end : stimuli
endprogram
 
interface wishbone_if # (
    parameter int gDataWidth = 32,
    parameter int gAddrWidth = 8
  )(
    input bit clk
  );
 
  logic [gAddrWidth-1:0] adr;
  logic [gDataWidth-1:0] datM; // data coming from master
  logic [gDataWidth-1:0] datS; // data coming from slave
  logic [gDataWidth/8-1:0] sel;
  logic cyc, stb, we, ack;
 
  clocking cb @(posedge clk);
    input ack, datS;
    output stb, cyc, we, datM, adr, sel;
  endclocking
 
  modport master ( // the interface as seen from the master
    clocking cb
  );
  modport slave ( // the interface as seen from the slave
    output ack, datS,
    input stb, cyc, we, datM, adr, sel
  );
endinterface