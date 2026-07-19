


`timescale 1ns/1ps

import uvm_pkg::*;
import env_pkg::*;
`include "uvm_macros.svh"
module testbench;

  bit clk;
  bit tb_reset1; 

 
  always #5 clk = ~clk;

  rsa_if #(.WIDTH(128)) intf(.clk(clk));

  assign intf.reset1 = tb_reset1;

  // DUT Instantiation
  RSA_main #(.WIDTH(128)) u_rsa_dut (
    .clk             ( intf.clk             ), 
    .reset1          ( intf.reset1          ), 
    .encrypt_decrypt ( intf.encrypt_decrypt ), 
    .encryption_key  ( intf.encryption_key  ), 
    .decryption_key  ( intf.decryption_key  ), 
    .modulo          ( intf.modulo          ), 
    .msg_in          ( intf.msg_in          ), 
    .msg_out         ( intf.msg_out         ), 
    .mod_exp_finish  ( intf.mod_exp_finish  )  
  );
  



  
  initial begin

    uvm_config_db#(virtual rsa_if #(128))::set(null, "*", "vif", intf);
    
    tb_reset1 = 1'b1;
     #50;
    tb_reset1 = 1'b0;
  end

  initial begin
    run_test(); 
  end

initial begin
    $display("[%0t] Starting VCD dump", $time);
    $dumpfile("dump.vcd");
     $dumpvars(0, clk);
    $dumpvars(0, tb_reset1);
    $dumpvars(0, intf.encrypt_decrypt);
    $dumpvars(0, intf.encryption_key);
    $dumpvars(0, intf.decryption_key);
    $dumpvars(0, intf.modulo);
    $dumpvars(0, intf.msg_in);
    $dumpvars(0, intf.msg_out);
    $dumpvars(0, intf.mod_exp_finish);
end

endmodule