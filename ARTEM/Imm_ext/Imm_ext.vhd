----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/30/2021 07:10:13 PM
-- Design Name: 
-- Module Name: Imm_ext - Do_extension
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

entity Imm_ext is
    Port (
        imm_in: in std_logic_vector(31 downto 0);   --32 bits immediate from the Control Unit
        imm_out: out std_logic_vector(31 downto 0); --32 bits sign extended immetiate to the ALU
        opc_in: in std_logic_vector(9 downto 0)     --10 bits funct3 & opcode from the Control Unit
    );
end Imm_ext;

architecture Do_extension of Imm_ext is
    
    signal imm_12bit: std_logic_vector(11 downto 0); --12 valid bits from imm_in
    signal imm_20bit: std_logic_vector(19 downto 0); --20 valid bits from imm_in
    signal immediate: std_logic_vector(31 downto 0); --vector for temporary storage sign extended immediate
    signal prekey: std_logic_vector(9 downto 0);     --
    signal sign_ext_imm: std_logic;
    
begin
    
    prekey <= opc_in;
    
    with prekey select sign_ext_imm <= --sign_ext_imm assignment
        '0' when "0000110111" | --LUI
                 "0000010111" | --AUIPC
                 "0010010011" | --SLLI
                 "1010010011",  --SRLI and SRAI
        '1' when others; 

    imm_12bit(11 downto 0) <= imm_in(11 downto 0);
    imm_20bit(19 downto 0) <= imm_in(19 downto 0);
        
    process(imm_in, opc_in, sign_ext_imm, immediate, imm_12bit, imm_20bit) begin
        
        case opc_in(6 downto 0) is
        
            when R_TYPE =>
                immediate <= (others => '0');
                
            when I_TYPE_LOAD =>
                if(sign_ext_imm = '1') then
                    immediate <= std_logic_vector(resize(signed(imm_12bit), immediate'length));
                else
                    immediate <= (others => '0');
                end if;
                
            when I_TYPE_JALR =>
                if(sign_ext_imm = '1') then
                    immediate <= std_logic_vector(resize(signed(imm_12bit), immediate'length));
                else
                    immediate <= (others => '0');
                end if;
                
            when I_TYPE_OTHERS =>
                if (sign_ext_imm = '1') then
                    immediate <= std_logic_vector(resize(signed(imm_12bit), immediate'length));
                else
                    immediate <= std_logic_vector(resize(unsigned(imm_12bit(4 downto 0)), immediate'length));
                end if;
                                
            when S_TYPE =>
                if (sign_ext_imm = '1') then
                    immediate <= std_logic_vector(resize(signed(imm_12bit), immediate'length)); 
                else
                    immediate <= (others => '0');
                end if;
                
            when SB_TYPE =>
                if (sign_ext_imm = '1') then
                    immediate <= std_logic_vector(resize(signed(imm_12bit), immediate'length));
                else
                    immediate <= (others => '0');
                end if;
                
            when U_TYPE_LUI =>
                immediate <= imm_in;
                
            when U_TYPE_AUIPC =>
                immediate <= imm_in;
                
            when UJ_TYPE =>
                if (sign_ext_imm = '1') then
                    immediate <= std_logic_vector(resize(signed(imm_20bit), immediate'length));
                else
                    immediate <= (others => '0');
                end if;
                
            when others => immediate <= (others => '0');
            
        end case;
        
    end process;

    imm_out <= immediate;
    

end Do_extension;
