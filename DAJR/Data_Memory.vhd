----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2021 18:08:47
-- Design Name: 
-- Module Name: Data_Memory - dm_ach
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

entity Data_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    --(word write enable bit, write enable bit) 
    write_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of data ram
    --(word read enable bit, read enable bit) 
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of data ram
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := DM_START_ADDR;
    data_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end Data_Memory;

architecture dm_ach of Data_Memory is

signal byte_0: data_ram := (others => (others => '0')); --LSB offset=0
signal byte_1: data_ram := (others => (others => '0')); --offset=1
signal byte_2: data_ram := (others => (others => '0')); --offset=2
signal byte_3: data_ram := (others => (others => '0')); --MSB offset=3
signal addr_word: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0) := x"00000000";
signal masked_addr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);
signal addr_mod: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0):= x"00000000";

begin

masked_addr <= (addr_in and (not DM_START_ADDR));
addr_word(LENGTH_ADDR_BITS-3 downto 0) <= masked_addr(LENGTH_ADDR_BITS-1 downto 2);
addr_mod <= (addr_in and X"00000003");

process(rst,clk) begin --read data
    if(rst = '0') then
        data_out <= (others => '0');
    elsif rising_edge(clk) then
        if(read_enable = "001") then --read idividual byte
            case addr_mod is
                when X"00000000" => data_out <= X"000000" & byte_0(to_integer(unsigned(addr_word)));
                when X"00000001" => data_out <= X"000000" & byte_1(to_integer(unsigned(addr_word)));
                when X"00000002" => data_out <= X"000000" & byte_2(to_integer(unsigned(addr_word)));
                when X"00000003" => data_out <= X"000000" & byte_3(to_integer(unsigned(addr_word)));
            end case;
        
        elsif(read_enable = "011") then --read half word
            case addr_mod is
                when X"00000000" => data_out <= X"0000" & byte_1(to_integer(unsigned(addr_word))) & byte_0(to_integer(unsigned(addr_word)));
                when X"00000001" => data_out <= X"0000" & byte_2(to_integer(unsigned(addr_word))) & byte_1(to_integer(unsigned(addr_word)));
                when X"00000002" => data_out <= X"0000" & byte_3(to_integer(unsigned(addr_word))) & byte_2(to_integer(unsigned(addr_word)));
                when X"00000003" => data_out <= X"0000" & byte_0(to_integer(unsigned(addr_word))+1) & byte_3(to_integer(unsigned(addr_word)));
            end case;    
            
        elsif(read_enable = "111") then --read word
            case addr_mod is
                when X"00000000" => data_out <= byte_3(to_integer(unsigned(addr_word))) & byte_2(to_integer(unsigned(addr_word))) & byte_1(to_integer(unsigned(addr_word))) & byte_0(to_integer(unsigned(addr_word)));
                when X"00000001" => data_out <= byte_0(to_integer(unsigned(addr_word))+1) & byte_3(to_integer(unsigned(addr_word))) & byte_2(to_integer(unsigned(addr_word))) & byte_1(to_integer(unsigned(addr_word)));
                when X"00000002" => data_out <= byte_1(to_integer(unsigned(addr_word))+1) & byte_0(to_integer(unsigned(addr_word))+1) & byte_3(to_integer(unsigned(addr_word))) & byte_2(to_integer(unsigned(addr_word)));
                when X"00000003" => data_out <= byte_2(to_integer(unsigned(addr_word))+1) & byte_1(to_integer(unsigned(addr_word))+1) & byte_0(to_integer(unsigned(addr_word))+1) & byte_3(to_integer(unsigned(addr_word)));
            end case; 
            
        else
            data_out <= (others => '0');
        end if;
    end if;
end process;

