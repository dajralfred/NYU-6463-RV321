----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2021 17:44:57
-- Design Name: 
-- Module Name: Program_Counter - pc_ach
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

entity Program_Counter is
  Port (
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    advance_counter: IN STD_LOGIC := '0'; -- control signal to allow advance of PC (Write enable)
    use_next_addr: IN STD_LOGIC := '1'; -- Mux control signal to select PC addr input (1 to increment by 4)
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
    addr_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    addr_next: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
   );
end Program_Counter;

architecture pc_ach of Program_Counter is 

signal addr: std_logic_vector((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;

begin

process(rst, clk) begin --address
    if(rst='0') then 
        addr <= IM_START_ADDR;
    elsif(rising_edge(clk)) then
        if(advance_counter = '1') then
            if(use_next_addr = '1')then
                addr <= std_logic_vector((unsigned(addr))+ LENGTH_ADDR_BYTES);
            else
                addr <= addr_in;
            end if;
        end if;
    end if;
end process;

addr_out <= addr;
addr_next <= std_logic_vector((unsigned(addr))+ LENGTH_ADDR_BYTES);

end pc_ach;
