----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2021 10:42:39 PM
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

package OPCODES is
    subtype opcode is std_logic_vector(6 downto 0);
    
----------------------------------------------------------------------------------
-- Instruction types
-- R_TYPE : arithmetic and logical instructions (add, sub, sll, slt, sltu, xor, srl, sra, or, and)
-- I_TYPE_LOAD : instructions with immediates (lb, lh, lw, lbu, lhu,)
-- I_TYPE_JALR : instructions with immediates (jalr)
-- I_TYPE_OTHERS : instructions with immediates (addi, slli, slti, sltiu, xori, srli, srai, ori, andi)
-- S_TYPE : store instructions (sb, sh, sw)
-- SB_TYPE : branch instructions (beq, bne, blt, bge, bltu, bgeu)
-- U_TYPE_LUI : instructions with upper immediates (lui)
-- U_TYPE_AUIPC : instructions with upper immediates (auipc)
-- UJ-Format : jump instructions (jal)
----------------------------------------------------------------------------------   
    constant R_TYPE: opcode        := "0110011";
    constant I_TYPE_LOAD: opcode   := "0000011";
    constant I_TYPE_JALR: opcode   := "1100111";
    constant I_TYPE_OTHERS: opcode := "0010011";
    constant S_TYPE: opcode        := "0100011";
    constant SB_TYPE: opcode       := "1100011";
    constant U_TYPE_LUI: opcode    := "0110111";
    constant U_TYPE_AUIPC: opcode  := "0010111";
    constant UJ_TYPE: opcode       := "1101111";
    
    --control signals for ALU
    type ALUop is (
        ALU_ADD,
        ALU_SUB,
        ALU_SLL,
        ALU_SLT,
        ALU_SLTU,
        ALU_XOR,
        ALU_SRL,
        ALU_SRA,
        ALU_OR,
        ALU_AND
    );
    
end OPCODES;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.opcodes.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
    Port (
        
        instr: in std_logic_vector(31 downto 0);
        current_pc: in std_logic_vector(31 downto 0); --PC content for AUIPC
        rs1: out std_logic_vector(4 downto 0); 
        rs2: out std_logic_vector(4 downto 0);
        rd: out std_logic_vector(4 downto 0);
        imm: out std_logic_vector(31 downto 0);
        alu_out: out ALUop;
        en_MEM_Write: out std_logic;
        en_REG_Write: out std_logic;
        en_IMM: out std_logic;
        offset: out std_logic_vector(31 downto 0);
        pc_set: out std_logic_vector(1 downto 0);
        zero_flag: in boolean
        
        );
end control_unit;

architecture Behavioral of control_unit is
    
    signal opc: opcode;
    signal funct7: std_logic_vector(6 downto 0);
    signal funct3: std_logic_vector(2 downto 0);
    
begin
    
    opc <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);
    
    process(opc, funct7, funct3, zero_flag, current_pc) 
    
        variable auipc_offset: std_logic_vector(31 downto 0);
    
    begin
        
        rs1 <= instr(19 downto 15);
        rs2 <= instr(24 downto 20);
        rd <= instr(11 downto 7); 
        en_MEM_Write <= '0';
        en_REG_Write <= '0';
        en_IMM <= '0';
        imm <= (others => '0');
        alu_out <= ALU_ADD;
        offset <= (others => '0');
        pc_set <= "00";
        
        
        case opc is
----------------------------------------------------------------------------------        
            when R_TYPE =>
                
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '0';
                
                case funct3 is
                    when "000" => -- add or sub
                        case funct7 is
                            when "0000000" => alu_out <= ALU_ADD;
                            when others => alu_out <= ALU_SUB;
                        end case;
                    when "001" => -- sll
                        alu_out <= ALU_SLL;
                    when "010" => -- slt
                        alu_out <= ALU_SLT;
                    when "011" => -- sltu
                        alu_out <= ALU_SLTU;
                    when "100" => -- xor
                        alu_out <= ALU_XOR;
                    when "101" => -- srl or sra
                        case funct7 is
                            when "0000000" => alu_out <= ALU_SRL;
                            when others => alu_out <= ALU_SRA;
                        end case;
                    when "110" => -- or
                        alu_out <= ALU_OR;
                    when "111" => -- and
                        alu_out <= ALU_AND;
                    when others => alu_out <= ALU_ADD;
                end case;
                
----------------------------------------------------------------------------------            
            when I_TYPE_LOAD =>
            
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '1';
                
                alu_out <= ALU_ADD;
                
                if(instr(31) = '1') then 
                    --2's complement representation
                    imm(31 downto 12) <= (others => '0');
                    imm(11 downto 0) <= std_logic_vector(unsigned((not (instr(31 downto 20))) + 1));
                else
                    imm(31 downto 12) <= (others => '0');
                    imm(11 downto 0) <= instr(31 downto 20);
                end if;
                
                --imm(31 downto 12) <= (others => '0');
                --imm(11 downto 0) <= instr(31 downto 20);
                
----------------------------------------------------------------------------------                
            when I_TYPE_JALR =>
                
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '1';
                
                alu_out <= ALU_ADD;
                
                if(instr(31) = '1') then 
                    --2's complement representation
                    imm(31 downto 12) <= (others => '0');
                    imm(11 downto 0) <= std_logic_vector(unsigned((not (instr(31 downto 20))) + 1));
                else
                    imm(31 downto 12) <= (others => '0');
                    imm(11 downto 0) <= instr(31 downto 20);
                end if;
                
                --imm(31 downto 12) <= (others => '0');
                --imm(11 downto 0) <= instr(31 downto 20);

                pc_set <= "10";
                
