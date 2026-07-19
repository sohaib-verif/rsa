
`timescale 1ns/1ps

class rsa_base_test extends uvm_test;
  `uvm_component_utils(rsa_base_test)

 rsa_env #(128) m_env;
  
  virtual rsa_if#(128) vif;

  function new(string name = "rsa_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   m_env = rsa_env#(128)::type_id::create("m_env", this);

    if(!uvm_config_db#(virtual rsa_if#(128))::get(this, "", "vif", vif)) begin
      `uvm_fatal("TEST_VIF_ERR", "Could not locate virtual interface handle inside the uvm_config_db!")
    end

    uvm_config_db#(virtual rsa_if#(128))::set(this, "m_env.m_agent*", "vif", vif);
  endfunction

  virtual task run_phase(uvm_phase phase);
    rsa_directed_sequence#(128) rsa_seq; 
    rsa_seq = rsa_directed_sequence#(128)::type_id::create("rsa_seq");

    phase.raise_objection(this);
    `uvm_info("TEST_START", "Starting Directed Test Sequence onto Driver...", UVM_LOW)
    
    rsa_seq.start(m_env.m_agent.seqr);
    
    
    `uvm_info("TEST_END", "Directed Test Sequence finished. Dropping Objection.", UVM_LOW)
    phase.drop_objection(this);
  endtask
  

endclass: rsa_base_test