----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.12.2021 14:02:02
-- Design Name: 
-- Module Name: Memory - mem_ach
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

entity Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    
    --(word write enable bits, write enable bit) 
    MEM_WE: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of mem
    
    --(word read enable bits, read enable bit) 
    MEM_RE: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of mem
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := DM_START_ADDR;
    data_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end Memory;

architecture mem_ach of Memory is

signal dm_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal num_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal sw_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
signal led_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');

component Data_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    --(word write enable bit, write enable bit) 
    write_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of data ram
    --(word read enable bit, read enable bit) 
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of data ram
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := DM_START_ADDR;
    data_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end component;

component Nnum_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of Nnumber
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := NNUM_START_ADDR;
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end component;

component Switch_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of mem
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := SW_START_ADDR;
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end component;

component Led_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    --(word write enable bit, write enable bit) 
    write_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of mem
    --(word read enable bit, read enable bit) 
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of mem
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := LED_START_ADDR;
    data_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
  );
end component;

begin

U1: Data_Memory 
  Port Map( 
    clk => clk,
    rst => rst, --asynchronous, active LOW
    --(word write enable bit, write enable bit) 
    write_enable => MEM_WE, --control signal used to enable write of data ram
    --(word read enable bit, read enable bit) 
    read_enable => MEM_RE, --control signal used to enable read of data ram
    addr_in => addr_in,
    data_in => data_in,
    data_out => dm_data_out
  );
  
U2: Nnum_Memory
  Port Map( 
    clk => clk,
    rst => rst, --asynchronous, active LOW
    read_enable => MEM_RE, --control signal used to enable read of Nnumber
    addr_in => addr_in,
    data_out => num_data_out
  );

U3: Switch_Memory
  Port Map( 
    clk => clk,
    rst => rst, --asynchronous, active LOW
    read_enable => MEM_RE, --control signal used to enable read of switches
    addr_in => addr_in,
    data_out => sw_data_out
  );
  
U4: Led_Memory
  Port Map( 
    clk => clk,
    rst => rst, --asynchronous, active LOW
    --(word write enable bit, write enable bit) 
    write_enable => MEM_WE, --control signal used to enable write of mem
    --(word read enable bit, read enable bit) 
    read_enable => MEM_RE, --control signal used to enable read of mem
    addr_in => addr_in,
    data_in => data_in,
    data_out => led_data_out
  );

--******************************************************************-- 
data_out <= (dm_data_out or num_data_out or sw_data_out or led_data_out);

        
end mem_ach;
