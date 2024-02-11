`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dff_tb
//////////////////////////////////////////////////////////////////////////////////

class transaction;
    // transaction class includes control and data signals.
    randc bit din;
    bit dout;
    
    // deep copy function
    function transaction copy();
        copy = new();
        copy.din = this.din;
        copy.dout = this.dout;
    endfunction
    
    function void display(input string tag);
        // Display transaction information
        $display("[%0s] : DIN : %0b DOUT : %0b", tag, din, dout);  
    endfunction

endclass

// MAIN TASK - Applying stimuli to driver. 
//             Generating random values for din
//             Sending data for scoreboard for comparision
class generator;
    transaction tr;
    mailbox #(transaction) mbx;     // send data to driver
    mailbox #(transaction) mbxref;  // send data to scoreboard for comparision
    event sconext;  // sense completion of scoreboard work
    event done;     // trigger once requested number of stimuli completed
    int count;
    
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
            $display("DUT INPUT ACTIVATED");
            // vif.din <= 1'b0;
            @(posedge vif.clk);
        end       
    endtask;
    
endclass 

// MAIN TASK - Getting results of stimuli from DUT and sending it to scoreboard. 
class monitor;

    virtual dff_if vif;
    mailbox #(transaction) mbx;
    transaction tr;
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    task run();
        tr = new();
        forever begin
            repeat(2) @(posedge vif.clk);
            tr.din = vif.din;
            tr.dout = vif.dout;
            mbx.put(tr);
            tr.display("MON");
            end
    endtask
    
endclass

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

// Setting the TB.
// initializing all classes
// setting pre,post and main task
class environment;
    // classes handler
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco;
    
    //event handler
    event next;     // gen -> sco;
    
    // mailbox handler
    mailbox #(transaction) gdmbx;   // gen -> driver
    mailbox #(transaction) msbx;    // mon -> sco
    mailbox #(transaction) mbxref;  // gen -> sco
    
    virtual dff_if vif;
    
    // custome new method
    function new(virtual dff_if vif);
        gdmbx = new();
        mbxref = new();
        
        gen = new(gdmbx, mbxref);
        drv = new(gdmbx);
        
        msbx = new();
        mon = new(msbx);
        sco = new(msbx, mbxref);
        
        // connecting interface to classes
        this.vif = vif;
        drv.vif = this.vif;
        mon.vif = this.vif;
        
        // initial event
        gen.sconext = next;
        sco.sconext = next;
    endfunction
    
    // before sending the stimuli
    task pre_test();
        drv.reset();
    endtask
    
    // main test
    task test();
        fork
            gen.run();
            drv.run();
            mon.run();
            sco.run();
        join_any
    endtask
    
    // after sending all stimuli
    task post_test();
        wait(gen.done.triggered);
        $finish();
    endtask
    
    task run();
        pre_test();
        test();
        post_test();
    endtask
   
endclass

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
    
    environment env;
    
    initial begin
        env = new(vif);
        env.gen.count = 30;
        env.run();
    end
endmodule
