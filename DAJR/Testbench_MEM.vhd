----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.12.2021 16:27:55
-- Design Name: 
-- Module Name: Testbench_MEM - tmem_ach
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

entity Testbench_MEM is
--  Port ( );
end Testbench_MEM;

architecture tmem_ach of Testbench_MEM is

signal t_clk : STD_LOGIC := '0';
signal t_rst : STD_LOGIC := '1'; --asynchronous, active LOW
       
       --(word write enable bits, write enable bit) 
signal t_MEM_WE: STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of mem
       
       --(word read enable bits, read enable bit) 
signal t_MEM_RE: STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of mem
signal t_addr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := DM_START_ADDR;
signal t_data_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal t_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal t_instr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0'); --***
signal t_SW_IN: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --********
signal t_LED_OUT: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --******

begin

dut: entity work.Memory
  Port Map( 
    clk => t_clk,
    rst => t_rst, --asynchronous, active LOW
    
    --(word write enable bits, write enable bit) 
    MEM_WE => t_MEM_WE, --control signal used to enable write of mem
    
    --(word read enable bits, read enable bit) 
    MEM_RE => t_MEM_RE, --control signal used to enable read of mem
    addr_in => t_addr_in,
    data_in => t_data_in,
    data_out => t_data_out,
    instr_in => t_instr_in,
    SW_IN => t_SW_IN,
    LED_OUT => t_LED_OUT
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
    -- assess initialization parameters
    t_addr_in <= DM_START_ADDR;
    wait for 10ns;
    
    -- enable word writing and write word
    t_MEM_WE <= "111";
    t_data_in <= X"89abcdef";
    wait for 10ns;
    
    -- change address and rewrite word
    t_addr_in <= t_addr_in + 8;
    wait for 10ns;
    
    -- disable write, change address, change data in to byte size
    t_addr_in <= t_addr_in + 8;
    t_MEM_WE <= "000";
    t_data_in <= X"00000011";
    wait for 10ns;
    
    --change address offset to 1
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    
    --write byte at this address
    t_MEM_WE <= "001";
    wait for 10ns;
    
    --change offset to 2 and write half word new data
    t_MEM_WE <= "011";
    t_data_in <= X"00003322";
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    
    
    
    --******* READ MODE *******--
    --disable write and enable word read
    -- change address to aligned address, read word and assert correct output
    t_MEM_WE <= "000";
    t_addr_in <= t_addr_in - 2;
    t_MEM_RE <= "111";
    wait for 10ns;
    assert(t_data_out = X"33221100") report "The output did not match the expected output!" severity FAILURE;
    
    --attempt word read at non-word aligned address and ensure output = 332211
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    assert(t_data_out(23 downto 0) = X"332211") report "The output did not match the expected output!" severity FAILURE;
    
    --verify byte at address + offet 1
    t_MEM_RE <= "001";
    wait for 10ns;
    assert(t_data_out = X"00000011") report "The output did not match the expected output!" severity FAILURE;
    
    --verify half-word at address + offet 2
    t_MEM_RE <= "011";
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    assert(t_data_out = X"00003322") report "The output did not match the expected output!" severity FAILURE;
    
    
    --verify byte at new aligned address
    t_MEM_RE <= "001";
    t_addr_in <= t_addr_in - (8+2);
    wait for 10ns;
    assert(t_data_out = X"000000ef") report "The output did not match the expected output!" severity FAILURE;
    
    --verify word at new aligned address
    t_MEM_RE <= "111";
    wait for 10ns;
    assert(t_data_out = X"89abcdef") report "The output did not match the expected output!" severity FAILURE;
    
    --reset and verify output = 0
    t_rst <= '0';
    wait for 10ns;
    assert(t_data_out = X"00000000") report "The output did not match the expected output!" severity FAILURE;
    
    --disable reset and read and ensure that output does not change
    t_rst <= '1';
    t_MEM_RE <= "000";
    wait for 10ns;
    assert(t_data_out = X"00000000") report "The output did not match the expected output!" severity FAILURE;
    
    --verify word written at initial address
    t_MEM_RE <= "111";
    t_addr_in <= t_addr_in - 8;
    wait for 10ns;
    assert(t_data_out = X"89abcdef") report "The output did not match the expected output!" severity FAILURE;
    
    report "All data memory tests passed successfully!";
    --std.env.stop;
    
--*************************************************************************************************************--
    t_addr_in <= NNUM_START_ADDR;
    
    file_open(file_pointer,"nnum.mem",read_mode);
    readline(file_pointer,l);
    hread(l,file_data);
    
    t_MEM_RE <= "111";
    wait for 10 ns;
    assert(t_data_out=file_data) report "The instruction output did not match the expected output!" severity FAILURE;
    t_MEM_RE <= "000";
    wait for 40 ns;
    
    t_rst <= '0';
    wait for 20ns;
    t_rst <= '1';
    assert(t_data_out=X"00000000") report "The instruction output did not match the expected output!" severity FAILURE;
    
    while not endfile(file_pointer)loop
        readline(file_pointer,l);
        hread(l,file_data);

        
        t_MEM_RE <= "111";
        t_addr_in <= t_addr_in + LENGTH_ADDR_BYTES;
        wait for 10 ns;
        assert(t_data_out=file_data) report "The instruction output did not match the expected output!" severity FAILURE;
        t_MEM_RE <= "000";
        wait for 40 ns;
        
    end loop;
    report "All N-number tests passed successfully!";
    --std.env.stop;

--*************************************************************************************************************--
    t_addr_in <= SW_START_ADDR;
    
    t_SW_IN <= X"ABCD";        
    
    t_MEM_RE <= "111"; -- read word
    wait for 10 ns;
    assert(t_data_out=X"0000ABCD") report "The instruction output did not match the expected output!" severity FAILURE;
    t_MEM_RE <= "000";
    wait for 40 ns;
    
    t_MEM_RE <= "011"; -- read half word
    wait for 10 ns;
    assert(t_data_out=X"0000ABCD") report "The instruction output did not match the expected output!" severity FAILURE;
    t_MEM_RE <= "000";
    wait for 40 ns;
    
    t_MEM_RE <= "001"; -- read byte
    wait for 10 ns;
    assert(t_data_out=X"000000CD") report "The instruction output did not match the expected output!" severity FAILURE;
    t_MEM_RE <= "000";
    wait for 40 ns;
    
    t_rst <= '0';
    wait for 20ns;
    assert(t_data_out=X"00000000") report "The instruction output did not match the expected output!" severity FAILURE;
    t_rst <= '1';
    assert(t_data_out=X"00000000") report "The instruction output did not match the expected output!" severity FAILURE;
    
    
    report "All switch tests passed successfully!";
    --std.env.stop;
    
--*************************************************************************************************************--
    t_addr_in <= LED_START_ADDR;
    
     -- assess initialization parameters
    wait for 10ns;
    
    -- enable word writing and write word
    t_MEM_WE <= "111";
    t_data_in <= X"89abcdef";
    wait for 10ns;
    
     --verify word written at initial address
    t_MEM_WE <= "000";
    t_MEM_RE <= "111";
    wait for 10ns;
    assert(t_data_out = X"89abcdef") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"cdef") report "The LED output did not match the expected output!" severity FAILURE;
    
    
    -- disable read
    t_MEM_RE <= "000";
    
    --write half word at this address
    t_MEM_WE <= "011";
    t_data_in <= X"00001100";
    wait for 10ns;    
    
    --change offset to 2 and write new data
    t_MEM_WE <= "001";
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
    t_MEM_WE <= "000";
    t_addr_in <= t_addr_in - 3;
    t_MEM_RE <= "111";
    wait for 10ns;
    assert(t_data_out = X"33221100") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
    
    --attempt word read at non-word aligned address and ensure output = 332211
    t_addr_in <= t_addr_in + 1;
    wait for 10ns;
    assert(t_data_out = X"00332211") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
    
    --verify byte at address + offset 1
    t_MEM_RE <= "001";
    wait for 10ns;
    assert(t_data_out = X"00000011") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"1100") report "The LED output did not match the expected output!" severity FAILURE;
    
    --verify half word at address + offet 2
    t_addr_in <= t_addr_in + 1;
    t_MEM_RE <= "011";
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
    t_MEM_RE <= "000";
    wait for 10ns;
    assert(t_data_out = X"00000000") report "The output did not match the expected output!" severity FAILURE;
    assert(t_LED_OUT = X"0000") report "The LED output did not match the expected output!" severity FAILURE;
    
   
    report "All LED tests passed successfully!";
    --std.env.stop;
--*************************************************************************************************************--   
    t_addr_in <= IM_START_ADDR;    
    wait for 10ns;
    t_instr_in <= X"FFFF46F0"; 
    wait for 10ns;
    assert(t_data_out = X"FFFF46F0") report "The output did not match the expected output!" severity FAILURE;
    
    
--*************************************************************************************************************--       
    report "All tests passed successfully!";
    std.env.stop;
    
end process;


end tmem_ach;
