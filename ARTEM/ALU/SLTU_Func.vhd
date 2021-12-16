----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 04:19:45 PM
-- Design Name: 
-- Module Name: SLTU_Func - Behavioral
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

entity SLTU_Func is
    Port (   SrcA                : in STD_LOGIC_VECTOR (31 downto 0);
             SrcB                : in STD_LOGIC_VECTOR (31 downto 0);
             Negative_Flag_SLTU  : out STD_LOGIC;
             Zero_Flag           : out STD_LOGIC;
             ----------------------------------------------------------------
             Output_Val          : out STD_LOGIC_VECTOR (31 downto 0)); --new
             ----------------------------------------------------------------
end SLTU_Func;

architecture Behavioral of SLTU_Func is
  
  signal Diff_Val : unsigned (31 downto 0);
  signal Data_Zero_Flag : STD_LOGIC := '0';

  begin

      Diff_Val <= unsigned(SrcA) - unsigned(SrcB);

      with Diff_Val select
          Data_Zero_Flag <= '1' when X"00000000",
                            '0' when others;

      Zero_Flag <= Data_Zero_Flag;                                               
      Negative_Flag_SLTU <= std_logic(Diff_Val(31)); 
      
      --------------------------------------------------
      --new block for Output_val
      process(SrcA, SrcB) begin
        if(unsigned(SrcA) < unsigned(SrcB)) then
            Output_Val <= X"00000001";
        else
            Output_Val <= (others => '0');
        end if;
      end process;
      --------------------------------------------------
          
  end Behavioral;
