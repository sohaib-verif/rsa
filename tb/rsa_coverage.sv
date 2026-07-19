`ifndef RSA_SUBSCRIBER_SV
`define RSA_SUBSCRIBER_SV

class rsa_coverage #(parameter WIDTH = 128) extends uvm_subscriber #(rsa_seq_item #(WIDTH));
  
  `uvm_component_param_utils(rsa_coverage #(WIDTH))

  rsa_seq_item #(WIDTH) pkt;

  
  covergroup rsa_functional_cov;
    option.per_instance = 1;

    cp_op_mode: coverpoint pkt.encrypt_decrypt {
      bins encryption_mode = {1'b1};
      bins decryption_mode = {1'b0};
    }

    cp_msg_in: coverpoint pkt.msg_in {
      bins zero_val     = {'0};
      bins small_vals   = {['h1 : 'hFFFF]};
      bins mid_vals     = {['h10000 : 'hFFFF_FFFF_FFFF_FFFF]};
      bins large_vals   = {['hFFFF_FFFF_FFFF_F000 : '1]};
    }

    cross_op_x_msg: cross cp_op_mode, cp_msg_in;
  endgroup

  
  function new(string name = "rsa_coverage", uvm_component parent = null);
    super.new(name, parent);
    rsa_functional_cov = new();
  endfunction

  
  virtual function void write(rsa_seq_item #(WIDTH) t);
    pkt = t; 
    rsa_functional_cov.sample(); 
  endfunction
  

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("FUNCTIONAL_COVERAGE", $sformatf("Your Functional Coverage Level: %0.2f%%", rsa_functional_cov.get_inst_coverage()), UVM_LOW)
  endfunction

endclass

`endif 