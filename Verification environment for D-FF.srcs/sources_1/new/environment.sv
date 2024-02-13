`timescale 1ns / 1ps
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
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