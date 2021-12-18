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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
USE	WORK.RV321_pkg.ALL;

entity reg_file is
    Port (
            CLK                  : in std_logic;
            ReadReg1, ReadReg2   : in std_logic_vector(4 downto 0);
            ReadData1, ReadData2 : out std_logic_vector(31 downto 0);
            WriteReg             : in std_logic_vector(4 downto 0);
            WriteData            : in std_logic_vector(31 downto 0);
            WriteEnable          : in std_logic;
            opc_in               : in std_logic_vector(9 downto 0); -- (funct3 & opcode) output needed for imm and data extension
            state_in             : in StateType
    );
end reg_file;

architecture reg_file_body of reg_file is

signal Reg32 : Register_Type := (others => (others => '0'));
signal stored_rs1: std_logic_vector(31 downto 0) := (others => '0');
signal same_flag : std_logic := '0'; --set when rd = rs1
signal opc_flag : std_logic := '0'; --set when JALR or I_TYPE_LOAD

begin

same_flag <= '1' when ReadReg1 = WriteReg else
             '0';
             
opc_flag <= '1' when opc_in(6 downto 0) = I_TYPE_JALR else
            '1' when opc_in(6 downto 0) = I_TYPE_LOAD else
            '0';           

process(clk) begin
    if(falling_edge(clk)) then
        if((same_flag = '1') and (state_in = ST_1) and (opc_flag = '1') ) then
            stored_rs1 <= Reg32(to_integer(unsigned(ReadReg1)));
        end if;
    end if;
end process;

process(CLK)--rd 
begin        
    if(rising_edge(CLK)) then
        if (WriteEnable = '1' and WriteReg /= "00000") then
            -- write
            Reg32(to_integer(unsigned(WriteReg))) <= WriteData;
        end if;
    end if;
end process;        

process(CLK) --rs1
begin        
    if(rising_edge(CLK)) then
       -- read
       if((same_flag = '1') and (opc_flag = '1')) then 
           ReadData1 <= stored_rs1;
       else
           ReadData1 <= Reg32(to_integer(unsigned(ReadReg1)));
       end if;
    end if;
end process; 

process(CLK) --rs2
begin        
    if(rising_edge(CLK)) then
           -- read
           ReadData2 <= Reg32(to_integer(unsigned(ReadReg2)));
    end if;
end process; 

end reg_file_body;
