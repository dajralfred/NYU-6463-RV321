----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.11.2021 03:10:30
-- Design Name: 
-- Module Name: Testbench_IM - tim_ach
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

entity Testbench_IM is
--  Port ( );
end Testbench_IM;

architecture tim_ach of Testbench_IM is 

signal t_clk : STD_LOGIC := '0';
signal t_rst : STD_LOGIC := '1';--*******
signal t_read_instr: STD_LOGIC := '1';
signal t_addr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
signal t_addr_in2: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');--*******
signal t_instr_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);
signal t_instr_out2: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);--*******
signal t_read_enable: STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of mem --*******

begin

dut: entity work.Instruction_Memory
    Port Map( 
    clk => t_clk,
    rst => t_rst,
    read_instr => t_read_instr,
    addr_in => t_addr_in,
    addr_in2 => t_addr_in2,
    instr_out => t_instr_out,
    instr_out2 => t_instr_out2,
    read_enable => t_read_enable
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
variable file_instr: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);

begin

    file_open(file_pointer,"main.mem",read_mode);
    readline(file_pointer,l);
    hread(l,file_instr);
    
    t_read_instr <= '1';
    wait for 10 ns;
    assert(t_instr_out=file_instr) report "The instruction output did not match the expected output!" severity FAILURE;
    t_read_instr <= '0';
    wait for 40 ns;
    
    while not endfile(file_pointer)loop
        readline(file_pointer,l);
        hread(l,file_instr);

        
        t_read_instr <= '1';
        t_addr_in <= t_addr_in + LENGTH_ADDR_BYTES;
        wait for 10 ns;
        assert(t_instr_out=file_instr) report "The instruction output did not match the expected output!" severity FAILURE;
        t_read_instr <= '0';
        wait for 40 ns;
        
    end loop;
 --******************************************************************************************--
    t_addr_in2 <= t_addr_in;
    t_read_enable <= "111";--read full word
    wait for 10 ns;
    assert(t_instr_out2=file_instr) report "The instruction-mem output did not match the expected output!" severity FAILURE;
    
    t_read_enable <= "011";--read full word
    wait for 10 ns;
    assert(t_instr_out2= (X"0000"&file_instr(15 downto 0)) ) report "The instruction-mem output did not match the expected output!" severity FAILURE;
    
    t_read_enable <= "001";--read full word
    wait for 10 ns;
    assert(t_instr_out2= (X"000000"&file_instr(7 downto 0)) ) report "The instruction-mem output did not match the expected output!" severity FAILURE;
        
    wait for 28 ns;
    t_rst <= '0';
    wait for 2 ns;
    t_rst <= '1';
    assert(t_instr_out2=X"00000000") report "The instruction-mem output did not reset as expected output!" severity FAILURE;    
    
    report "All tests passed successfully!";
    std.env.stop;

end process;

end tim_ach;
