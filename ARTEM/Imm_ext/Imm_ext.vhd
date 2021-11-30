----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2021 01:20:46 PM
-- Design Name: 
-- Module Name: Imm_ext - Behavioral
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
use work.OPCODES.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Imm_ext is
    Port (
        imm_in: in std_logic_vector(31 downto 0);
        imm_out: out std_logic_vector(31 downto 0);
        sign_ext_imm: in std_logic;
        opc_in: in std_logic_vector(6 downto 0)    
    );
end Imm_ext;

architecture Behavioral of Imm_ext is
    
    signal imm_12bit: std_logic_vector(11 downto 0);
    signal imm_20bit: std_logic_vector(19 downto 0);
    signal immediate: std_logic_vector(31 downto 0);
   
begin
        
    imm_12bit(11 downto 0) <= imm_in(11 downto 0);
    imm_20bit(19 downto 0) <= imm_in(19 downto 0);
        
    process(imm_in, opc_in, sign_ext_imm, immediate, imm_12bit, imm_20bit) begin
        
        case opc_in is
        
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
    
end Behavioral;
