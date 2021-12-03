----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2018 04:13:56 PM
-- Design Name: 
-- Module Name: BC_TB - BC_Body_TB
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
entity BC_TB is
--  Port ( );
end BC_TB;
----------------------------------------------------------------------------------
  
architecture BC_Body_TB of BC_TB is


component BranchCmp is
    Port ( rs1        : in STD_LOGIC_VECTOR (31 downto 0); 
           rs2        : in STD_LOGIC_VECTOR (31 downto 0);
           BC_Control : in BCop;
           compare    : out STD_LOGIC
         );
end component;

----------------------------------------------------------------------------------
--Define Port signals
----------------------------------------------------------------------------------
signal rs1,rs2    : STD_LOGIC_VECTOR(31 downto 0);
signal BC_Control : BCop;
signal compare    : STD_LOGIC;
----------------------------------------------------------------------------------

begin

----------------------------------------------------------------------------------
--Map the port signals to the component
----------------------------------------------------------------------------------
Map_Signals: BranchCmp Port map(rs1        => rs1,
                                rs2        => rs2,
                                BC_Control => BC_Control,
                                compare    => compare
                               );

----------------------------------------------------------------------------------

--Start the Test Process : Begin the simulation
----------------------------------------------------------------------------------
BC_Test: process
begin

    --BC_EQ - 1
    rs1 <= X"0000000A";
    rs2 <= X"0000000A";
    BC_Control <= BC_EQ;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_EQ operation" severity error;
    ------------------------------------------------------------------------------

    --BC_EQ - 2
    rs1 <= X"0000000A";
    rs2 <= X"00000004";
    BC_Control <= BC_EQ;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_EQ operation" severity error;
    ------------------------------------------------------------------------------

    --BC_NE - 1
    rs1 <= X"0000000A";
    rs2 <= X"00000004";
    BC_Control <= BC_NE;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_NE operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_NE - 2
    rs1 <= X"0000000A";
    rs2 <= X"0000000A";
    BC_Control <= BC_NE;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_NE operation" severity error;
    ------------------------------------------------------------------------------ 
    
    --BC_LT - 1
    rs1 <= X"FFFFFFFE";
    rs2 <= X"FFFFFFFF";
    BC_Control <= BC_LT;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_LT operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_LT - 2
    rs1 <= X"FFFFFFFF";
    rs2 <= X"FFFFFFFE";
    BC_Control <= BC_LT;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_LT operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_LT - 3
    rs1 <= X"FFFFFFFE";
    rs2 <= X"FFFFFFFE";
    BC_Control <= BC_LT;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_LT operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_GE - 1
    rs1 <= X"FFFFFFFF";
    rs2 <= X"FFFFFFFE";
    BC_Control <= BC_GE;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_GE operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_GE - 2
    rs1 <= X"FFFFFFFE";
    rs2 <= X"FFFFFFFE";
    BC_Control <= BC_GE;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_GE operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_GE - 3
    rs1 <= X"FFFFFFFE";
    rs2 <= X"FFFFFFFF";
    BC_Control <= BC_GE;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_GE operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_LTU - 1
    rs1 <= X"00000004";
    rs2 <= X"0000000A";
    BC_Control <= BC_LTU;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_LTU operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_LTU - 2
    rs1 <= X"0000000A";
    rs2 <= X"00000004";
    BC_Control <= BC_LTU;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_LTU operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_LTU - 3
    rs1 <= X"0000000A";
    rs2 <= X"0000000A";
    BC_Control <= BC_LTU;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_LTU operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_GEU - 1
    rs1 <= X"0000000A";
    rs2 <= X"00000004";
    BC_Control <= BC_GEU;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_GEU operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_GEU - 2
    rs1 <= X"0000000A";
    rs2 <= X"0000000A";
    BC_Control <= BC_GEU;
    wait for 10 ns;
    assert (compare = '1')  -- expected output
    -- error will be reported if compare is not 1.
    report "test failed for BC_GEU operation" severity error;
    ------------------------------------------------------------------------------ 

    --BC_GEU - 3
    rs1 <= X"00000004";
    rs2 <= X"0000000A";
    BC_Control <= BC_GEU;
    wait for 10 ns;
    assert (compare = '0')  -- expected output
    -- error will be reported if compare is not 0.
    report "test failed for BC_GEU operation" severity error;
    ------------------------------------------------------------------------------ 
    
    assert false
       report "ALL TESTCASES PASSED"
       severity failure;

end process;


end BC_Body_TB;
