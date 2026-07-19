
`timescale 1ns/1ps

`define MONITOR_IF vif.MONITOR.cb_mon

class rsa_monitor #(parameter WIDTH = 128) extends uvm_monitor;

  virtual rsa_if #(WIDTH) vif;

  uvm_analysis_port #(rsa_seq_item #(WIDTH)) item_collected_port;

  `uvm_component_param_utils(rsa_monitor #(WIDTH))


  function new(string name = "rsa_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction : new


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual rsa_if #(WIDTH))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
  endfunction : build_phase
  
  
  virtual task run_phase(uvm_phase phase);

    rsa_seq_item #(WIDTH) trans;

    forever begin

        @(posedge `MONITOR_IF.mod_exp_finish);

        @(posedge vif.clk);

        trans = rsa_seq_item#(WIDTH)::type_id::create("trans");

        trans.encrypt_decrypt = `MONITOR_IF.encrypt_decrypt;
        trans.encryption_key  = `MONITOR_IF.encryption_key;
        trans.decryption_key  = `MONITOR_IF.decryption_key;
        trans.modulo          = `MONITOR_IF.modulo;
        trans.msg_in          = `MONITOR_IF.msg_in;
        trans.msg_out         = `MONITOR_IF.msg_out;

        item_collected_port.write(trans);

    end

endtask

endclass : rsa_monitor

`undef MONITOR_IF








