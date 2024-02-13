`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dff
//////////////////////////////////////////////////////////////////////////////////


// insitianting the interface to the dut
module dff(dff_if.DUT vif);
    always_ff @(posedge vif.clk) begin
        if(vif.rst == 1'b1) begin
            vif.dout <= 1'b0;
        end
        else begin
            vif.dout <= vif.din;
        end
    end
endmodule
