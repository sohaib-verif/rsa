// `include "dff.v" 
// `include "inverter.v" 
// `include "mod.v" 
// `include "mod_exp.v" 
// `include "mux.v"
// `include "Division.sv"

`timescale 1ns / 1ps

/*to calculate decryption key 'd' and encryption key 'e' we use extended euclidian algorithm  
i.e                 d * e = 1 mod (phi)
*/

module RSA_main#( parameter WIDTH = 128)(  
    input                  clk,  
    input                  reset1,
    input                  encrypt_decrypt,       //if =1 it is used for encryption, otherwise decryption.
    input wire [WIDTH-1:0] encryption_key,
    input wire [WIDTH-1:0] decryption_key,
    input wire [WIDTH-1:0] modulo,
    input [WIDTH-1:0]      msg_in,               //msg input to be encrypted/decrypted
    output [WIDTH*2-1:0]   msg_out,              //output message after running the program
    output                 mod_exp_finish
    );
   
   // parameter WIDTH = 32;
    
    wire inverter_finish;
   // wire [WIDTH*2-1:0] e,d;//e=encryption key.d=decryption key.
    wire [WIDTH*2-1:0] exponent = encrypt_decrypt?encryption_key:decryption_key;
   // wire [WIDTH*2-1:0] modulo = p*q;   
    wire mod_exp_reset  = 1'b0;
    
    reg [WIDTH*2-1:0] exp_reg,msg_reg;
    reg [WIDTH*2-1:0] mod_reg;
    
    always @(posedge clk)begin
         exp_reg <= exponent;
         mod_reg <= modulo;
         msg_reg <= msg_in;
    end
    
   // inverter i(p,q,clk,reset,inverter_finish,e,d);
   // defparam i.WIDTH = WIDTH;
   (*dont_touch = "true"*)  mod_exp #(.WIDTH(WIDTH)) m(msg_reg,mod_reg,exp_reg,clk,reset1,mod_exp_finish,msg_out);
    
endmodule