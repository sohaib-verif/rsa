//`include "Divison.sv"
`timescale 1ns / 1ps

//states
`define UPDATE 2'd2
`define HOLD 2'd1
`define IDLE 2'd0

module mod_exp #( parameter WIDTH = 32)(
    input [WIDTH*2-1:0] base,       //input message
	input [WIDTH*2-1:0] modulo,     //modulo n
	input [WIDTH*2-1:0] exponent,   //encryption_key or decryption_key
	input  clk,
	input  reset,
	output reg finish,
    output [WIDTH*2-1:0] result
    );
    
    //FSM registers
    reg  [WIDTH*2-1:0] base_reg,modulo_reg,exponent_reg;
    reg  [WIDTH*2-1:0] result_reg;
    reg  [WIDTH-1:0]   exponent_next;
    reg  [1:0]         state;  
    
    //base square module registers
    wire [WIDTH*2-1:0]   base_squared = base_reg * base_reg;
    wire [WIDTH*2-1:0]   base_next; 
    wire bs_done;
    reg  bs_start;
    wire bs_busy;
    
    //result mul base module registers
    wire [WIDTH*2-1:0] result_mul_base = result_reg * base_reg;
    wire mb_done;    
    reg  mb_start;    
    wire mb_busy;
    wire [WIDTH*2-1:0] result_next;

    assign result = result_reg;
  
  // iterative division module 
   Divison #(.WIDTH(WIDTH*2))base_squared_mod ( 
  .clk         (clk),
  .rst         (reset),
  .dividend    (base_squared),
  .divisor     (modulo_reg),
  .MulDivSign  ('d0),
  .RemSign     ('d0),
  .IDU_MulDivOp('d1),
  .IDU_Rd      ('d0),
  .start       (bs_start),
  .busy        (bs_busy ),           
  .valid       (bs_done),         
  .dbz         (),
  .DIV_Rd      (),
  .DIV_Result  (base_next)
  );
    
  Divison #(.WIDTH(WIDTH*2))result_mul_base_mod ( 
  .clk         (clk),
  .rst         (reset),
  .dividend    (result_mul_base),
  .divisor     (modulo_reg),
  .MulDivSign  ('d0),
  .RemSign     ('d0),
  .IDU_MulDivOp('d1),
  .IDU_Rd      ('d0),
  .start       (mb_start),
  .busy        (mb_busy ),         
  .valid       (mb_done),         
  .dbz         (),
  .DIV_Rd      (),
  .DIV_Result  (result_next)
  );
    
    
   always @(posedge clk) begin
        if(reset) begin
            base_reg     <= base;
            modulo_reg   <= modulo;
            exponent_reg <= exponent;                
            result_reg   <= 32'd1;
            state        <= `IDLE;
            bs_start     <= 0;
            mb_start     <= 0;
            finish       <= 0;
        end
        else begin
            case(state)  
             `IDLE: begin                   //start division 
                bs_start <= 1;
                mb_start <= 1;
                state    <= `HOLD;
            end               
           `HOLD: begin                    
                bs_start <= 0;                              // start is a pulse signal so set to zero
                mb_start <= 0;              
                if (bs_done && mb_done) begin               // when divison complete
                   exponent_next <= exponent_reg >> 1; //shift exponent reg with zero append            
                    state         <= `UPDATE;
                end else
                    state <= `HOLD;
            end
             `UPDATE: begin                
                if (exponent_reg != 64'd0) begin            // repeat until exponent reg is zero
                    if (exponent_reg[0])                    
                        result_reg <= result_next;
                    base_reg     <= base_next;                
                    exponent_reg <= exponent_next;                
                    state        <= `IDLE;
                end                    
                else 
                    finish <= 1;
            end
                 
            endcase
      
        end
 end
endmodule
 
