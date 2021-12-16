----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/10/2021 01:35:57 PM
-- Design Name: 
-- Module Name: TB_RISC_V - Behavioral
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
use WORK.RV321_PKG.ALL; -- include the package to your design
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TB_RISC_V is
--  Port ( );
end TB_RISC_V;

architecture Behavioral of TB_RISC_V is

component NYU_6463_RV32I_Processor port (
        clk: in std_logic := '0';
        rst: in std_logic := '1'; --Active LOW, asynchronous
    
        --cpu_out: out std_logic_vector(31 downto 0); --output of cpu (to use --> write to register r0 using r_type, load or i_type_others instructions)
        SW: in std_logic_vector(15 downto 0) := (others => '0');
        LED: out std_logic_vector(15 downto 0)
        );
    end component;
    
    signal tb_clk: std_logic;
    signal tb_rst: std_logic := '1';
    --signal tb_cpu_out: std_logic_vector(31 downto 0);
    signal t_SW : std_logic_vector(15 downto 0) := (others => '0');
    signal t_LED : std_logic_vector(15 downto 0) ;

begin
    
    RV32: entity work.NYU_6463_RV32I_Processor port map(
        clk => tb_clk,
        rst => tb_rst,
        --cpu_out => tb_cpu_out
        SW => t_SW,
        LED => t_LED
    );
    
    CLK_GEN: process begin
        tb_clk <= '0';
        wait for 5ns;
        tb_clk <= '1';
        wait for 5ns;
    end process;
    
    process
           
    begin
        wait for 350ns;
        
        std.env.stop;
    end process;
    
end Behavioral;
