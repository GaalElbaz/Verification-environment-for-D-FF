`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class Name: generator
//////////////////////////////////////////////////////////////////////////////////


// MAIN TASK - Applying stimuli to driver. 
//             Generating random values for din
//             Sending data for scoreboard for comparision
class generator;
    transaction tr;
    mailbox #(transaction) mbx;     // send data to driver
    mailbox #(transaction) mbxref;  // send data to scoreboard for comparision
    event sconext;  // sense completion of scoreboard work
    event done;     // trigger once requested number of stimuli completed
    int count;      // number of tests
    
    // custome new function
    function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
        this.mbx = mbx;
        this.mbxref = mbxref;
        tr = new();
    endfunction
    
    task run();
        repeat(count) begin                             // count specifies the number of stimultis to generate
            assert(tr.randomize()) else 
                $error("[GEN] : RANDOMIZATION FAILED"); // Generate random values.
            mbx.put(tr.copy());                         // Data sent to driver to apply to DUT
            mbxref.put(tr.copy());                      // Data sent to scoreboard for comparision
            tr.display("GEN");
            @(sconext);                                 // Wait till scoreboard compeletes his execution.
        end
        ->done;                                         // Stop the simulation
    endtask

endclass