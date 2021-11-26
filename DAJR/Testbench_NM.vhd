----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2021 01:07:01
-- Design Name: 
-- Module Name: Testbench_NM - nm_ach
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
use std.textio.all;
use ieee.std_logic_textio.all;

entity Testbench_NM is
--  Port ( );
end Testbench_NM;

architecture nm_ach of Testbench_NM is

signal t_clk : STD_LOGIC := '0';
signal t_rst : STD_LOGIC := '1'; --asynchronous, active LOW
signal t_read_enable: STD_LOGIC_VECTOR(2 downto 0) := "000";
signal t_addr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := NNUM_START_ADDR;
signal t_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');

begin

dut: entity work.Nnum_Memory
    Port Map( 
    clk => t_clk,
    rst => t_rst, --asynchronous, active LOW
    read_enable => t_read_enable,
    addr_in => t_addr_in,
    data_out => t_data_out
  );

CLK_GEN:process begin --10ns Period
    t_clk <= '0';
    wait for 5ns;
    t_clk <= '1';
    wait for 5ns;
end process;

MAIN_PROG: process
file file_pointer: text;
variable l:line;
variable file_data: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);

begin

    file_open(file_pointer,"nnum.mem",read_mode);
    readline(file_pointer,l);
    hread(l,file_data);
    
    t_read_enable <= "111";
    wait for 10 ns;
    assert(t_data_out=file_data) report "The instruction output did not match the expected output!" severity FAILURE;
    t_read_enable <= "000";
    wait for 40 ns;
    
    t_rst <= '0';
    wait for 20ns;
    t_rst <= '1';
    assert(t_data_out=X"00000000") report "The instruction output did not match the expected output!" severity FAILURE;
    
    while not endfile(file_pointer)loop
        readline(file_pointer,l);
        hread(l,file_data);

        
        t_read_enable <= "111";
        t_addr_in <= t_addr_in + LENGTH_ADDR_BYTES;
        wait for 10 ns;
        assert(t_data_out=file_data) report "The instruction output did not match the expected output!" severity FAILURE;
        t_read_enable <= "000";
        wait for 40 ns;
        
    end loop;
    report "All tests passed successfully!";
    std.env.stop;

end process;


end nm_ach;
