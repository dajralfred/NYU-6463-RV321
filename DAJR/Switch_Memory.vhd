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
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of switches
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := SW_START_ADDR;
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    SW_in : IN STD_LOGIC_VECTOR(15 downto 0) := (others => '0') --********
  );
end Switch_Memory;

architecture sw_ach of Switch_Memory is

signal byte_0: std_logic_vector(7 downto 0) := (others => '0'); --LSB offset=0
signal byte_1: std_logic_vector(7 downto 0) := (others => '0'); --offset=1
signal byte_2: std_logic_vector(7 downto 0) := (others => '0'); --offset=2
signal byte_3: std_logic_vector(7 downto 0) := (others => '0'); --MSB offset=3
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
signal addr_mod: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0):= x"00000000";
signal t_SW_IN: std_logic_vector(15 downto 0) := (others => '0');

begin

t_SW_IN <= SW_in;

byte_0 <= t_SW_IN( 7 downto 0);

byte_1 <= t_SW_IN(15 downto 8);


masked_addr <= addr_in and (not SW_START_ADDR);
addr_word(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr(LENGTH_ADDR_BITS-1 downto 2);
addr_mod <= (addr_in and X"00000003");

process(rst,clk) begin --read data
    if(rst = '0') then
        data_out <= (others => '0');
    elsif rising_edge(clk) then
        if(addr_word = X"00000000") then --***This only works for 1 word of LEDs***---
            if(read_enable = "001") then --read idividual byte 
                case addr_mod is
                    when X"00000000" => data_out <= X"000000" & byte_0;
                    when X"00000001" => data_out <= X"000000" & byte_1;
                    when X"00000002" => data_out <= X"000000" & byte_2;
                    when X"00000003" => data_out <= X"000000" & byte_3;
                    when others => NULL;
                end case;
            elsif(read_enable = "011") then --read half word
                case addr_mod is
                    when X"00000000" => data_out <= X"0000" & byte_1 & byte_0;
                    when X"00000001" => data_out <= X"0000" & byte_2 & byte_1;
                    when X"00000002" => data_out <= X"0000" & byte_3 & byte_2;
                    when X"00000003" => data_out <= X"000000" & byte_3;
                    when others => NULL;
                end case;
                
            elsif(read_enable = "111") then --read word
                case addr_mod is
                    when X"00000000" => data_out <= byte_3 & byte_2 & byte_1 & byte_0;
                    when X"00000001" => data_out <= X"00" & byte_3 & byte_2 & byte_1;
                    when X"00000002" => data_out <= X"0000" & byte_3 & byte_2;
                    when X"00000003" => data_out <= X"000000" & byte_3;
                    when others => NULL;
                end case;
                
            else
                data_out <= (others => '0');
            end if;
        
        else
            data_out <= (others => '0');
        end if;
    end if;
end process;


end sw_ach;
