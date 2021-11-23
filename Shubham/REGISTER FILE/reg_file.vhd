----------------------------------------------------------------------------------
-- Company: NYU Tandon AHD
-- Engineer: 
-- 
-- Create Date: 11/16/2021
-- Design Name: 
-- Module Name: reg_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Register File
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE	WORK.NYU_6463_RV32I_pkg.ALL;

entity reg_file is
    Port (
            CLK                  : in std_logic;
            ReadReg1, ReadReg2   : in std_logic_vector(4 downto 0);
            ReadData1, ReadData2 : out std_logic_vector(31 downto 0);
            WriteReg             : in std_logic_vector(4 downto 0);
            WriteData            : in std_logic_vector(31 downto 0);
            WriteEnable          : in std_logic;
            --reg_out              : out Register_Type -- to make the entire Statck register available to use.
    );
end reg_file;

architecture reg_file_body of reg_file is

signal Reg32 : Register_Type := (others => (others => '0'));

begin

    --reg_out <= Reg32;

    process(CLK)
    begin        
        if(rising_edge(CLK)) then
            if (WriteEnable = '1') then
                -- write
                Reg32(to_integer(unsigned(WriteReg))) <= WriteData;
            end if;
         
           -- read
           ReadData1 <= Reg32(to_integer(unsigned(ReadReg1)));
           ReadData2 <= Reg32(to_integer(unsigned(ReadReg2)));
       end if;
    end process;        

end reg_file_body;
