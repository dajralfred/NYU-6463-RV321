----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2021 01:38:32
-- Design Name: 
-- Module Name: Switch_Memory - sw_ach
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

entity Switch_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    read_sw: IN STD_LOGIC := '1'; --control signal used to enable read of switches
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := SW_START_ADDR;
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end Switch_Memory;

architecture sw_ach of Switch_Memory is

signal rom_words: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := (others => '0');
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := (others => '0');

begin

masked_addr <= addr_in and (not SW_START_ADDR);
addr_word(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr(LENGTH_ADDR_BITS-1 downto 2);

process(rst,clk) begin
    if(rst = '0') then
        data_out <= (others => '0');
    elsif rising_edge(clk) then
        if(read_sw = '1') then
            data_out <= rom_words;
        end if;
    end if;
end process;

end sw_ach;
