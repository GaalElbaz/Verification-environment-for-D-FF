`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class Name: scoreboard
//////////////////////////////////////////////////////////////////////////////////

// MAIN TASK - Getting results of stimuli from MONITOR
//             Compare result from DUT and generator expected value 
class scoreboard;
    transaction tr;     // data from monitor
    transaction trref;  // data from generator for reference
    mailbox #(transaction) mbx;
    mailbox #(transaction) mbxref;
    event sconext;
    
    function new( mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
        this.mbx = mbx;
        this.mbxref = mbxref;
    endfunction
    
    task run();
        forever begin
            mbx.get(tr);            // get data from monitor
            mbxref.get(trref);      // get data from generator
            tr.display("SCO");
            trref.display("REF");
            if( tr.dout == trref.din)
                $display("[SCO] : DATA MATCHED");
            else
                $display("[SCO] : DATA MISMATCHED");
            $display("--------------------------------------------------");
            -> sconext;            // Ready for next value
        end
    endtask
endclass

