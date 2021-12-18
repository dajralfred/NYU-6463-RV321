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
    rst : IN STD_LOGIC := '1';--*******
    read_instr: IN STD_LOGIC := '1'; --control signal used to enable read of next instruction
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
    addr_in2: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');--*******
    instr_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);
    instr_out2: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);--******* 
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000" --control signal used to enable read of mem --*******
  );
end Instruction_Memory;

architecture im_ach of Instruction_Memory is

signal rom_words: instr_rom := instr_rom_readfile("C:/Users/Dajr/Documents/AHD_Project/NYU-6463-RV321/NYU-6463-RV321.srcs/sources_1/imports/NYU-6463-RV321 Processor/main.mem");
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
signal addr_word2: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr2: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
signal addr_mod2: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0):= x"00000000";

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

--*****************************************************************************-- 
masked_addr2 <= addr_in2 and (not IM_START_ADDR);
addr_word2(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr2(LENGTH_ADDR_BITS-1 downto 2);
addr_mod2 <= (addr_in2 and X"00000003");

process(rst,clk) begin --read data
    if(rst = '0') then
        instr_out2 <= (others => '0');
    elsif rising_edge(clk) then
        if(masked_addr2 < IM_LENGTH_BYTES) then
            if(read_enable = "001") then --read idividual byte
                case addr_mod2 is
                    when X"00000000" => instr_out2 <= X"000000" & rom_words(to_integer(unsigned(addr_word2)))(31 downto 24); --byte0
                    when X"00000001" => instr_out2 <= X"000000" & rom_words(to_integer(unsigned(addr_word2)))(23 downto 16); --byte1
                    when X"00000002" => instr_out2 <= X"000000" & rom_words(to_integer(unsigned(addr_word2)))(15 downto  8); --byte2
                    when X"00000003" => instr_out2 <= X"000000" & rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0); --byte3
                    when others => NULL;
                end case;
            
            elsif(read_enable = "011") then --read half word
                case addr_mod2 is
                    when X"00000000" => instr_out2 <= X"0000" & rom_words(to_integer(unsigned(addr_word2)))(23 downto 16) & rom_words(to_integer(unsigned(addr_word2)))(31 downto 24);
                    when X"00000001" => instr_out2 <= X"0000" & rom_words(to_integer(unsigned(addr_word2)))(15 downto  8) & rom_words(to_integer(unsigned(addr_word2)))(23 downto 16);
                    when X"00000002" => instr_out2 <= X"0000" & rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0) & rom_words(to_integer(unsigned(addr_word2)))(15 downto  8);
                    when X"00000003" => instr_out2 <= X"0000" & rom_words(to_integer(unsigned(addr_word2))+1)(31 downto 24) & rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0);
                    when others => NULL;
                end case;    
                
            elsif(read_enable = "111") then --read word
                case addr_mod2 is
                    when X"00000000" => instr_out2 <= rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0) & rom_words(to_integer(unsigned(addr_word2)))(15 downto  8) & rom_words(to_integer(unsigned(addr_word2)))(23 downto 16) & rom_words(to_integer(unsigned(addr_word2)))(31 downto 24);
                    when X"00000001" => instr_out2 <= rom_words(to_integer(unsigned(addr_word2))+1)(31 downto 24) & rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0) & rom_words(to_integer(unsigned(addr_word2)))(15 downto  8) & rom_words(to_integer(unsigned(addr_word2)))(23 downto 16);
                    when X"00000002" => instr_out2 <= rom_words(to_integer(unsigned(addr_word2))+1)(23 downto 16) & rom_words(to_integer(unsigned(addr_word2))+1)(31 downto 24) & rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0) & rom_words(to_integer(unsigned(addr_word2)))(15 downto  8);
                    when X"00000003" => instr_out2 <= rom_words(to_integer(unsigned(addr_word2))+1)(15 downto  8) & rom_words(to_integer(unsigned(addr_word2))+1)(23 downto 16) & rom_words(to_integer(unsigned(addr_word2))+1)(31 downto 24) & rom_words(to_integer(unsigned(addr_word2)))( 7 downto  0);
                    when others => NULL;
                end case; 
                
            else
                instr_out2 <= (others => '0');
            end if;
        else
            instr_out2 <= (others => '0');
        end if;
    end if;
end process;

end im_ach;
