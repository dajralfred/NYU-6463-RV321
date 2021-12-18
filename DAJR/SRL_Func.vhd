----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 10:13:47 AM
-- Design Name: 
-- Module Name: SRL_Func - SRL_Func_Body
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SRL_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0); 
           Shift_Amt : in STD_LOGIC_VECTOR (4 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end SRL_Func;

architecture SRL_Func_Body of SRL_Func is
signal Data_Out : STD_LOGIC_VECTOR (31 downto 0);
signal Data_Zero_Flag : STD_LOGIC;
begin

    with Shift_Amt select
    Data_Out <= '0' & A_Source(31 downto 1) when "00001",
                "00" & A_Source(31 downto 2)  when "00010",
                "000" & A_Source(31 downto 3) when "00011",
                "0000" & A_Source(31 downto 4) when "00100",
                "00000" & A_Source(31 downto 5) when "00101",
                "000000" & A_Source(31 downto 6) when "00110",
                "0000000" & A_Source(31 downto 7) when "00111",
                "00000000" & A_Source(31 downto 8) when "01000",
                "000000000" & A_Source(31 downto 9) when "01001",
                "0000000000" & A_Source(31 downto 10) when "01010",
                "00000000000" & A_Source(31 downto 11) when "01011",
                "000000000000" & A_Source(31 downto 12) when "01100",
                "0000000000000" & A_Source(31 downto 13) when "01101",
                "00000000000000" & A_Source(31 downto 14) when "01110",
                "000000000000000" & A_Source(31 downto 15) when "01111",
                "0000000000000000" & A_Source(31 downto 16) when "10000",
                "00000000000000000" & A_Source(31 downto 17) when "10001",
                "000000000000000000" & A_Source(31 downto 18) when "10010",
                "0000000000000000000" & A_Source(31 downto 19)when "10011",
                "00000000000000000000" & A_Source(31 downto 20) when "10100",
                "000000000000000000000" & A_Source(31 downto 21) when "10101",
                "0000000000000000000000" & A_Source(31 downto 22) when "10110",
                "00000000000000000000000" & A_Source(31 downto 23) when "10111",
                "000000000000000000000000" & A_Source(31 downto 24) when "11000",
                "0000000000000000000000000" & A_Source(31 downto 25) when "11001",
                "00000000000000000000000000" & A_Source(31 downto 26) when "11010",
                "000000000000000000000000000" & A_Source(31 downto 27) when "11011",
                "0000000000000000000000000000" & A_Source(31 downto 28) when "11100",
                "00000000000000000000000000000" & A_Source(31 downto 29) when "11101",
                "000000000000000000000000000000" & A_Source(31 downto 30) when "11110",
                "0000000000000000000000000000000" & A_Source(31) when "11111",
                A_Source when others;
                
    with Data_Out select
    Data_Zero_Flag <= '1' when X"00000000",
                      '0' when others;
    Output_Val <= Data_Out;
    Zero_Flag <= Data_Zero_Flag;
    
end SRL_Func_Body;