----------------------------------------------------------------------------------                
            when I_TYPE_OTHERS =>
            
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '1';
                
                
                case funct3 is
                    when "000" => -- addi
                        if(instr(31) = '1') then --if imm is negative then ALU_SUB
                            alu_out <= ALU_SUB;
                        else
                            alu_out <= ALU_ADD;
                        end if;
                    when "001" => -- slli
                        alu_out <= ALU_SLL;
                    when "010" => -- slti
                        alu_out <= ALU_SLT;
                    when "011" => -- sltui
                        alu_out <= ALU_SLTU;
                    when "100" => -- xori
                        alu_out <= ALU_XOR;
                    when "101" => -- srli or srai
                        case funct7 is
                            when "0000000" => alu_out <= ALU_SRL;
                            when others => alu_out <= ALU_SRA;
                        end case;
                    when "110" => -- ori
                        alu_out <= ALU_OR;
                    when "111" => -- andi
                        alu_out <= ALU_AND;
                    when others => alu_out <= ALU_ADD;
                end case;
                
                --immediate (shift)
                case funct3 is
                    when "001" | "101" =>
                        imm(31 downto 5) <= (others => '0');
                        imm(4 downto 0) <= instr(24 downto 20);
                    when others =>
                        if(instr(31) = '1') then 
                            --2's complement representation
                            imm(31 downto 12) <= (others => '0');
                            imm(11 downto 0) <= std_logic_vector(unsigned((not (instr(31 downto 20))) + 1));
                        else
                            imm(31 downto 12) <= (others => '0');
                            imm(11 downto 0) <= instr(31 downto 20);
                        end if;
                        
                        --imm(31 downto 12) <= (others => '0');
                        --imm(11 downto 0) <= instr(31 downto 20);
                
                end case;
                
----------------------------------------------------------------------------------                
            when S_TYPE =>
            
                en_REG_Write <= '0';
                en_MEM_Write <= '1';
                en_IMM <= '1';
                
                alu_out <= ALU_ADD;
                
                imm(31 downto 12) <= (others => '0');
                imm(11 downto 5) <= instr(31 downto 25);
                imm(4 downto 0) <= instr(11 downto 7);
                
----------------------------------------------------------------------------------                
            when SB_TYPE =>
                
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '1';
                rd <= "00001"; --when branch
                
                offset(31 downto 13) <= (others => '0');
                offset(12) <= instr(31);
                offset(11) <= instr(7);
                offset(10 downto 5) <= instr(30 downto 25);
                offset(4 downto 1) <= instr(11 downto 8);
                offset(0) <= '0'; --lowest bit of offset is always zero
                
                case funct3 is
                    when "000" => --Branch Equal
                        alu_out <= ALU_AND;
                        case zero_flag is
                            when true =>
                                pc_set <= "01";
                            when others =>
                                offset <= (others => '0');
                        end case;
                        
                    when "001" => --Branch Not Equal
                        alu_out <= ALU_AND;
                        case zero_flag is
                            when false =>
                                pc_set <= "01";
                            when others =>
                             offset <= (others => '0');
                        end case;
                    
                    when "100" => --Branch Less Than
                        alu_out <= ALU_SLT;
                        case zero_flag is
                            when true =>
                                pc_set <= "01";
                            when others =>
                             offset <= (others => '0');
                        end case;
                    
                    when "101" => --Branch Greater Than or Equal
                        alu_out <= ALU_SLT;
                        case zero_flag is
                            when false =>
                                pc_set <= "01";
                            when others =>
                             offset <= (others => '0');
                        end case;
                    
                    when "110" => --Branch Less Than Unsigned
                        alu_out <= ALU_SLTU;
                        case zero_flag is
                            when true =>
                                pc_set <= "01";
                            when others =>
                             offset <= (others => '0');
                        end case;
                    
                    when "111" => --Branch Greater Than or Equal Unsigned
                        alu_out <= ALU_SLTU;
                        case zero_flag is
                            when false =>
                                pc_set <= "01";
                            when others =>
                             offset <= (others => '0');
                        end case;
                        
                    when others => offset <= (others => '0');
                end case;
                
----------------------------------------------------------------------------------            
            when U_TYPE_LUI =>
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '1';
                
                rs1 <= (others => '0');
                alu_out <= ALU_ADD;
                
                imm(31 downto 12) <= instr(31 downto 12);
                imm(11 downto 0) <= instr(11 downto 0);
                
----------------------------------------------------------------------------------            
            when U_TYPE_AUIPC =>
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                en_IMM <= '1';
                
                rs1 <= (others => '0');
                alu_out <= ALU_ADD;
                
                auipc_offset := instr(31 downto 12) & (11 downto 0 => '0');
                imm <= std_logic_vector(signed(current_pc) + signed(auipc_offset));
                
----------------------------------------------------------------------------------
            when UJ_TYPE =>
                
                pc_set <= "01";
                en_REG_Write <= '1';
                en_MEM_Write <= '0';
                
                offset(31 downto 21) <= (others => '0');
                offset(20) <= instr(31);
                offset(19 downto 12) <= instr(19 downto 12);
                offset(11) <= instr(20);
                offset(10 downto 1) <= instr(30 downto 21);
                offset(0) <= '0';
                
----------------------------------------------------------------------------------                
            when others => null;
            
        end case;
                
    end process;

end Behavioral;
