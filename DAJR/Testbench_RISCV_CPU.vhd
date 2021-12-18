----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2021 18:20:51
-- Design Name: 
-- Module Name: Testbench_RISCV_CPU - tcpu_ach
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Testbench_RISCV_CPU is
--  Port ( );
end Testbench_RISCV_CPU;

architecture tcpu_ach of Testbench_RISCV_CPU is

signal t_clk: std_logic := '0';
signal t_rst: std_logic := '1'; --Active LOW, asynchronous
--signal t_cpu_out: std_logic_vector(31 downto 0); --output of cpu (to use --> write to register r0 using r_type, load or i_type_others instructions)
signal t_SW : std_logic_vector(15 downto 0) := (others => '0');
signal t_LED : std_logic_vector(15 downto 0) ;

begin

dut: entity work.NYU_6463_RV32I_Processor
  Port Map( 
    clk => t_clk,
    rst => t_rst, --Active LOW, asynchronous
    --cpu_out => t_cpu_out, --output of cpu (to use --> write to register r0 using r_type, load or i_type_others instructions)
    SW => t_SW,
    LED => t_LED
  );

CLK_GEN:process begin --10ns Period
    t_clk <= '0';
    wait for 5ns;
    t_clk <= '1';
    wait for 5ns;
end process;

MAIN_PROG: process begin
    -- assess initialization parameters
    wait for 200ns;
    t_SW <= "1000000000000001";
    wait for 40000ns;
    t_SW <= "0000000000010011";
    wait for 20000ns;
    t_SW <= "0000010000001111";
    wait for 39000ns;
    report("Program run to completion.");
    std.env.stop;
end process;

end tcpu_ach;
