# NYU-6463-RV321
Implementation of a subset of the open source RISCV architecture on an FPGA to create a functional CPU

## Be careful of absolute addressing for main.mem and nnum.mem in InstructionMemory.vhd and NnumMemory.vhd

## Group - 5 : Members
  - Dajr Alfred:        <b>dva240</b><br>
  - Artem Shlepchenko:  <b>as14836</b><br>
  - Shubham Shandilya:  <b>ss15590</b><br>

## Instructions to "run" the Processor:
- Version 6 is the latest version.
- Unzip the Version of choice and open the project contained inside in Vivado
- Version 2 to 6 are synthesizable while only V3 to V6 are robust to C-derived programs
- Copy the contents of the .mem program you wish to run into the main.mem file linked to in the program
- Be careful of choosing the correct absolute address for the main.mem and nnum.mem files
- To run on FPGA Dev Board, simply synthesize Version 3 of the processor, implement it, 
ensure that all timing and utililzation reports pass successfully, then generate the bitstream and program the devide

## Complex Program 1: Permutation : permutation.txt
### Computed N!/(N-R)! by Calculating N! and then (N-R)! separately and then dividing them together to get value of Permutation
The Final Result is stored in Data Memory as:
 -0x00000000 : N!/(N-R)!
 -0x00000008 : N!
 -0x00000010 : (N-R)!

## Complex Program 2. Binary Search operation : binsearch.txt
### Performed Binary Search Operation to look up the given number (needle) and find its location if present
The Final Result is stored in Register Stack as:
 - Register x1(ra) holds the value of the neddle if its present in the given array, otherwise 0
 - Register x2(sp) holds the distane from the initial address of arr[], which is the position of the needle in the arr[].

## Simple C Program 3. Blink the LED: c_test.mem
Read in a constant, increment it by 1 and Write to LED register 
