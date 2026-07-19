`timescale 1ns/1ps

class rsa_sequencer #(parameter WIDTH = 128) extends uvm_sequencer #(rsa_seq_item #(WIDTH));

  `uvm_component_param_utils(rsa_sequencer #(WIDTH))
  
  function new (string name = "rsa_sequencer",uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  
endclass : rsa_sequencer