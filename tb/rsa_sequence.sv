
`timescale 1ns / 1ps

class rsa_directed_sequence #(parameter WIDTH = 128)
  extends uvm_sequence #(rsa_seq_item #(WIDTH));

  `uvm_object_param_utils(rsa_directed_sequence #(WIDTH))

  function new(string name = "rsa_directed_sequence");
    super.new(name);
  endfunction

  virtual task body();
    int file_pointer;
    int status;
    
    reg                 f_mode;
    reg [WIDTH-1:0]     f_e_key;
    reg [WIDTH-1:0]     f_d_key;
    reg [WIDTH-1:0]     f_mod;
    reg [WIDTH-1:0]     f_msg_in;
    reg [(WIDTH*2)-1:0] f_unused_expected_out; 

    `uvm_info("DIR_SEQ", "Automated file parsing sequence initialized.", UVM_LOW)

    file_pointer = $fopen("stimulus.txt", "r");
    
    if (file_pointer == 0) begin
      `uvm_fatal("FILE_OPEN_ERR", "CRITICAL: Could not find or open 'stimulus.txt'! Please verify Python ran successfully first.")
    end

    `uvm_info("DIR_SEQ", "Successfully located stimulus.txt. Starting processing loop...", UVM_LOW)

    while (!$feof(file_pointer)) begin
      
      status = $fscanf(file_pointer, "%h, %h, %h, %h, %h, %h\n", 
                       f_mode, f_e_key, f_d_key, f_mod, f_msg_in, f_unused_expected_out);
      
      if (status == 6) begin
        
        req = rsa_seq_item#(WIDTH)::type_id::create("req");
        
        start_item(req);
        
        req.encrypt_decrypt = f_mode;
        req.encryption_key  = f_e_key;
        req.decryption_key  = f_d_key;
        req.modulo          = f_mod;
        req.msg_in          = f_msg_in;
        
        finish_item(req);
        
        `uvm_info("DIR_SEQ", $sformatf("Successfully loaded vector from file -> msg_in: 0x%0h", req.msg_in), UVM_LOW)
      end
    end

    $fclose(file_pointer);
    `uvm_info("DIR_SEQ", "All automated test vectors from text file have been processed.", UVM_LOW)

  endtask : body

endclass : rsa_directed_sequence