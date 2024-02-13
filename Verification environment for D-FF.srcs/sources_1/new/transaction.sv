`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class Name: transaction
//////////////////////////////////////////////////////////////////////////////////


class transaction;
    // transaction class includes control and data signals.
    randc bit din;
    bit dout; 
    
    // deep copy function - in order to overcome race conditions in UVM
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