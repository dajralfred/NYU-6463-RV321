----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/21/2021 07:49:04 AM
-- Design Name: 
-- Module Name: BranchCmp - BranchCmp_Body
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

--
use work.NYU_6463_RV32I_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------------------------------------------
entity BranchCmp is
    Port ( rs1        : in STD_LOGIC_VECTOR (31 downto 0); 
           rs2        : in STD_LOGIC_VECTOR (31 downto 0);
           BC_Control : in BCop;
           compare    : out STD_LOGIC
         );
end BranchCmp;
-----------------------------------------------------------------------------------------------
    
architecture BranchCmp_Body of BranchCmp is

--Instantiating the ALU Component:
-----------------------------------------------------------------------------------------------
component ALU is
    Port ( SrcA : in STD_LOGIC_VECTOR (31 downto 0);
           SrcB : in STD_LOGIC_VECTOR (31 downto 0);
           ALU_Control : in ALUop;
           ALU_Result : out STD_LOGIC_VECTOR (31 downto 0);
           Flag_Zero : out STD_LOGIC;
           Flag_Negative : out STD_Logic);
end component;  

--Define the intermediate signals   
    --Final result from ALU
signal ALU_Result : STD_LOGIC_VECTOR (31 downto 0);

    --Control signal to be given to ALU
signal ALU_Control : ALUop;

    --Zero Flags from ALU
signal Flag_Zero : STD_LOGIC;

    --Negative Flags from ALU
signal Flag_Negative : STD_Logic;

-----------------------------------------------------------------------------------------------
begin  
--Let's Map the ports to the respective components with intermediate signals
-----------------------------------------------------------------------------------------------
Map_Ports_Add:  ALU Port Map ( SrcA           => rs1,
                               SrcB           => rs2,
                               ALU_Control    => ALU_Control,
                               ALU_Result     => ALU_Result,
                               Flag_Zero      => Flag_zero,
                               Flag_Negative  => Flag_Negative);
-----------------------------------------------------------------------------------------------  
    
--Select the Intermediate Output Signals from one of the componets based on the requested ALU_Control
-----------------------------------------------------------------------------------------------

Select_Func: with BC_Control select
             ALU_Control <=  ALU_XOR  when BC_EQ, --Perform an XOR  on rs1 and rs2 to see if they are equal or not.
                             ALU_XOR  when BC_NE, --Perform an XOR  on rs1 and rs2 to see if they are not equal or not.
                             ALU_SLT  when BC_LT, --Perform an SLT  on rs1 and rs2 to see which is lesser.
                             ALU_SLT  when BC_GE, --Perform an SLT  on rs1 and rs2 to see which is greater or maybe equal.
                             ALU_SLTU when BC_LTU,--Perform an SLTU on rs1 and rs2 to see which is lesser.
                             ALU_SLTU when BC_GEU,--Perform an SLTU on rs1 and rs2 to see which is greater or maybe equal.
                             '0' when others;

Select_Func: with BC_Control select
             compare <=  Flag_Zero         when BC_EQ, --Flag_Zero     would be 1 if rs1 and rs2 are equal.
                         not Flag_Zero     when BC_NE, --Flag_Zero     would be 0 if rs1 and rs2 are not equal.
                         Flag_Negative     when BC_LT, --Flag_Negative would be 1 if rs1 is less than rs2.
                         NOT Flag_Negative when BC_GE, --Flag_Negative would be 0 if rs1 is greater than or equal to rs2.
                         Flag_Negative     when BC_LTU,--Flag_Negative would be 1 if rs1 is less than rs2.
                         NOT Flag_Negative when BC_GEU,--Flag_Negative would be 0 if rs1 is greater than or equal to rs2.
                         '0' when others;
end BranchCmp_Body;
-----------------------------------------------------------------------------------------------                           
-----------------------------------------------------------------------------------------------                           
