class rsa_env #(parameter WIDTH = 128) extends uvm_env;

  `uvm_component_param_utils(rsa_env#(WIDTH))

  rsa_agent      #(WIDTH) m_agent;
  rsa_scoreboard #(WIDTH) m_scoreboard; 
  rsa_coverage   #(WIDTH) cov;

  function new(string name = "rsa_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    m_agent      = rsa_agent#(WIDTH)::type_id::create("m_agent", this);
    m_scoreboard = rsa_scoreboard#(WIDTH)::type_id::create("m_scoreboard", this);
    cov          = rsa_coverage#(WIDTH)::type_id::create("cov", this); // Matched class name here
    `uvm_info("ENV_BUILD", "UVM Base Environment and Scoreboard instantiated successfully.", UVM_LOW)
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    m_agent.mon.item_collected_port.connect(m_scoreboard.item_collected_export);
    m_agent.mon.item_collected_port.connect(cov.analysis_export);

    `uvm_info("ENV_CONN", "Connected Monitor Analysis Port to Scoreboard Export.", UVM_LOW)
  endfunction

endclass: rsa_env