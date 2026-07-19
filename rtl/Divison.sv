`timescale 1ns / 1ps

//iterative divison module

module Divison #(parameter WIDTH=32) ( 
  input                  clk,
  input				     rst,
  input [WIDTH-1:0]      dividend,      
  input [WIDTH-1:0]      divisor,
  input                  MulDivSign,
  input                  RemSign,
  input [3:0]            IDU_MulDivOp,           // to select if u need remainder or quotient
  input [4:0]            IDU_Rd,
  input                  start,          // to start the divison, it should be a pulse signal
  output reg             busy ,           
  output reg             valid,                     // shows divison is complete
  output reg             dbz,                       // divided by zero
  output reg [4:0]       DIV_Rd,
  output [WIDTH-1:0]     DIV_Result                 // Resultant reg   
  );
  
  // Reg declaration
  
  reg [WIDTH-1:0]  quotient_result; 
  reg [WIDTH-1:0]  remainder_result; 
  reg [WIDTH-1:0]  dividend_copy;
  reg [WIDTH-1:0]  divisor_copy;                   // copy of divisor
  reg [WIDTH-1:0]  quotient_intermediate;          // intermediate quotient
  reg [WIDTH-1:0]  quotient_next;                 // intermediate quotient for next iteration
  reg [WIDTH:0]    accumulator, accumulator_next;  // accumulator (1 bit wider)
  integer          iteration_counter;              // iteration counter
  reg              ready_for_init = 1'b1;          // initialization flag
  reg              muldiv_sign_reg;
  reg              is_remainder_op;  
  reg              rem_sign_reg;
  wire [WIDTH-1:0] remainder_signed;
  wire [WIDTH-1:0] quotient_signed;
  
  
  always @ (*) begin
    if (accumulator >= {1'b0,divisor_copy}) begin
        accumulator_next = accumulator - divisor_copy;
        {accumulator_next, quotient_next} = {accumulator_next[WIDTH-1:0], quotient_intermediate, 1'b1};
    end else begin
        {accumulator_next, quotient_next} = {accumulator, quotient_intermediate} << 1;
    end
  end
  
 always @(posedge clk or posedge rst) begin
 
    if (rst)begin 
        rem_sign_reg    <= 0;
        dividend_copy   <= 0;
        DIV_Rd          <= 0;
        muldiv_sign_reg <= 0;
        is_remainder_op <= 0;
    end    
    else if (!busy) begin
        rem_sign_reg  <= RemSign;
        dividend_copy <= dividend;
        DIV_Rd        <= IDU_Rd;
        muldiv_sign_reg <= MulDivSign;
        is_remainder_op <= IDU_MulDivOp[0];
    end
 end
 
 
  always @(posedge clk or  posedge rst) begin
    if (rst)begin    
	   valid              <= 'b0;
       iteration_counter  <= 'b0;
       busy               <= 'b0;
       dbz                <= 'b0;
       divisor_copy       <= 'b0;
       {accumulator, quotient_intermediate} <= 'b0;
       ready_for_init     <= 'b1;
       quotient_result    <= 'b0;
       remainder_result   <= 'b0; // undo final shift
    end
    else begin if (ready_for_init && start) begin
	   valid <= 0;
       iteration_counter <= 0;
       if (divisor == 0) begin // catch divide by zero
        busy <= 1'b1;
        dbz  <= 1'b1;
        ready_for_init <= 1'b0;
       end else begin    // initialize values
        busy     <= 1'b1;
        dbz      <= 1'b0;
        divisor_copy       <= divisor;
        {accumulator, quotient_intermediate} <= {{WIDTH{1'b0}}, dividend, 1'b0};
        ready_for_init     <= 1'b0;
       end
    end else if (busy) begin
        if (iteration_counter == WIDTH-1) begin    // we're done
            busy      <= 0;
            valid     <= 1;
            quotient_result  <= (dbz == 1'b1) ? 32'hffffffff: quotient_next;
            remainder_result <= (dbz == 1'b1) ? dividend_copy : accumulator_next[WIDTH:1];     // undo final shift
            ready_for_init      <=  1'b1;                                                      // initialize for next
        end else begin   // next iteration
            iteration_counter  <= iteration_counter + 1;
            accumulator <= accumulator_next;
            quotient_intermediate <= quotient_next;
        end
    end else begin
      valid <= 0;
    end
  end
end

  assign remainder_signed = (rem_sign_reg) ? (~remainder_result + 1'b1): remainder_result;
  assign quotient_signed  = (muldiv_sign_reg & !dbz ) ? (~quotient_result + 1'b1): quotient_result;
  assign DIV_Result       = is_remainder_op ? remainder_signed: quotient_signed;
  
  
endmodule
