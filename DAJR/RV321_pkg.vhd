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
