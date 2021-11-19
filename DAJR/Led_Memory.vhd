----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2021 15:05:41
-- Design Name: 
-- Module Name: Led_Memory - led_ach
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

-- *******Keep in mind, only lower 16 bits are valid LEDs*******--
entity Led_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    --(word write enable bit, write enable bit) 
    write_enable: IN STD_LOGIC_VECTOR(1 downto 0) := "00"; --control signal used to enable write of data ram
    --(word read enable bit, read enable bit) 
    read_enable: IN STD_LOGIC_VECTOR(1 downto 0) := "00"; --control signal used to enable read of data ram
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := LED_START_ADDR;
    data_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end Led_Memory;

architecture led_ach of Led_Memory is

signal byte_0: std_logic_vector(7 downto 0) := (others => '0'); --LSB offset=0
signal byte_1: std_logic_vector(7 downto 0) := (others => '0'); --offset=1
signal byte_2: std_logic_vector(7 downto 0) := (others => '0'); --offset=2
signal byte_3: std_logic_vector(7 downto 0) := (others => '0'); --MSB offset=3
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
signal addr_mod: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0):= x"00000000";

begin


masked_addr <= (addr_in and (not LED_START_ADDR));
addr_word(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr(LENGTH_ADDR_BITS-1 downto 2);
addr_mod <= (addr_in and X"00000003");

process(rst,clk) begin --read data
    if(rst = '0') then
        data_out <= (others => '0');
    elsif rising_edge(clk) then
        if(addr_word = X"00000000") then --***This only works for 1 word of LEDs***---
            if(read_enable = "01") then --read idividual byte 
                case addr_mod is
                    when X"00000000" => data_out <= X"000000" & byte_0;
                    when X"00000001" => data_out <= X"000000" & byte_1;
                    when X"00000002" => data_out <= X"000000" & byte_2;
                    when X"00000003" => data_out <= X"000000" & byte_3;
                end case;
            elsif(read_enable = "11" and addr_mod = X"00000000") then --read word
                data_out <= byte_3 & byte_2 & byte_1 & byte_0;
            else
                data_out <= (others => '0');
            end if;
        end if;
    end if;
end process;

process(clk) begin --write byte 0
    if rising_edge(clk) then
        if(addr_word = X"00000000") then --***This only works for 1 word of LEDs***---
            if(write_enable = "01") then --write idividual byte
                if(addr_mod = X"00000000") then
                    byte_0 <= data_in( 7 downto 0);
                end if;
            elsif(write_enable = "11" and addr_mod = X"00000000") then --write word
                byte_0 <= data_in(  7 downto  0);
            end if;
        end if;
    end if;
end process;

process(clk) begin --write byte 1
    if rising_edge(clk) then
        if(addr_word = X"00000000") then --***This only works for 1 word of LEDs***---
            if(write_enable = "01") then --write idividual byte
                if(addr_mod = X"00000001") then
                    byte_1 <= data_in( 7 downto 0);
                end if;
            elsif(write_enable = "11" and addr_mod = X"00000000") then --write word
                byte_1 <= data_in(15 downto 8);
            end if;
        end if;
    end if;
end process;

process(clk) begin --write byte 2
    if rising_edge(clk) then
        if(addr_word = X"00000000") then --***This only works for 1 word of LEDs***---
            if(write_enable = "01") then --write idividual byte
                if(addr_mod = X"00000002") then
                    byte_2 <= data_in(7 downto 0);
                end if;
            elsif(write_enable = "11" and addr_mod = X"00000000") then --write word
                byte_2 <= data_in( 23 downto 16);
            end if;
        end if;
    end if;
end process;

process(clk) begin --write byte 3
    if rising_edge(clk) then
        if(addr_word = X"00000000") then --***This only works for 1 word of LEDs***---
            if(write_enable = "01") then --write idividual byte
                if(addr_mod = X"00000003") then
                    byte_3 <= data_in( 7 downto 0);
                end if;
            elsif(write_enable = "11" and addr_mod = X"00000000") then --write word
                byte_3 <= data_in( 31 downto 24);
            end if;
        end if;
    end if;
end process;


end led_ach;
