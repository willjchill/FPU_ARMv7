`timescale 1ns / 1ps

// Mantissa addition using IEEE 754 standards for floating point arithmetic
module mantissa_addsub_32(
	input A_sign,
	input B_sign,
	input [22:0] A,
	input [22:0] B,
	output [22:0] Sum,
	output Sign,
	output Overflow
    );
    wire [23:0] tmp;
    assign tmp = (A_sign == B_sign) ? A + B : (A >= B ? A - B : B - A);
    assign Overflow = tmp[23];
    assign Sum = tmp[22:0];
    assign Sign = (A_sign == B_sign) ? A_sign : (A >= B ? A_sign : B_sign);             
endmodule