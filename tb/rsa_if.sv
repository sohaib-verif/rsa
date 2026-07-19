
`timescale 1ns/1ps

interface rsa_if #(parameter WIDTH = 128) (input logic clk);
  

  	
    logic	            reset1;
  	logic				encrypt_decrypt;
  	logic	[WIDTH-1:0] encryption_key;	
    logic	[WIDTH-1:0] decryption_key;
  	logic	[WIDTH-1:0] modulo;
  	logic   [WIDTH-1:0] msg_in;
  
    logic   [WIDTH*2-1:0] msg_out; 
    logic                 mod_exp_finish;
  
  
  clocking cb_drv @(posedge clk);
     
    default input #1step output #1step;
    
    output	 encrypt_decrypt;
  	output	 encryption_key;	
    output	 decryption_key;
  	output	 modulo;
  	output   msg_in;
    input    msg_out; 
    input    mod_exp_finish;
    
    
  endclocking
  
  
  clocking cb_mon @(posedge clk);
     
    default input #1step;
    
    input	 encrypt_decrypt;
  	input	 encryption_key;	
    input	 decryption_key;
  	input	 modulo;
  	input    msg_in;
    input msg_out;
    input mod_exp_finish;
    
    
  endclocking
  
  
  modport DRIVER(clocking cb_drv,input clk,input reset1);
  modport MONITOR(clocking cb_mon,input clk, input reset1);
  
  
endinterface : rsa_if