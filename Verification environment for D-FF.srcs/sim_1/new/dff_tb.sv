`timescale 1ns / 1ps
//`include "dff_if.sv"
//`include "dff.sv"
//`include "transaction.sv"
//`include "generator.sv"
//`include "driver.sv"
//`include "monitor.sv"
//`include "scoreboard.sv"
//`include "environment.sv"
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dff_tb
//////////////////////////////////////////////////////////////////////////////////

module dff_tb;
    
    // declaring the interface
    dff_if vif();  
    // instaniting the dut
    dff dut(vif);
    
    // creating clock
    initial begin
        vif.clk = 1'b0;
    end
    always #10 vif.clk <= ~vif.clk;
    
    //environment handler
    environment env;
    
    initial begin
        env = new(vif);
        env.gen.count = 30;
        env.run();
    end
endmodule
