----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2021 07:49:04 AM
-- Design Name: 
-- Module Name: ALU - ALU_Body
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
use work.RV321_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------------------------------------------------
entity ALU is
    Port ( SrcA : in STD_LOGIC_VECTOR (31 downto 0);
           SrcB : in STD_LOGIC_VECTOR (31 downto 0);
           ALU_Control : in ALUop;
           ALU_Result : out STD_LOGIC_VECTOR (31 downto 0);
           Flag_Zero : out STD_LOGIC;
           Flag_Negative : out STD_Logic);
end ALU;
-----------------------------------------------------------------------------------------------
    
architecture ALU_Body of ALU is

--Instantiating the components of ALU namely
    --ADD
    --SUB
    --AND
    --OR
    --XOR
    --SLL
    --SRL
    --SRA
    --STL
    --STLU
-----------------------------------------------------------------------------------------------    
component ADD_Func
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           B_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------
component SUB_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           B_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------
component AND_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           B_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------
component OR_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           B_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------
component XOR_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           B_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------
component SLL_Func is
    Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
           Shift_Amt : in STD_LOGIC_VECTOR (4 downto 0);
           Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
           Zero_Flag : out STD_LOGIC);
end component;
 ----------------------------------------------------------------------------------------------- 
component SRL_Func is
  Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
         Shift_Amt : in STD_LOGIC_VECTOR (4 downto 0);
         Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
         Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------  
