----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2021 07:05:36 PM
-- Design Name: 
-- Module Name: NYU_6463_RV32I_pkg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package NYU_6463_RV32I_pkg is
    subtype opcode is std_logic_vector(6 downto 0);
    
----------------------------------------------------------------------------------
-- Instruction types
-- R_TYPE : arithmetic and logical instructions (add, sub, sll, slt, sltu, xor, srl, sra, or, and)
-- I_TYPE_LOAD : instructions with immediates (lb, lh, lw, lbu, lhu,)
-- I_TYPE_JALR : instructions with immediates (jalr)
-- I_TYPE_OTHERS : instructions with immediates (addi, slli, slti, sltiu, xori, srli, srai, ori, andi)
-- S_TYPE : store instructions (sb, sh, sw)
-- SB_TYPE : branch instructions (beq, bne, blt, bge, bltu, bgeu)
-- U_TYPE_LUI : instructions with upper immediates (lui)
-- U_TYPE_AUIPC : instructions with upper immediates (auipc)
-- UJ-Format : jump instructions (jal)
----------------------------------------------------------------------------------   
    constant R_TYPE: opcode        := "0110011";
    constant I_TYPE_LOAD: opcode   := "0000011";
    constant I_TYPE_JALR: opcode   := "1100111";
    constant I_TYPE_OTHERS: opcode := "0010011";
    constant S_TYPE: opcode        := "0100011";
    constant SB_TYPE: opcode       := "1100011";
    constant U_TYPE_LUI: opcode    := "0110111";
    constant U_TYPE_AUIPC: opcode  := "0010111";
    constant UJ_TYPE: opcode       := "1101111";
    
    --control signals for ALU
    type ALUop is (
        ALU_ADD,
        ALU_SUB,
        ALU_SLL,
        ALU_SLT,
        ALU_SLTU,
        ALU_XOR,
        ALU_SRL,
        ALU_SRA,
        ALU_OR,
        ALU_AND
    );
    
    --Register_Type : 32 32-bits registers
    type Register_Type is array (0 to 31) of std_logic_vector(31 downto 0);

    
end NYU_6463_RV32I_pkg;
