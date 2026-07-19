`timescale 1ns/1ps

class rsa_agent #(parameter WIDTH = 128) extends uvm_agent;
   `uvm_component_param_utils(rsa_agent #(WIDTH))
      
   rsa_driver    #(WIDTH) driv;
   rsa_sequencer #(WIDTH) seqr;
   rsa_monitor   #(WIDTH) mon;
    
   function new(string name = "rsa_agent", uvm_component parent = null);
     super.new(name, parent);
   endfunction
 
   function void build_phase(uvm_phase phase);
     driv = rsa_driver#(WIDTH)::type_id::create("driv", this);
     seqr = rsa_sequencer#(WIDTH)::type_id::create("seqr", this);
     mon  = rsa_monitor#(WIDTH)::type_id::create("mon", this);
   endfunction
    
   function void connect_phase(uvm_phase phase);
     driv.seq_item_port.connect(seqr.seq_item_export);
   endfunction
    
endclass : rsa_agent







