----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2021 00:05:21
-- Design Name: 
-- Module Name: Nnum_Memory - nnum_ach
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

entity Nnum_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';  
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of Nnumber
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := NNUM_START_ADDR;
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end Nnum_Memory;

architecture nnum_ach of Nnum_Memory is

signal rom_words: nnum := nnum_readfile("C:/Users/Dajr/Documents/AHD_Project/NYU-6463-RV321/NYU-6463-RV321.srcs/sources_1/imports/NYU-6463-RV321 Processor/nnum.mem");
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);

begin

masked_addr <= addr_in and (not NNUM_START_ADDR);
addr_word(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr(LENGTH_ADDR_BITS-1 downto 2);

process(rst,clk) begin
    if(rst = '0') then
        data_out <= (others => '0');
    elsif rising_edge(clk) then
        if(masked_addr < NNUM_LENGTH_BYTES) then
            if(read_enable = "111") then
                --This section needs to be adjusted manually if the word length is changed.
                data_out(31 downto 24) <= rom_words(to_integer(unsigned(addr_word)))( 7 downto  0);
                data_out(23 downto 16) <= rom_words(to_integer(unsigned(addr_word)))(15 downto  8);
                data_out(15 downto  8) <= rom_words(to_integer(unsigned(addr_word)))(23 downto 16);
                data_out( 7 downto  0) <= rom_words(to_integer(unsigned(addr_word)))(31 downto 24);
            
            else
                data_out <= (others => '0');
            
            end if;
            
        else
            data_out <= (others => '0');
            
        end if;
    end if;
end process;

end nnum_ach;
