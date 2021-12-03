----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2021 10:32:44 PM
-- Design Name: 
-- Module Name: TB_Data_ext - test
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
use WORK.RV321_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_Data_ext is
--  Port ( );
end TB_Data_ext;

architecture test of TB_Data_ext is

    component Data_ext port (
        data_in: in std_logic_vector(31 downto 0);
        data_out: out std_logic_vector(31 downto 0);
        opc_in: in std_logic_vector(9 downto 0)
        );
    end component;
    
    --inputs
    signal tb_data_in: std_logic_vector(31 downto 0);
    signal tb_opc_in: std_logic_vector(9 downto 0);
    --output
    signal tb_data_out: std_logic_vector(31 downto 0);
    
begin
    
    uut: Data_ext port map (
        data_in => tb_data_in,
        data_out => tb_data_out,
        opc_in => tb_opc_in
    );
    
    TEST_Data_ext: process begin
        --I_TYPE_LOAD - lb
        tb_opc_in <= "000" & I_TYPE_LOAD;
        tb_data_in <= X"00000011";
        wait for 10ns;
        assert (tb_data_out = X"00000011") report "Test I_TYPE_LOAD(lb) failed!" severity FAILURE;
        tb_opc_in <= "000" & I_TYPE_LOAD;
        tb_data_in <= X"000000FA";
        wait for 10ns;
        assert (tb_data_out = X"FFFFFFFA") report "Test I_TYPE_LOAD(lb) failed!" severity FAILURE;
        
        --I_TYPE_LOAD - lh
        tb_opc_in <= "001" & I_TYPE_LOAD;
        tb_data_in <= X"00007D1A";
        wait for 10ns;
        assert (tb_data_out = X"00007D1A") report "Test I_TYPE_LOAD(lh) failed!" severity FAILURE;
        tb_opc_in <= "001" & I_TYPE_LOAD;
        tb_data_in <= X"0000A1B2";
        wait for 10ns;
        assert (tb_data_out = X"FFFFA1B2") report "Test I_TYPE_LOAD(lh) failed!" severity FAILURE;
        
        --I_TYPE_LOAD - lbu
        tb_opc_in <= "100" & I_TYPE_LOAD;
        tb_data_in <= X"00000022";
        wait for 10ns;
        assert (tb_data_out = X"00000022") report "Test I_TYPE_LOAD(lbu) failed!" severity FAILURE;
        tb_opc_in <= "100" & I_TYPE_LOAD;
        tb_data_in <= X"000000FA";
        wait for 10ns;
        assert (tb_data_out = X"000000FA") report "Test I_TYPE_LOAD(lbu) failed!" severity FAILURE;
        
        --I_TYPE_LOAD - lhu
        tb_opc_in <= "101" & I_TYPE_LOAD;
        tb_data_in <= X"00001234";
        wait for 10ns;
        assert (tb_data_out = X"00001234") report "Test I_TYPE_LOAD(lhu) failed!" severity FAILURE;
        tb_opc_in <= "101" & I_TYPE_LOAD;
        tb_data_in <= X"0000CB99";
        wait for 10ns;
        assert (tb_data_out = X"0000CB99") report "Test I_TYPE_LOAD(lhu) failed!" severity FAILURE;
        
        --others
        tb_opc_in <= "100" & I_TYPE_OTHERS; --xori
        tb_data_in <= X"000000D4";
        wait for 10ns;
        assert (tb_data_out = X"000000D4") report "Test I_TYPE_OTHERS(xori) failed!" severity FAILURE;
        tb_opc_in <= "000" & I_TYPE_OTHERS; --addi
        tb_data_in <= X"00000AC4";
        wait for 10ns;
        assert (tb_data_out = X"00000AC4") report "Test I_TYPE_OTHERS(xori) failed!" severity FAILURE;
        tb_opc_in <= "001" & U_TYPE_LUI; --lui
        tb_data_in <= X"000DE0A1";
        wait for 10ns;
        assert (tb_data_out = X"000DE0A1") report "Test U_TYPE_LUI(lui) failed!" severity FAILURE;
        tb_opc_in <= "101" & SB_TYPE; --bge
        tb_data_in <= X"005000A9";
        wait for 10ns;
        assert (tb_data_out = X"005000A9") report "Test SB_TYPE(bge) failed!" severity FAILURE;
        tb_opc_in <= "001" & S_TYPE; --sh
        tb_data_in <= X"0A07D007";
        wait for 10ns;
        assert (tb_data_out = X"0A07D007") report "Test S_TYPE(sh) failed!" severity FAILURE;
        
        report "ALL TESTCASES PASSED";
        std.env.stop;
        
    end process;
    
end test;
