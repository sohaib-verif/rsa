

`timescale 1ns / 1ps

class rsa_scoreboard #(parameter WIDTH = 128) extends uvm_scoreboard;

  `uvm_component_param_utils(rsa_scoreboard #(WIDTH))

  uvm_analysis_imp #(rsa_seq_item #(WIDTH), rsa_scoreboard #(WIDTH)) item_collected_export;

  local reg [(WIDTH*2)-1:0] expected_output_queue [$];

  // Tracking metrics
  int match_count = 0;
  int mismatch_count = 0;

  function new(string name = "rsa_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_collected_export = new("item_collected_export", this);
  endfunction

  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    parse_stimulus_file();
  endfunction

  
  local function void parse_stimulus_file();
    int file_pointer;
    int status;
    

    reg                 tmp_mode;
    reg [WIDTH-1:0]     tmp_e_key;
    reg [WIDTH-1:0]     tmp_d_key;
    reg [WIDTH-1:0]     tmp_mod;
    reg [WIDTH-1:0]     tmp_msg_in;
    reg [(WIDTH*2)-1:0] golden_expected_out;

    file_pointer = $fopen("stimulus.txt", "r");
    if (file_pointer == 0) begin
      `uvm_fatal("SB_FILE_ERR", "Scoreboard could not open 'stimulus.txt' reference file!")
    end

    while (!$feof(file_pointer)) begin
      status = $fscanf(file_pointer, "%h, %h, %h, %h, %h, %h\n", 
                       tmp_mode, tmp_e_key, tmp_d_key, tmp_mod, tmp_msg_in, golden_expected_out);
      
      if (status == 6) begin
        expected_output_queue.push_back(golden_expected_out);
      end
    end

    $fclose(file_pointer);
    `uvm_info("SB_INIT", $sformatf("Scoreboard initialized. Loaded %0d reference vectors.", expected_output_queue.size()), UVM_LOW)
  endfunction
  

  
  
  virtual function void write(rsa_seq_item #(WIDTH) t);
    reg [(WIDTH*2)-1:0] golden_ref;

    `uvm_info("SB_WRITE", $sformatf("Received monitored transaction for msg_in: 0x%0h", t.msg_in), UVM_HIGH)

    if (expected_output_queue.size() == 0) begin
      `uvm_error("SB_UNEXPECTED", $sformatf("DUT generated an output (msg_out: 0x%0h), but the scoreboard reference queue is EMPTY!", t.msg_out))
      return;
    end

    golden_ref = expected_output_queue.pop_front();

    if (t.msg_out === golden_ref) begin
      match_count++;
      `uvm_info("PASS", $sformatf("MATCH SUCCESSFUL!\n Input Message: 0x%0h\n Observed Output: 0x%0h\n Expected Output: 0x%0h", t.msg_in, t.msg_out, golden_ref), UVM_LOW)
    end
    else begin
      mismatch_count++;
      `uvm_error("FAIL", $sformatf("MISMATCH DETECTED!\n Input Message: 0x%0h\n Observed Output: 0x%0h\n Expected Output: 0x%0h", t.msg_in, t.msg_out, golden_ref))
    end
  endfunction

  
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    $display("\n=========================================================");
    $display("               VERIFICATION REPORT SUMMARY               ");
    $display("=========================================================");
    $display(" TOTAL MATCHES:    %0d", match_count);
    $display(" TOTAL MISMATCHES: %0d", mismatch_count);
    $display(" LEFT OVER IN Q:   %0d (Should be 0 if all rows executed)", expected_output_queue.size());
    $display("=========================================================\n");

    if (mismatch_count > 0 || expected_output_queue.size() > 0) begin
      `uvm_error("TEST_STATUS", "--- TEST FAILED ---")
    end else begin
      `uvm_info("TEST_STATUS", "--- TEST PASSED CLEANLY ---", UVM_LOW)
    end
  endfunction

endclass