## Trying to create an FPU from the ground-up for fun

1. IEEE 754 standard for floating pointing representation.

We can use this to create a high-level structure of all the operations
on this data type primitive.

single floating-pointer (32-bit)
[ 0 ] [ 0x00 ] [ 0x000000 ]  
sign , exponent - 127, mantissa
exponent = 0 reserved for subnormal values (0.mantissa)
exponent = 0xFF reserved for inf (if mantissa = 0) or NaN (else)

VADD R1, R2
 - align exponents
 - add mantissa
 - normalize if necessary
 - done!

2. ARM 32 bit ISA

What instructions will be passed into the FPU directly?
Should we assume the instructions are already decoded?

3. Top-level architecture for 32-bit FPU accelerator

How will our hardware reflect the specs designated by the ISA?

4. RTL -> FPGA workflow

How can we start creating DUTs that can be used as a proof-of-concept?

5. (optional) P&R, Front-end VLSI for IC

How can we create an IP module for our RTL design created previously?