component SRA_Func is
  Port ( A_Source : in STD_LOGIC_VECTOR (31 downto 0);
         Shift_Amt : in STD_LOGIC_VECTOR (4 downto 0);
         Output_Val : out STD_LOGIC_VECTOR (31 downto 0);
         Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------
component SLT_Func is
    Port ( SrcA : in STD_LOGIC_VECTOR (31 downto 0);
           SrcB : in STD_LOGIC_VECTOR (31 downto 0);
           Negative_Flag_SLT : out STD_LOGIC;
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------  
component SLTU_Func is
    Port ( SrcA : in STD_LOGIC_VECTOR (31 downto 0);
           SrcB : in STD_LOGIC_VECTOR (31 downto 0);
           Negative_Flag_SLTU : out STD_LOGIC;
           Zero_Flag : out STD_LOGIC);
end component;
-----------------------------------------------------------------------------------------------

--Define the intermediate signals   
    --Final Output
signal ALU_Output : STD_LOGIC_VECTOR (31 downto 0);
    --Intermediate Output from each components
signal Output_Add, Output_Sub, Output_And, Output_Or, Output_Xor, Output_ShiftLL, Output_SRL, Output_SRA : STD_LOGIC_VECTOR (31 downto 0); 
    --Zero Flags from each components
signal Zero_Flg_Add, Zero_Flg_Sub, Zero_Flg_And, Zero_Flg_Or, Zero_Flg_Xor, Zero_Flg_ShiftLL, Zero_Flg_SRL, Zero_Flg_SRA, Zero_Flg_SLT, Zero_Flg_SLTU : STD_LOGIC;
    --Negative Flags from SLT and SLTU
signal Negative_Flag_SLT, Negative_Flag_SLTU  : STD_LOGIC;
-----------------------------------------------------------------------------------------------
begin

--Let's Map the ports to the respective components with intermediate signals
-----------------------------------------------------------------------------------------------
Map_Ports_Add:  ADD_Func Port Map ( A_Source => SrcA,
                                    B_Source => SrcB,
                                    Output_Val => Output_Add,
                                    Zero_Flag => Zero_Flg_Add);
-----------------------------------------------------------------------------------------------                               
Map_Ports_Sub:  SUB_Func Port Map ( A_Source => SrcA,
                                         B_Source => SrcB,
                                         Output_Val => Output_Sub,
                                         Zero_Flag => Zero_Flg_Sub);                                
-----------------------------------------------------------------------------------------------
Map_Ports_And:  AND_Func Port Map ( A_Source => SrcA,
                                    B_Source => SrcB,
                                    Output_Val => Output_And,
                                    Zero_Flag => Zero_Flg_And);
-----------------------------------------------------------------------------------------------                               
Map_Ports_Or:  OR_Func Port Map ( A_Source => SrcA,
                                  B_Source => SrcB,
                                  Output_Val => Output_Or,
                                  Zero_Flag => Zero_Flg_Or);
-----------------------------------------------------------------------------------------------
Map_Ports_Xor: XOR_Func Port Map ( A_Source => SrcA,
                                   B_Source => SrcB,
                                   Output_Val => Output_Xor,
                                   Zero_Flag => Zero_Flg_Xor);
-----------------------------------------------------------------------------------------------                          
Map_Ports_SLL: SLL_Func Port Map ( A_Source => SrcA,
                                          Shift_Amt => SrcB(4 downto 0),
                                          Output_Val => Output_ShiftLL,
                                          Zero_Flag => Zero_Flg_ShiftLL);
-----------------------------------------------------------------------------------------------
Map_Ports_SRL: SRL_Func Port Map ( A_Source => SrcA,
                                          Shift_Amt => SrcB(4 downto 0),
                                          Output_Val => Output_SRL,
                                          Zero_Flag => Zero_Flg_SRL);
-----------------------------------------------------------------------------------------------
Map_Ports_SRA: SRA_Func Port Map ( A_Source => SrcA,
                                          Shift_Amt => SrcB(4 downto 0),
                                          Output_Val => Output_SRA,
                                          Zero_Flag => Zero_Flg_SRA);
-----------------------------------------------------------------------------------------------
Map_Ports_SLT: SLT_Func Port Map ( SrcA => SrcA,
                                    SrcB => SrcB,
                                    Negative_Flag_SLT => Negative_Flag_SLT,
                                    Zero_Flag => Zero_Flg_SLT);
-----------------------------------------------------------------------------------------------
Map_Ports_SLTU: SLTU_Func Port Map ( SrcA => SrcA,
                                  SrcB => SrcB,
                                  Negative_Flag_SLTU => Negative_Flag_SLTU,
                                  Zero_Flag => Zero_Flg_SLTU);
-----------------------------------------------------------------------------------------------                
                                                                              
--Select the Intermediate Output Signals from one of the componets based on the requested ALU_Control
-----------------------------------------------------------------------------------------------
Select_Func: with ALU_Control select
             ALU_Output <= Output_Add when ALU_ADD,
                           Output_Sub when ALU_SUB,
                           Output_ShiftLL when ALU_SLL,
                           Output_Xor when ALU_XOR,
                           Output_SRL when ALU_SRL,
                           Output_SRA when ALU_SRA,
                           Output_Or when ALU_OR,
                           Output_And when ALU_AND,
                           X"00000000" when others;

--Select the Intermediate Zero Flag Signals from one of the componets based on the requested ALU_Control
-----------------------------------------------------------------------------------------------
Select_Zero_Flag: with ALU_Control select
             Flag_Zero <= Zero_Flg_Add when ALU_ADD,
                           Zero_Flg_Sub when ALU_SUB,
                           Zero_Flg_ShiftLL when ALU_SLL,
                           Zero_Flg_SLT when ALU_SLT,
                           Zero_Flg_SLTU when ALU_SLTU,
                           Zero_Flg_Xor when ALU_XOR,
                           Zero_Flg_SRL when ALU_SRL,
                           Zero_Flg_SRA when ALU_SRA,
                           Zero_Flg_Or when ALU_OR,
                           Zero_Flg_And when ALU_AND,
                           '0' when others;

--Select the Intermediate Negative signals from one of the componets based on the requested ALU_Control
-----------------------------------------------------------------------------------------------                           
Select_Negative_Flag: with ALU_Control select
                      Flag_Negative <= Negative_Flag_SLT when ALU_SLT,
                                                   Negative_Flag_SLTU when ALU_SLTU,
                      '0' when others;

-----------------------------------------------------------------------------------------------                           
ALU_Result <= ALU_Output;
-----------------------------------------------------------------------------------------------                           

end ALU_Body;
-----------------------------------------------------------------------------------------------                           
-----------------------------------------------------------------------------------------------                           
