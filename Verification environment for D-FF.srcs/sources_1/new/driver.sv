`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class Name: driver
//////////////////////////////////////////////////////////////////////////////////


// MAIN TASK - Applying stimuli to DUT. 
//             Getting random values from generator and applying it to dut
class driver;
    
    virtual dff_if vif;             // connecting interface to driver
    transaction data;               // data
    mailbox #(transaction) mbx;     // mailbox from gen to driver
    
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task reset();                   // for reseting the dut
        vif.rst <= 1'b1;
        repeat(5) @(posedge vif.clk);
        vif.rst <= 1'b0;
        @(posedge vif.clk);
        $display("[DRV] : RESET DONE");
    endtask

    task run();
        forever begin
            mbx.get(data);          // receive the data from gen
            vif.din <= data.din;    // applying the data to the dut
            @(posedge vif.clk);
            data.display("DRV");
            // vif.din <= 1'b0;
            @(posedge vif.clk);
        end       
    endtask;
    
endclass 