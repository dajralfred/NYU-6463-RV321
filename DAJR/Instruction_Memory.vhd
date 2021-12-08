----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2021 17:55:54
-- Design Name: 
-- Module Name: Instruction_Memory - im_ach
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
USE WORK.RV321_pkg.ALL; -- include the package to your design
use std.textio.all;
use ieee.std_logic_textio.all;

entity Instruction_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    read_instr: IN STD_LOGIC := '1'; --control signal used to enable read of next instruction
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
    instr_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0)
  );
end Instruction_Memory;

architecture im_ach of Instruction_Memory is 

signal rom_words: instr_rom := instr_rom_readfile("main.mem");
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);

begin

masked_addr <= addr_in and (not IM_START_ADDR);
addr_word(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr(LENGTH_ADDR_BITS-1 downto 2);

process(clk) begin
    if rising_edge(clk) then
        if(read_instr = '1') then
            --This section needs to be adjusted manually if the word length is changed.
            instr_out(31 downto 24) <= rom_words(to_integer(unsigned(addr_word)))( 7 downto  0);
            instr_out(23 downto 16) <= rom_words(to_integer(unsigned(addr_word)))(15 downto  8);
            instr_out(15 downto  8) <= rom_words(to_integer(unsigned(addr_word)))(23 downto 16);
            instr_out( 7 downto  0) <= rom_words(to_integer(unsigned(addr_word)))(31 downto 24);
        end if;
    end if;
end process;

end im_ach;
