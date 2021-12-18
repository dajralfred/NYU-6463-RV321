----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2021 15:08:11
-- Design Name: 
-- Module Name: Testbench_LED - led_ach
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

entity Testbench_LED is
--  Port ( );
end Testbench_LED;

architecture led_ach of Testbench_LED is

signal t_clk : STD_LOGIC := '0';
signal t_rst : STD_LOGIC := '1'; --asynchronous, active LOW
signal t_write_enable: STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of data ram
signal t_read_enable: STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of data ram
signal t_addr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := LED_START_ADDR;
signal t_data_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal t_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal t_LED_OUT: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --******
    
begin

dut: entity work.Led_Memory
    Port Map( 
        clk => t_clk,
        rst => t_rst,
        write_enable => t_write_enable,
        read_enable => t_read_enable,
        addr_in => t_addr_in,
        data_in => t_data_in,
        data_out => t_data_out,
        LED_OUT => t_LED_OUT
  );

CLK_GEN:process begin --10ns Period
    t_clk <= '0';
    wait for 5ns;
    t_clk <= '1';
    wait for 5ns;
end process;

MAIN_PROG: process begin
    -- assess initialization parameters
    wait for 10ns;
    
    -- enable word writing and write word
    t_write_enable <= "111";
    t_data_in <= X"89abcdef";
    wait for 10ns;
    
     --verify word written at initial address
    t_write_enable <= "000";
    t_read_enable <= "111";
    wait for 10ns;
    assert(t_data_out = X"89abcdef") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"cdef") report "The LED output did not match the expected output!" severity FAILURE;
    
    -- disable read
    t_read_enable <= "000";
    
    --write half word at this address
    t_write_enable <= "011";
    t_data_in <= X"00001100";
    wait for 10ns;    
    
    --change offset to 2 and write new data
    t_write_enable <= "001";
    t_data_in <= X"00000022";
    t_addr_in <= t_addr_in + 2;
    wait for 10ns;
    
    --change offset to 3 and write new data
    t_data_in <= X"00000033";
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    
    --******* READ MODE *******--
    --disable write and enable word read
    -- change address to aligned address, read word and assert correct output
    t_write_enable <= "000";
    t_addr_in <= t_addr_in - 3;
    t_read_enable <= "111";
    wait for 10ns;
    assert(t_data_out = X"33221100") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
    
    --attempt word read at non-word aligned address and ensure output = 332211
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    assert(t_data_out = X"00332211") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
    
    --verify byte at address + offset 1
    t_read_enable <= "001";
    wait for 10ns;
    assert(t_data_out = X"00000011") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
    
    --verify half word at address + offet 2
    t_addr_in <= t_addr_in + 1;
    t_read_enable <= "011";
    wait for 10ns;
    assert(t_data_out = X"00003322") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
        
    --reset and verify output = 0
    t_rst <= '0';
    wait for 10ns;
    assert(t_data_out = X"00000000") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"0000") report "The LED output did not match the expected output!" severity FAILURE;
    
    --disable reset and read and ensure that output does not change
    t_rst <= '1';
    t_read_enable <= "000";
    wait for 10ns;
    assert(t_data_out = X"00000000") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"0000") report "The LED output did not match the expected output!" severity FAILURE;
    
   
    report "All tests passed successfully!";
    std.env.stop;
    
end process;


end led_ach;
