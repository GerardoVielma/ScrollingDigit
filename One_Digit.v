`timescale 1ns / 1ps

// Project Name: ScrollingDigit

module One_Digit(
    input [3:0] SW,
    input CLK,
    output [7:0] SSEG_CA,
    output [7:0] SSEG_AN,
    output [3:0] LED
    );
    parameter width = 100000000;     
    
    reg [7:0] SEG_AN;
    
    initial begin
    SEG_AN[7] = 0;
    SEG_AN[6:0] = 1;
    SEG_AN = ~(8'b00000001);                  //initilize the anode vector with a single 0 and the other bits at 1
    end
    
    
     slow_clock # width IN1 (CLK, clk_Slow);  //Here is the instanitatin of the clock divider module
     
     always @(posedge clk_Slow) begin
     SEG_AN = {SEG_AN[6:0], SEG_AN[7]};                        // use the concat statement
     end
     Digit_Set_Segs  IN2 (SW, DP, SSEG_CA);  // make DP a constant off
     assign SSEG_AN = SEG_AN ;                  //Turn on only the 1st digit     
     assign LED = SW;                  // Drive the LEDs
endmodule

// This module slows down the 100 Mhz clock to a 2 second period.

module slow_clock(Clk, Clk_Slow);
parameter size = 100000000;  //added to be used by test bench 
input Clk;
output Clk_Slow;
reg [31:0] counter_out;
reg Clk_Slow;
	initial begin	//Note this will synthesize because we are using an FPGA and not making an IC
	counter_out<= 32'h00000000;
	Clk_Slow <=0;
	end
	
//this always block runs on the fast 100MHz clock
always @(posedge Clk) begin
	counter_out<=    counter_out + 32'h00000001;
		
	if (counter_out  > size) begin
		counter_out<= 32'h00000000;
		Clk_Slow <= !Clk_Slow;
		end
	end

endmodule

module Digit_Set_Segs( 
	input [3:0] Digit,	//All 16 hex digits decoded
	input DP,  //DP=1 turns on Decmil Point
	output [7:0] Cathodes	//Note bit order Hi to Lo (DP,G,F,E,D,C,B,A)
	);  

reg [7:0]SEG_CA;

assign Cathodes = {(~DP),SEG_CA[6:0]};

          always @(Digit)begin
case (Digit)
   4'h0: SEG_CA = ~(8'b00111111);    //Note:  to lite digit, cathode must = 0
   4'h1: SEG_CA = ~(8'b00000110);
   4'h2: SEG_CA = ~(8'b01011011);
   4'h3: SEG_CA = ~(8'b01001111);
   4'h4: SEG_CA = ~(8'b01100110);
   4'h5: SEG_CA = ~(8'b01101101);
   4'h6: SEG_CA = ~(8'b01111101);
   4'h7: SEG_CA = ~(8'b00000111);
   4'h8: SEG_CA = ~(8'b01111111);
   4'h9: SEG_CA = ~(8'b01100111);
   4'hA: SEG_CA = ~(8'b01110111);
   4'hB: SEG_CA = ~(8'b01111100);
   4'hC: SEG_CA = ~(8'b01011000);
   4'hD: SEG_CA = ~(8'b01011110);
   4'hE: SEG_CA = ~(8'b01111001);
   4'hF: SEG_CA = ~(8'b01110001);
   default: SEG_CA = ~(8'b01001001);
 endcase
 end    



endmodule
