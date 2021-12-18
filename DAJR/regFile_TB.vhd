----------------------------------------------------------------------------------
-- Company: NYU Tandon AHD
-- Engineer: 
-- 
-- Create Date: 11/16/2021
-- Design Name: 
-- Module Name: reg_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Register File
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE	WORK.RV321_pkg.ALL;



entity regFile_TB is
--  Port ( );
end regFile_TB;

architecture regFile_TB_Body of regFile_TB is

--Define the Mapping signal
-------------------------------------------------------------------------------------------
signal tClk, tWriteEnable: STD_LOGIC;
signal tReadReg1, tReadReg2, tWriteReg : std_logic_vector(4 downto 0);
signal tWriteData, tReadData1, tReadData2 : std_logic_vector(31 downto 0);
signal t_opc_in : std_logic_vector(9 downto 0); -- (funct3 & opcode) output needed for imm and data extension
signal t_state_in : StateType;
-------------------------------------------------------------------------------------------

signal period : time := 10 ns;

-------------------------------------------------------------------------------------------
begin

--map the port signals to the component signals
-------------------------------------------------------------------------------------------
uut: entity  work.reg_file PORT MAP( 
                  CLK => tClk,
                  ReadReg1 => tReadReg1,
                  ReadReg2 => tReadReg2,
                  WriteReg => tWriteReg,
                  WriteEnable => tWriteEnable,
                  WriteData => tWriteData,
                  ReadData1 => tReadData1,
                  ReadData2 => tReadData2,
                  opc_in => t_opc_in,
                  state_in => t_state_in
                  );

-- continuous clock
    CLK: process 
    begin
        tclk <= '0';
        wait for period/2;
        tclk <= '1';
        wait for period/2;
    end process;

-------------------------------------------------------------------------------------------
--Begin the REGISTER_TEST process: Begin the test simulations
REGISTER_TEST : process
begin
    
    ---------------------------------------------------------------------------------------
    -- case A, write to reg 0x03
    tWriteEnable <= '1';
    tReadReg1 <= "00001";
    tReadReg2 <= "00010";
    tWriteReg <= "00011";
    tWriteData <= X"89ABCDEF";

    wait for 1 * period;
    
        ---------------------------------------------------------------------------------------
    -- case b, write to  reg 0x02
    tWriteEnable <= '1';
    tReadReg1 <= "00001";
    tReadReg2 <= "00010";
    tWriteReg <= "00100";
    tWriteData <= X"01234567";

    wait for 1 * period;
    
    ------------------------------------------------------------------------------  
      
    -- case c, retrieve reg 0x03
    tWriteEnable <= '0';
    tReadReg1 <= "00100";
    tReadReg2 <= "00011";
    tWriteReg <= "00001";
    tWriteData <= "00000000000000000000000000000000";
    wait for 1 * period;
    assert (tReadData1 = X"01234567" and tReadData2 = X"89ABCDEF")-- expected output
    -- error will be reported if ReadData1 and ReadData2 do not contain correct value.
    report "Read Operation failed" severity failure;
    
      
    ------------------------------------------------------------------------------
      
    -- case d, try writing to reg 0x00 == R0 (a read-only register that is always hardwired to equal zero)
    tWriteEnable <= '1';
    tReadReg1 <= "00000";
    tReadReg2 <= "00000";
    tWriteReg <= "00000"; -- R0
    tWriteData <= X"01234567";
    wait for 1 * period;
    assert (tReadData1 = "00000000000000000000000000000000" and tReadData2 = "00000000000000000000000000000000" )-- expected output
    -- error will be reported if ReadData1 and ReadData2 do not contain all zeros value.
    report "R0 is not acting as read-only special register" severity failure;
    
      
    ------------------------------------------------------------------------------        

   report "ALL TESTCASES PASSED";
   std.env.stop;
end process;

end regFile_TB_Body;
