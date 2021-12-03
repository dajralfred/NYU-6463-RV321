----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2021 04:02:29 PM
-- Design Name: 
-- Module Name: TB_Imm_ext - test
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

entity TB_Imm_ext is
--  Port ( );
end TB_Imm_ext;

architecture test of TB_Imm_ext is

    component Imm_ext port (
        imm_in: in std_logic_vector(31 downto 0);
        imm_out: out std_logic_vector(31 downto 0);
        opc_in: in std_logic_vector(9 downto 0)
        );
    end component;
    
    --inputs
    --signal tb_clk: std_logic;
    signal tb_imm_in: std_logic_vector(31 downto 0);
    signal tb_sign_ext_imm: std_logic;
    signal tb_opc_in: std_logic_vector(9 downto 0);
    --output
    signal tb_imm_out: std_logic_vector(31 downto 0);
    
begin
    
    uut: Imm_ext port map (
        imm_in => tb_imm_in,
        imm_out => tb_imm_out,
        opc_in => tb_opc_in
    );
    
    TEST_Imm_ext: process begin
        
        --I_TYPE_LOAD
        tb_opc_in <= "000" & I_TYPE_LOAD; --lb
        tb_imm_in <= X"00000411";
        wait for 10ns;
        assert (tb_imm_out = X"00000411") report "Test I_TYPE_LOAD(lb) failed!" severity FAILURE;
        tb_opc_in <= "001" & I_TYPE_LOAD; --lh
        tb_imm_in <= X"00000AFD";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFAFD") report "Test I_TYPE_LOAD(lh) failed!" severity FAILURE;
        tb_opc_in <= "010" & I_TYPE_LOAD; --lw
        tb_imm_in <= X"00000D0D";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFD0D") report "Test I_TYPE_LOAD(lw) failed!" severity FAILURE;
        tb_opc_in <= "100" & I_TYPE_LOAD; --lbu
        tb_imm_in <= X"000006A3";
        wait for 10ns;
        assert (tb_imm_out = X"000006A3") report "Test I_TYPE_LOAD(lbu) failed!" severity FAILURE;
        tb_opc_in <= "101" & I_TYPE_LOAD; --lhu
        tb_imm_in <= X"00000C8A";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFC8A") report "Test I_TYPE_LOAD(lhu) failed!" severity FAILURE;
        
                
        --I_TYPE_JALR
        tb_opc_in <= "000" & I_TYPE_JALR;
        tb_imm_in <= X"00000649";
        wait for 10ns;
        assert (tb_imm_out = X"00000649") report "Test I_TYPE_JALR failed!" severity FAILURE;
        tb_imm_in <= X"00000AAA";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFAAA") report "Test I_TYPE_JALR failed!" severity FAILURE;
        
        --I_TYPE_OTHERS
        tb_opc_in <= "000" & I_TYPE_OTHERS; --addi
        tb_imm_in <= X"0000017F";
        wait for 10ns;
        assert (tb_imm_out = X"0000017F") report "Test I_TYPE_OTHERS(addi) failed!" severity FAILURE;
        tb_opc_in <= "001" & I_TYPE_OTHERS; --slli
        tb_imm_in <= X"00000E3A";
        wait for 10ns;
        assert (tb_imm_out = X"0000001A") report "Test I_TYPE_OTHERS(slli) failed!" severity FAILURE;
        tb_opc_in <= "010" & I_TYPE_OTHERS; --slti
        tb_imm_in <= X"000006AF";
        wait for 10ns;
        assert (tb_imm_out = X"000006AF") report "Test I_TYPE_OTHERS(slti) failed!" severity FAILURE;
        tb_opc_in <= "011" & I_TYPE_OTHERS; --sltiu
        tb_imm_in <= X"00000E97";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFE97") report "Test I_TYPE_OTHERS(sltiu) failed!" severity FAILURE;
        tb_opc_in <= "100" & I_TYPE_OTHERS; --xori
        tb_imm_in <= X"00000456";
        wait for 10ns;
        assert (tb_imm_out = X"00000456") report "Test I_TYPE_OTHERS(xori) failed!" severity FAILURE;
        tb_opc_in <= "101" & I_TYPE_OTHERS; --srli, srai
        tb_imm_in <= X"00000A1D";
        wait for 10ns;
        assert (tb_imm_out = X"0000001D") report "Test I_TYPE_OTHERS(srli, srai) failed!" severity FAILURE;
        tb_opc_in <= "110" & I_TYPE_OTHERS; --ori
        tb_imm_in <= X"00000FD2";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFFD2") report "Test I_TYPE_OTHERS(ori) failed!" severity FAILURE;
        tb_opc_in <= "111" & I_TYPE_OTHERS; --andi
        tb_imm_in <= X"000005FD";
        wait for 10ns;
        assert (tb_imm_out = X"000005FD") report "Test I_TYPE_OTHERS(andi) failed!" severity FAILURE;
        
        --S_TYPE
        tb_opc_in <= "000" & S_TYPE; --sb
        tb_imm_in <= X"00000A99";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFA99") report "Test S_TYPE(sb) failed!" severity FAILURE;
        tb_opc_in <= "001" & S_TYPE; --sh
        tb_imm_in <= X"00000001";
        wait for 10ns;
        assert (tb_imm_out = X"00000001") report "Test S_TYPE(sh) failed!" severity FAILURE;
        tb_opc_in <= "010" & S_TYPE; --sw
        tb_imm_in <= X"00000A09";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFA09") report "Test S_TYPE(sw) failed!" severity FAILURE;
        
        --SB_TYPE
        tb_opc_in <= "000" & SB_TYPE; --beq
        tb_imm_in <= X"00000788";
        wait for 10ns;
        assert (tb_imm_out = X"00000788") report "Test SB_TYPE(beq) failed!" severity FAILURE;
        tb_opc_in <= "001" & SB_TYPE; --bne
        tb_imm_in <= X"00000BBC";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFBBC") report "Test SB_TYPE(bne) failed!" severity FAILURE;
        tb_opc_in <= "100" & SB_TYPE; --blt
        tb_imm_in <= X"000006E8";
        wait for 10ns;
        assert (tb_imm_out = X"000006E8") report "Test SB_TYPE(blt) failed!" severity FAILURE;
        tb_opc_in <= "101" & SB_TYPE; --bge
        tb_imm_in <= X"00000CEB";        
        wait for 10ns;
        assert (tb_imm_out = X"FFFFFCEB") report "Test SB_TYPE(bge) failed!" severity FAILURE;
        tb_opc_in <= "110" & SB_TYPE; --bltu
        tb_imm_in <= X"00000333";
        wait for 10ns;
        assert (tb_imm_out = X"00000333") report "Test SB_TYPE(bltu) failed!" severity FAILURE;
        tb_opc_in <= "111" & SB_TYPE; --bgeu
        tb_imm_in <= X"000009A2";
        wait for 10ns;
        assert (tb_imm_out = X"FFFFF9A2") report "Test SB_TYPE(bgeu) failed!" severity FAILURE;
        
        --U_TYPE_LUI
        tb_opc_in <= "000" & U_TYPE_LUI;
        tb_imm_in <= X"87654000";
        wait for 10ns;
        assert (tb_imm_out = X"87654000") report "Test U_TYPE_LUI failed!" severity FAILURE;
        
        --U_TYPE_AUIPC
        tb_opc_in <= "000" & U_TYPE_AUIPC;
        tb_imm_in <= X"DEADB000";
        wait for 10ns;
        assert (tb_imm_out = X"DEADB000") report "Test U_TYPE_AUIPC failed!" severity FAILURE;
        
        --UJ_TYPE
        tb_opc_in <= "000" & UJ_TYPE;
        tb_imm_in <= X"0000A122";
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

end test;
