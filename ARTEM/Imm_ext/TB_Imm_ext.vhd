----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2021 08:15:53 PM
-- Design Name: 
-- Module Name: TB_Imm_ext - Behavioral
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
use work.OPCODES.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_Imm_ext is
--  Port ( );
end TB_Imm_ext;

architecture Behavioral of TB_Imm_ext is
    
    component Imm_ext port (
        imm_in: in std_logic_vector(31 downto 0);
        imm_out: out std_logic_vector(31 downto 0);
        sign_ext_imm: in std_logic;
        opc_in: in std_logic_vector(6 downto 0)
        );
    end component;
    
    --inputs
    signal tb_clk: std_logic;
    signal tb_imm_in: std_logic_vector(31 downto 0);
    signal tb_sign_ext_imm: std_logic;
    signal tb_opc_in: std_logic_vector(6 downto 0);
    --output
    signal tb_imm_out: std_logic_vector(31 downto 0);
    
begin
    
    uut: Imm_ext port map (
        imm_in => tb_imm_in,
        imm_out => tb_imm_out,
        sign_ext_imm => tb_sign_ext_imm,
        opc_in => tb_opc_in
    );
    
    CLK_GEN: process begin
        tb_clk <= '0';
        wait for 10ns;
        tb_clk <= '1';
        wait for 10ns;
    end process;
    
    TEST_Imm_ext: process begin
        
        --I_TYPE_LOAD
        tb_opc_in <= I_TYPE_LOAD;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"00000411";
        wait for 10ns;
        assert (tb_imm_out = X"00000000") report "Test I_TYPE_LOAD failed!" severity FAILURE;
        tb_sign_ext_imm <= '1';
        wait for 10ns;
        assert (tb_imm_out = X"00000411") report "Test I_TYPE_LOAD failed!" severity FAILURE;
        tb_imm_in <= X"00000D0D";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFD0D") report "Test I_TYPE_LOAD failed!" severity FAILURE;
                
        --I_TYPE_JALR
        tb_opc_in <= I_TYPE_JALR;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"00000649";
        wait for 10ns;
        assert (tb_imm_out = X"00000000") report "Test I_TYPE_JALR failed!" severity FAILURE;
        tb_sign_ext_imm <= '1';
        wait for 10ns;
        assert (tb_imm_out = X"00000649") report "Test I_TYPE_JALR failed!" severity FAILURE;
        tb_imm_in <= X"00000AAA";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFAAA") report "Test I_TYPE_JALR failed!" severity FAILURE;
        
        --I_TYPE_OTHERS
        tb_opc_in <= I_TYPE_OTHERS;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"0000017F";
        wait for 10ns;
        assert (tb_imm_out = X"0000001F") report "Test I_TYPE_OTHERS failed!" severity FAILURE;
        tb_sign_ext_imm <= '1';
        wait for 10ns;
        assert (tb_imm_out = X"0000017F") report "Test I_TYPE_OTHERS failed!" severity FAILURE;
        tb_imm_in <= X"00000E3A";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFE3A") report "Test I_TYPE_OTHERS failed!" severity FAILURE;
        
        --S_TYPE
        tb_opc_in <= S_TYPE;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"0000000A";
        wait for 10ns;
        assert (tb_imm_out = X"00000000") report "Test S_TYPE failed!" severity FAILURE;
        tb_sign_ext_imm <= '1';
        wait for 10ns;
        assert (tb_imm_out = X"0000000A") report "Test S_TYPE failed!" severity FAILURE;
        tb_imm_in <= X"00000A09";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFA09") report "Test S_TYPE failed!" severity FAILURE;
        
        --SB_TYPE
        tb_opc_in <= SB_TYPE;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"00000788";
        wait for 10ns;
        assert (tb_imm_out = X"00000000") report "Test SB_TYPE failed!" severity FAILURE;
        tb_sign_ext_imm <= '1';
        wait for 10ns;
        assert (tb_imm_out = X"00000788") report "Test SB_TYPE failed!" severity FAILURE;
        tb_imm_in <= X"00000814";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFF814") report "Test SB_TYPE failed!" severity FAILURE;
        
        --U_TYPE_LUI
        tb_opc_in <= U_TYPE_LUI;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"87654000";
        wait for 10ns;
        assert (tb_imm_out = X"87654000") report "Test U_TYPE_LUI failed!" severity FAILURE;
        
        --U_TYPE_AUIPC
        tb_opc_in <= U_TYPE_AUIPC;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"DEADB000";
        wait for 10ns;
        assert (tb_imm_out = X"DEADB000") report "Test U_TYPE_AUIPC failed!" severity FAILURE;
        
        --UJ_TYPE
        tb_opc_in <= UJ_TYPE;
        tb_sign_ext_imm <= '0';
        tb_imm_in <= X"0000A122";
        wait for 10ns;
        assert (tb_imm_out = X"00000000") report "Test UJ_TYPE failed!" severity FAILURE;
        tb_sign_ext_imm <= '1';
        wait for 10ns;
        assert (tb_imm_out = X"0000A122") report "Test UJ_TYPE failed!" severity FAILURE;
        tb_imm_in <= X"000CD552";
        wait for 10ns;
        assert (tb_imm_out = X"FFFCD552") report "Test UJ_TYPE failed!" severity FAILURE;
        
        --others
        tb_opc_in <= (others => '0');
        tb_imm_in <= X"0D40A122";
        wait for 10ns;
        assert (tb_imm_out = X"00000000") report "Test OTHERS failed!" severity FAILURE;
        
        
        report "ALL TESTCASES PASSED";
        std.env.stop;
    end process;
    
end Behavioral;
