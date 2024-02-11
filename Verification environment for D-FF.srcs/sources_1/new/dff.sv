`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dff
//////////////////////////////////////////////////////////////////////////////////

interface dff_if;
    logic clk;
    logic rst;
    logic din;
    logic dout;
endinterface

module dff(dff_if vif);
    always_ff @(posedge vif.clk) begin
        if(vif.rst == 1'b1) begin
            vif.dout <= 1'b0;
        end
        else begin
            vif.dout <= vif.din;
        end
    end
endmodule