process(clk) begin --write byte 0
    if rising_edge(clk) then
        if(write_enable = "001") then --write idividual byte
            if(addr_mod = X"00000000") then
                byte_0(to_integer(unsigned(addr_word))) <= data_in( 7 downto 0);
            end if;
        
        elsif(write_enable = "011") then --write half word
            case addr_mod is       
                when X"00000000" => byte_0(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000003" => byte_0(to_integer(unsigned(addr_word))+1) <= data_in( 15 downto  8);
                when others => NULL;
            end case;              

        elsif(write_enable = "111") then --write word
            case addr_mod is       
                when X"00000000" => byte_0(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000001" => byte_0(to_integer(unsigned(addr_word))+1) <= data_in( 31 downto 24);  
                when X"00000002" => byte_0(to_integer(unsigned(addr_word))+1) <= data_in( 23 downto 16);  
                when X"00000003" => byte_0(to_integer(unsigned(addr_word))+1) <= data_in( 15 downto  8);                
            end case;
        
        end if;        
    end if;
end process;

process(clk) begin --write byte 1
    if rising_edge(clk) then
        if(write_enable = "001") then --write idividual byte
            if(addr_mod = X"00000001") then
                byte_1(to_integer(unsigned(addr_word))) <= data_in( 7 downto 0);
            end if;
        
        elsif(write_enable = "011") then --write half word
            case addr_mod is       
                when X"00000001" => byte_1(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000000" => byte_1(to_integer(unsigned(addr_word))) <= data_in( 15 downto  8);
                when others => NULL;
            end case;              

        elsif(write_enable = "111") then --write word
            case addr_mod is       
                when X"00000001" => byte_1(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000002" => byte_1(to_integer(unsigned(addr_word))+1) <= data_in( 31 downto 24);  
                when X"00000003" => byte_1(to_integer(unsigned(addr_word))+1) <= data_in( 23 downto 16);  
                when X"00000000" => byte_1(to_integer(unsigned(addr_word))) <= data_in( 15 downto  8);                
            end case;
        
        end if;        
    end if;
end process;

process(clk) begin --write byte 2
    if rising_edge(clk) then
        if(write_enable = "001") then --write idividual byte
            if(addr_mod = X"00000002") then
                byte_2(to_integer(unsigned(addr_word))) <= data_in( 7 downto 0);
            end if;
        
        elsif(write_enable = "011") then --write half word
            case addr_mod is       
                when X"00000002" => byte_2(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000001" => byte_2(to_integer(unsigned(addr_word))) <= data_in( 15 downto  8);
                when others => NULL;
            end case;              

        elsif(write_enable = "111") then --write word
            case addr_mod is       
                when X"00000002" => byte_2(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000003" => byte_2(to_integer(unsigned(addr_word))+1) <= data_in( 31 downto 24);  
                when X"00000000" => byte_2(to_integer(unsigned(addr_word))) <= data_in( 23 downto 16);  
                when X"00000001" => byte_2(to_integer(unsigned(addr_word))) <= data_in( 15 downto  8);                
            end case;
        
        end if;        
    end if;
end process;

process(clk) begin --write byte 3
    if rising_edge(clk) then
        if(write_enable = "001") then --write idividual byte
            if(addr_mod = X"00000003") then
                byte_3(to_integer(unsigned(addr_word))) <= data_in( 7 downto 0);
            end if;
        
        elsif(write_enable = "011") then --write half word
            case addr_mod is       
                when X"00000003" => byte_3(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000002" => byte_3(to_integer(unsigned(addr_word))) <= data_in( 15 downto  8);
                when others => NULL;
            end case;              

        elsif(write_enable = "111") then --write word
            case addr_mod is       
                when X"00000003" => byte_3(to_integer(unsigned(addr_word))) <= data_in(  7 downto  0);
                when X"00000000" => byte_3(to_integer(unsigned(addr_word))) <= data_in( 31 downto 24);  
                when X"00000001" => byte_3(to_integer(unsigned(addr_word))) <= data_in( 23 downto 16);  
                when X"00000002" => byte_3(to_integer(unsigned(addr_word))) <= data_in( 15 downto  8);                
            end case;
        
        end if;        
    end if;
end process;


end dm_ach;
