`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class Name: monitor
//////////////////////////////////////////////////////////////////////////////////

// MAIN TASK - Getting results of stimuli from DUT and sending it to scoreboard. 
class monitor;

    virtual dff_if vif;
    mailbox #(transaction) mbx;     // send to scoreboard
    transaction tr;                 // store the data
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task run();
        tr = new();
        forever begin
            repeat(2) @(posedge vif.clk);
            tr.dout = vif.dout;
            mbx.put(tr);
            tr.display("MON");
            end
    endtask
    
endclass