 `timescale 1ns/1ps
 
class rsa_seq_item #(parameter WIDTH = 128) extends uvm_sequence_item;
     
  function new(string name = "rsa_seq_item");
    super.new(name);
  endfunction
  
  	rand	logic					encrypt_decrypt;   
  	rand	logic	[WIDTH-1:0] 	encryption_key;	
    rand	logic	[WIDTH-1:0] 	decryption_key;
  	rand	logic	[WIDTH-1:0] 	modulo;
  	rand	logic   [WIDTH-1:0] 	msg_in;
    		logic   [WIDTH*2-1:0] 	msg_out; 
    		logic                 	mod_exp_finish;
  
  
 
  
  `uvm_object_utils_begin(rsa_seq_item)
  	`uvm_field_int	(encrypt_decrypt, UVM_DEFAULT)
  	`uvm_field_int	(encryption_key, UVM_DEFAULT)
  	`uvm_field_int	(decryption_key, UVM_DEFAULT)
  	`uvm_field_int	(modulo, UVM_DEFAULT)
  	`uvm_field_int	(msg_in, UVM_DEFAULT)
  	`uvm_field_int	(msg_out, UVM_DEFAULT)
  	`uvm_field_int	(mod_exp_finish, UVM_DEFAULT)
  
  
  `uvm_object_utils_end
  
  
endclass : rsa_seq_item