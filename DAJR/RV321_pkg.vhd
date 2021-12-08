----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2021 19:09:44
-- Design Name: 
-- Module Name: RV321_pkg - pkg_ach
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package RV321_pkg is

constant IM_LENGTH_WORDS: integer := 512;-- Number of words in Instruction Memory
constant NNUM_LENGTH_WORDS: integer := 3;-- Number of words in N-number Memory
constant SW_LED_LENGTH_WORDS: integer := 1;-- Number of words in Switch Memory
constant DM_LENGTH_WORDS: integer := 1024;-- Number of words in Data Memory

constant LENGTH_ADDR_BITS: integer := 32; --address width in bits (word size)
constant LENGTH_ADDR_BYTES: integer := LENGTH_ADDR_BITS/8; --address width in bytes

constant IM_LENGTH_BYTES: integer := IM_LENGTH_WORDS * LENGTH_ADDR_BYTES;-- Number of bytes in Instruction Memory
constant NNUM_LENGTH_BYTES: integer := NNUM_LENGTH_WORDS * LENGTH_ADDR_BYTES;-- Number of bytes in N-number Memory
constant SW_LED_LENGTH_BYTES: integer := SW_LED_LENGTH_WORDS * LENGTH_ADDR_BYTES;-- Number of bytes in Switch Memory
constant DM_LENGTH_BYTES: integer := DM_LENGTH_WORDS * LENGTH_ADDR_BYTES;-- Number of bytes in Data Memory


constant IM_START_ADDR: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := X"01000000"; --start address of instruction memory
constant NNUM_START_ADDR: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := X"00100000"; --start address of N-number memory
constant SW_START_ADDR: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := X"00100010"; --start address of Switch memory
constant LED_START_ADDR: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := X"00100014"; --start address of Switch memory
constant DM_START_ADDR: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := X"80000000"; --start address of Data memory

type instr_rom is array(0 to IM_LENGTH_WORDS-1) of std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
type data_ram is array(0 to DM_LENGTH_WORDS-1) of std_logic_vector(7 downto 0);
type nnum is array(0 to NNUM_LENGTH_WORDS-1) of std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);

impure function instr_rom_readfile(FileName : STRING) return instr_rom;

impure function nnum_readfile(FileName : STRING) return nnum;

--additions from other meembers

--Register_Type : 32 32-bits registers
type Register_Type is array (0 to 31) of std_logic_vector(31 downto 0);

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
--F_TYPE: FENCE (implemented as NOP)
--E_TYPE: halt program execution
--------------------------------------------------------------------------------   
    constant R_TYPE: opcode        := "0110011";
    constant I_TYPE_LOAD: opcode   := "0000011";
    constant I_TYPE_JALR: opcode   := "1100111";
    constant I_TYPE_OTHERS: opcode := "0010011";
    constant S_TYPE: opcode        := "0100011";
    constant SB_TYPE: opcode       := "1100011";
    constant U_TYPE_LUI: opcode    := "0110111";
    constant U_TYPE_AUIPC: opcode  := "0010111";
    constant UJ_TYPE: opcode       := "1101111";
    constant F_TYPE: opcode        := "0001111";
    constant E_TYPE: opcode        := "1110011";
    
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
    
    --control signals for BC
    type BCop is (
        BC_EQ,
        BC_NE,
        BC_LT,
        BC_GE,
        BC_LTU,
        BC_GEU
    );
    

end RV321_pkg;

package body RV321_pkg is

impure function instr_rom_readfile(FileName : STRING) return instr_rom is
    file FileHandle : TEXT open READ_MODE is FileName;
    variable CurrentLine : LINE;
    variable CurrentWord : std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
    variable Result : instr_rom := (others => (others => 'X'));
    
    begin
    
    for i in 0 to IM_LENGTH_WORDS - 1 loop
        exit when endfile(FileHandle);
        readline(FileHandle, CurrentLine);
        hread(CurrentLine, CurrentWord);
        for j in 0 to LENGTH_ADDR_BYTES-1 loop
            Result(i)( ((j+1)*8)-1 downto (j*8)) := CurrentWord( ((LENGTH_ADDR_BYTES-j)*8)-1 downto (LENGTH_ADDR_BYTES-(j+1))*8 );--Little Edianness
        end loop;
    end loop;
    
    return Result;
    
end function;


impure function nnum_readfile(FileName : STRING) return nnum is
    file FileHandle : TEXT open READ_MODE is FileName;
    variable CurrentLine : LINE;
    variable CurrentWord : std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
    variable Result : nnum := (others => (others => 'X'));
    
    begin
    
    for i in 0 to NNUM_LENGTH_WORDS - 1 loop
        exit when endfile(FileHandle);
        readline(FileHandle, CurrentLine);
        hread(CurrentLine, CurrentWord);
        for j in 0 to LENGTH_ADDR_BYTES-1 loop
            Result(i)( ((j+1)*8)-1 downto (j*8)) := CurrentWord( ((LENGTH_ADDR_BYTES-j)*8)-1 downto (LENGTH_ADDR_BYTES-(j+1))*8 );--Little Edianness
        end loop;
    end loop;
    
    return Result;
    
end function;

end RV321_pkg;
