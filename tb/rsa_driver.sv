

`timescale 1ns / 1ps

`define DRIVER_IF vif.DRIVER.cb_drv

class rsa_driver #(parameter WIDTH = 128) extends uvm_driver #(rsa_seq_item #(WIDTH));

  virtual rsa_if #(WIDTH) vif;

  `uvm_component_param_utils(rsa_driver #(WIDTH))

  function new(string name="rsa_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual rsa_if #(WIDTH))::get(this,"","vif",vif))
      `uvm_fatal("NOVIF",
                 {"virtual interface must be set for: ",
                  get_full_name(), ".vif"});
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin

      rsa_seq_item #(WIDTH) trans;
      
      seq_item_port.get_next_item(trans);
      
      `uvm_info("DRV", $sformatf("Driving new vector from file -> msg_in: 0x%0h", trans.msg_in), UVM_LOW)
      
   
      vif.reset1 = 1'b1; 
      
      `DRIVER_IF.encrypt_decrypt <= trans.encrypt_decrypt;
      `DRIVER_IF.encryption_key  <= trans.encryption_key;
      `DRIVER_IF.decryption_key  <= trans.decryption_key;
      `DRIVER_IF.modulo          <= trans.modulo;
      `DRIVER_IF.msg_in          <= trans.msg_in;
      
      repeat(5) @(posedge vif.clk);
      
      vif.reset1 = 1'b0;
      
      @(posedge `DRIVER_IF.mod_exp_finish);
      
      trans.msg_out = `DRIVER_IF.msg_out;
      
      seq_item_port.item_done();
       repeat(2) @(posedge vif.clk);
    end
  endtask

endclass

`undef DRIVER_IF





