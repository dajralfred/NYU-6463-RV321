----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2021 02:15:59
-- Design Name: 
-- Module Name: Testbench_SW - sw_ach
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating 
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
USE WORK.RV321_pkg.ALL; -- include the package to your design

entity Testbench_SW is
--  Port ( );
end Testbench_SW;

architecture sw_ach of Testbench_SW is

signal t_clk : STD_LOGIC := '0';
signal t_rst : STD_LOGIC := '1'; --asynchronous, active LOW
signal t_read_enable: STD_LOGIC_VECTOR(2 downto 0) := "000";
signal t_addr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := SW_START_ADDR;
signal t_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);
signal t_SW_IN: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --********

begin

dut: entity work.Switch_Memory
    Port Map( 
    clk => t_clk,
    rst => t_rst, --asynchronous, active LOW
    read_enable => t_read_enable,
    addr_in => t_addr_in,
    data_out => t_data_out,
    SW_IN => t_SW_IN
  );

CLK_GEN:process begin --10ns Period
    t_clk <= '0';
    wait for 5ns;
    t_clk <= '1';
    wait for 5ns;
end process;

MAIN_PROG: process begin
    
    t_SW_IN <= X"ABCD";
    
    t_read_enable <= "111"; -- read word
    wait for 10 ns;
    assert(t_data_out=X"0000ABCD") report "The instruction output did not match the expected output!" severity FAILURE;
    t_read_enable <= "000";
    wait for 40 ns;
    
    
    t_read_enable <= "011"; -- read half word
    wait for 10 ns;
    assert(t_data_out=X"0000ABCD") report "The instruction output did not match the expected output!" severity FAILURE;
    t_read_enable <= "000";
    wait for 40 ns;
    
    
    t_read_enable <= "001"; -- read byte
    wait for 10 ns;
    assert(t_data_out=X"000000CD") report "The instruction output did not match the expected output!" severity FAILURE;
    t_read_enable <= "000";
    wait for 40 ns;
    
    
    t_rst <= '0';
    wait for 10ns;
    assert(t_data_out=X"00000000") report "The instruction output did not match the expected output!" severity FAILURE;
    t_SW_IN <= X"0000";
    t_rst <= '1';
    wait for 10ns;
    assert(t_data_out=X"00000000") report "The instruction output did not match the expected output!" severity FAILURE;
    
    
    report "All tests passed successfully!";
    std.env.stop;

end process;

end sw_ach;
