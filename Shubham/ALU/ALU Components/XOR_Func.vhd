----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 10:13:47 AM
-- Design Name: 
-- Module Name: XOR_Func - XOR_Func_Body
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
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity XOR_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           B_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end XOR_Func;

architecture XOR_Func_Body of XOR_Func is
signal Data_Out : STD_LOGIC_VECTOR (31 downto 0);
signal Data_Zero_Flag : STD_LOGIC;
begin

    Data_Out <= A_Source xor B_Source;
    with Data_Out select
        Data_Zero_Flag <= '1' when X"00000000",
                          '0' when others;
    Output_Val <= Data_Out;
    Zero_Flag <= Data_Zero_Flag;
end XOR_Func_Body;