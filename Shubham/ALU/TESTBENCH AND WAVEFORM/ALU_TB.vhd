----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2018 04:13:56 PM
-- Design Name: 
-- Module Name: ALU_TB - ALU_Body_TB
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

--Import the Custom designed Package file
use WORK.RV321_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------------
entity ALU_TB is
--  Port ( );
end ALU_TB;
----------------------------------------------------------------------------------
  
architecture ALU_Body_TB of ALU_TB is

component ALU
    Port ( SrcA : in STD_LOGIC_VECTOR (31 downto 0);
           SrcB : in STD_LOGIC_VECTOR (31 downto 0);
           ALU_Control : in ALUop;
           ALU_Result : out STD_LOGIC_VECTOR (31 downto 0);
           Flag_Zero : out STD_LOGIC;
           Flag_Negative : out STD_Logic);
end component;

----------------------------------------------------------------------------------
--Define Port signals
----------------------------------------------------------------------------------
signal A,B,ALU_Rslt : STD_LOGIC_VECTOR(31 downto 0);
signal Cntrl_Sig : ALUop;
signal Flg_Zero, Flg_Neg : STD_LOGIC;
----------------------------------------------------------------------------------

begin

----------------------------------------------------------------------------------
--Map the port signals to the component
----------------------------------------------------------------------------------
Map_Signals: ALU Port map( SrcA => A,
                                SrcB => B,
                                ALU_Control => Cntrl_Sig,
                                ALU_Result => ALU_Rslt,
                                Flag_Zero => Flg_Zero,
                                Flag_Negative => Flg_Neg);

----------------------------------------------------------------------------------

--Start the Test Process : Begin the simulation
----------------------------------------------------------------------------------
ALU_Test: process
begin

    --ADD
    A <= X"0000000A";
    B <= X"00000004";
    Cntrl_Sig <= ALU_ADD;
    wait for 10 ns;
    assert (ALU_Rslt = X"0000000E")  -- expected output
    -- error will be reported if ALU_Rslt is not E.
    report "test failed for ADD operation" severity error;
    ------------------------------------------------------------------------------

    --SUB
    A <= X"0000000A";
    B <= X"0000000A";
    Cntrl_Sig <= ALU_SUB;
    wait for 10 ns;    
    assert (ALU_Rslt = X"00000000")  -- expected output
    -- error will be reported if ALU_Rslt is not 0.
    report "test failed for SUB operation" severity error;
    ------------------------------------------------------------------------------

    --AND
    A <= X"0000000A";
    B <= X"00000004";
    Cntrl_Sig <= ALU_AND;
    wait for 10 ns; 
    assert (ALU_Rslt = X"00000000")  -- expected output
    -- error will be reported if ALU_Rslt is not 0.
    report "test failed for AND operation" severity error;
    ------------------------------------------------------------------------------

    --OR
    A <= X"0000000A";
    B <= X"00000004";
    Cntrl_Sig <= ALU_OR;
    wait for 10 ns;
    assert (ALU_Rslt = X"0000000E")  -- expected output
    -- error will be reported if ALU_Rslt is not E.
    report "test failed for OR operation" severity error;
    ------------------------------------------------------------------------------

    --XOR
    A <= X"0000000A";
    B <= X"00000004";
    Cntrl_Sig <= ALU_XOR;
    wait for 10 ns; 
    assert (ALU_Rslt = X"0000000E")  -- expected output
    -- error will be reported if ALU_Rslt is not 0000000E.
    report "test failed for XOR operation" severity error;
    ------------------------------------------------------------------------------

    --SLL
    A <= X"000000F0";
    B <= X"00000004";
    Cntrl_Sig <= ALU_SLL;
    wait for 10 ns;  
    assert (ALU_Rslt = X"00000F00")  -- expected output
    -- error will be reported if ALU_Rslt is not 00000F00.
    report "test failed for SLL operation" severity error;
    ------------------------------------------------------------------------------
    
    --SRL
    A <= X"000000F0";
    B <= X"00000004";
    Cntrl_Sig <= ALU_SRL;
    wait for 10 ns;  
    assert (ALU_Rslt = X"0000000F")  -- expected output
    -- error will be reported if ALU_Rslt is not 0000000F.
    report "test failed for SRL operation" severity error;
    ------------------------------------------------------------------------------

    --SRA
    A <= X"000000FA";
    B <= X"00000004";
    Cntrl_Sig <= ALU_SRA;
    wait for 10 ns;  
    assert (ALU_Rslt = X"A000000F")  -- expected output
    -- error will be reported if ALU_Rslt is not A000000F.
    report "test failed for SRA operation" severity error;
    ------------------------------------------------------------------------------

    --STLU
    A <= X"0000000E";
    B <= X"0000000F";
    Cntrl_Sig <= ALU_SLTU;
    wait for 10 ns;
    assert (Flg_Neg = '1')  -- expected output
    -- error will be reported if Flg_Neg is not 1.
    report "test failed for STLU operation" severity error;
    ------------------------------------------------------------------------------

    --STL
    A <= X"FFFFFFFE";
    B <= X"FFFFFFFF";
    Cntrl_Sig <= ALU_SLT;
    wait for 10 ns;
    assert (Flg_Neg = '1')  -- expected output
    -- error will be reported if Flg_Neg is not 1.
    report "test failed for STL operation" severity error;
    ------------------------------------------------------------------------------    
    
    assert false
       report "ALL TESTCASES PASSED"
       severity failure;

end process;


end ALU_Body_TB;
