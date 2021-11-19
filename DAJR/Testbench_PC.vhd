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

entity Testbench_PC is
--  Port ( );
end Testbench_PC;

architecture tpc_ach of Testbench_PC is

signal t_clk : std_logic := '0';
signal t_rst : std_logic := '1';
signal t_advance_counter: STD_LOGIC := '0'; -- control signal to allow advance of PC (Write enable)
signal t_use_next_addr: STD_LOGIC := '1'; -- Mux control signal to select PC addr input (1 to increment by 4)
signal t_addr_in: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
signal t_addr_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal t_addr_next: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');

begin
dut: entity work.Program_Counter
  Port Map(
    clk => t_clk,
    rst => t_rst, --asynchronous, active LOW
    advance_counter => t_advance_counter, -- control signal to allow advance of PC (Write enable)
    use_next_addr => t_use_next_addr, -- Mux control signal to select PC addr input (1 to increment by 4)
    addr_in => t_addr_in,
    addr_out => t_addr_out,
    addr_next => t_addr_next
   );
   
CLK_GEN:process begin --10ns Period
    t_clk <= '0';
    wait for 5ns;
    t_clk <= '1';
    wait for 5ns;
end process;

MAIN_PROG: process begin
    wait for 40 ns;
    t_advance_counter <= '1';
    wait for 60 ns;
    t_addr_in <= X"01000040";
    wait for 20 ns;
    t_use_next_addr <= '0';
    wait for 10ns;
    t_addr_in <= X"01000020";
    wait for 20ns;
    t_addr_in <= X"01000100";
    wait for 20ns;
    t_use_next_addr <= '1';
    wait for 40ns;
    t_rst <= '0';
    wait for 2ns;
    t_rst <= '1';
    wait for 28ns;
    t_advance_counter <= '0';
    wait for 20ns;
    report("Basic operation passed successfully!");
    std.env.stop;
    
end process;

end tpc_ach;
