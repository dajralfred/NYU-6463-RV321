----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2021 09:38:21 PM
-- Design Name: 
-- Module Name: Data_ext - Do_extension
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
use WORK.RV321_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Data_ext is
    Port (
        data_in: in std_logic_vector(31 downto 0);   --32 bits data from the DM
        data_out: out std_logic_vector(31 downto 0); --32 bits sign extended data to the MUX
        opc_in: in std_logic_vector(9 downto 0)      --10 bits funct3 & opcode from the Control Unit
    );
end Data_ext;

architecture Do_extension of Data_ext is
    
    signal data_Byte: std_logic_vector(7 downto 0);      --lower 8 valid bits from data_in
    signal data_HalfWord: std_logic_vector(15 downto 0); --lower 16 valid bits from data_in
    signal data: std_logic_vector(31 downto 0);          --vector for temporary storage sign extended data
    signal prekey: std_logic_vector(9 downto 0);         --
    signal sign_ext_data: std_logic;
    
begin
    
    prekey <= opc_in;
    
    with prekey select sign_ext_data <= --sign_ext_data assignment
        '1' when "0000000011" | "0010000011",
        '0' when others; 
    
    data_Byte(7 downto 0) <= data_in(7 downto 0);
    data_HalfWord(15 downto 0) <= data_in(15 downto 0);
    
    process(data_in, opc_in, sign_ext_data, data, data_Byte, data_HalfWord) begin
        
        case opc_in(6 downto 0) is
            when I_TYPE_LOAD =>
                if(sign_ext_data = '1') then
                    case opc_in(9 downto 7) is
                        when "000" => --lb (8 valid bits extend to signed 32 bits)
                            data <= std_logic_vector(resize(signed(data_Byte), data'length));
                        when "001" => --lh (16 valid bits extend to signed 32 bits)
                            data <= std_logic_vector(resize(signed(data_HalfWord), data'length));
                        when others => data <= data_in;
                    end case;      
                else
                    case opc_in(9 downto 7) is
                        when "100" => --lbu (8 valid bits extend to unsigned 32 bits)
                            data <= std_logic_vector(resize(unsigned(data_Byte), data'length));
                        when "101" => --lhu (16 valid bits extend to unsigned 32 bits)
                            data <= std_logic_vector(resize(unsigned(data_HalfWord), data'length));
                        when others => data <= data_in;
                    end case;
                end if;

            when others => data <= data_in;
        end case;
    
    end process;
    
    data_out <= data;
    
end Do_extension;

