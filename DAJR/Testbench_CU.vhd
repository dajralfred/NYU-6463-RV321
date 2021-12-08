----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2021 01:50:42
-- Design Name: 
-- Module Name: Testbench_CU - cu_ach
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

entity Testbench_CU is
--  Port ( );
end Testbench_CU;

architecture cu_ach of Testbench_CU is 

signal t_clk: std_logic := '0';
signal t_rst: std_logic := '1'; --Active LOW, asynchronous
signal t_instr: std_logic_vector(31 downto 0);--instruction input
signal t_current_pc: std_logic_vector(31 downto 0) := X"01000000"; --PC content for AUIPC

signal t_use_next_addr: STD_LOGIC := '1'; --use PC+4 as PC input? 0 to use ALU output    
signal t_advance_counter: STD_LOGIC := '0';                                              

signal t_read_instr: STD_LOGIC := '1'; --control signal used to enable read of next instruction

signal t_rs1: std_logic_vector(4 downto 0) := "00000"; 
signal t_rs2: std_logic_vector(4 downto 0) := "00000";
signal t_rd: std_logic_vector(4 downto 0) := "00000";
signal t_REG_WE: std_logic := '0'; --Reg write enable(stack)
signal t_rd_input: std_logic := '1'; -- 1 to use ALU/ RAM output & 0 to use PC+4

signal t_bc_out: BCop;

signal t_alu_out: ALUop;
signal t_use_rs1: std_logic := '1'; --to ALU input, 0 to use PC value
signal t_use_rs2: std_logic := '1'; --to ALU input, 0 to use imm value
--signal t_sign_ext_imm: std_logic := '1';
signal t_imm: std_logic_vector(31 downto 0); -- immediate (numerical value)

signal t_MEM_WE: std_logic_vector( 2 downto 0); --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
signal t_MEM_RE: std_logic_vector( 2 downto 0); --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)
--signal t_sign_ext_data: std_logic := '0'; --zero for zero-extend

signal t_use_alu: std_logic := '1'; -- zero to use data_ram output

signal t_compare: std_logic := '0'; --comparison result from BC block

signal t_opc_out: opcode; -- opcode output needed for imm extension

begin

dut: entity work.Control_Unit
    Port Map( 
    clk => t_clk,
    rst => t_rst, --Active LOW, asynchronous
    instr => t_instr, --instruction input
    
    use_next_addr => t_use_next_addr, --use PC+4 as PC input? 0 to use ALU output
    advance_counter => t_advance_counter, 
    
    read_instr => t_read_instr, --control signal used to enable read of next instruction
    
    rs1 => t_rs1, 
    rs2 => t_rs2,
    rd => t_rd,
    REG_WE => t_REG_WE, --Reg write enable(stack)
    rd_input => t_rd_input, -- 1 to use ALU/ RAM output & 0 to use PC+4
    
    bc_out => t_bc_out,
    
    alu_out => t_alu_out,
    use_rs1 => t_use_rs1, --to ALU input, 0 to use PC value
    use_rs2 => t_use_rs2, --to ALU input, 0 to use imm value
    
    imm => t_imm, -- immediate (numerical value)
    
    MEM_WE => t_MEM_WE, --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
    MEM_RE => t_MEM_RE, --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)
    
    
    use_alu => t_use_alu, -- zero to use data_ram output
    
    compare => t_compare, --comparison result from BC block
    
    opc_out => t_opc_out -- opcode output needed for imm extension
  );

CLK_GEN:process begin --10ns Period
    t_clk <= '0';
    wait for 5ns;
    t_clk <= '1';
    wait for 5ns;
end process;


MAIN_PROG: process
file file_pointer: text open read_mode is "test.txt";
variable frow:line;
variable file_data: std_logic_vector(LENGTH_ADDR_BITS-1 downto 0);

begin

    --file_open(file_pointer,"test.txt",read_mode);
    readline(file_pointer,frow);
    hread(frow,file_data);      
    
    t_instr <= file_data;        
    wait for 40 ns;
        
    while not endfile(file_pointer)loop
        readline(file_pointer,frow);
        hread(frow,file_data);      
        
        t_instr <= file_data;        
        wait for 40 ns;
        
        --assert(t_data_out=file_data) report "The instruction output did not match the expected output!" severity FAILURE;
        
    end loop;
    report "All tests passed successfully!";
    std.env.stop;

end process;


end cu_ach;
