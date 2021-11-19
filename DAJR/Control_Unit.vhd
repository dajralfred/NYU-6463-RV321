----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.11.2021 19:58:04
-- Design Name: 
-- Module Name: Control_Unit - cu_ach
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.opcodes.all;

entity Control_Unit is
  Port ( 
    clk: in std_logic := '0';
    rst: in std_logic := '1'; --Active LOW, asynchronous
    instr: in std_logic_vector(31 downto 0);--instruction input
    current_pc: in std_logic_vector(31 downto 0) := X"01000000"; --PC content for AUIPC
    
    pc_set: out std_logic_vector(1 downto 0) := "10"; --(use_addr_4 bit, advance PC bit)
    
    read_instr: OUT STD_LOGIC := '1'; --control signal used to enable read of next instruction
    
    rs1: out std_logic_vector(4 downto 0) := "00000"; 
    rs2: out std_logic_vector(4 downto 0) := "00000";
    rd: out std_logic_vector(4 downto 0) := "00000";
    REG_WE: out std_logic := '0'; --Reg write enable(stack)
    rd_input: out std_logic := '1'; -- 1 to use ALU/ RAM output & 0 to use PC+4
    
    bc_out: out BCop;
    
    alu_out: out ALUop;
    use_rs1: out std_logic := '1'; --to ALU input, 0 to use PC value
    use_rs2: out std_logic := '1'; --to ALU input, 0 to use imm value
    sign_ext_imm: out std_logic := '1';
    imm: out std_logic_vector(31 downto 0); -- immediate (numerical value)
    
    MEM_WE: out std_logic_vector( 2 downto 0); --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
    MEM_RE: out std_logic_vector( 2 downto 0); --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)
    sign_ext_data: out std_logic := '0'; --zero for zero-extend
    
    use_alu: out std_logic := '1'; -- zero to use data_ram output
    
    compare: in std_logic := '0'; --comparison result from BC block
    
    opc_out: out opcode -- opcode output needed for imm extension
  );
end Control_Unit;

architecture cu_ach of Control_Unit is

signal opc: opcode;
signal funct7: std_logic_vector(6 downto 0);
signal funct3: std_logic_vector(2 downto 0);
TYPE StateType IS (ST_1, ST_2, ST_3, ST_4, ST_STOP);
SIGNAL state : StateType := ST_1;
signal pc: std_logic_vector(1 downto 0) := "10";
signal stop_flag : std_logic := '0';

begin

opc <= instr(6 downto 0);
opc_out <= opc;
funct3 <= instr(14 downto 12);
funct7 <= instr(31 downto 25);
    
--state machine
PROCESS(rst, clk) BEGIN
    IF(rst='0') THEN
        state<=ST_1;
    ELSIF(rising_edge(clk)) THEN
        IF(stop_flag = '1') THEN
            state <= ST_STOP;
        ELSE
            CASE state IS
                WHEN ST_1 =>
                    state <= ST_1;
                WHEN ST_2=>
                    state<=ST_3;
                WHEN ST_3=>
                    state <= ST_4;
                WHEN ST_4 =>
                    state <= ST_1;
                WHEN ST_STOP =>
                    state <= ST_STOP;
            END CASE;
        END IF;
    END IF;
END PROCESS;


process(rst,clk) begin
    if(rst = '0') then
        
    elsif(rising_edge(clk)) then
        
        if(state = ST_1) then -- Read next instruction
            REG_WE <= '0';
            MEM_WE <= "000";
            MEM_RE <= "000";
            read_instr <= '1';
            pc <= "10";
        elsif(state = ST_2) then --Output control signals based on instruction
            read_instr <= '0';
            
            case opc is
        ----------------------------------------------------------------------------------        
                when R_TYPE =>
                    
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    use_rs1 <= '1';
                    use_rs2 <= '1';
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    use_alu <= '1';
                    
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
                
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    if(funct3 = "000" or funct3 = "001" or funct3 = "010") then
                        sign_ext_data <= '1'; 
                    else
                        sign_ext_data <= '0'; 
                    end if;
                    
                    use_alu <= '0';
                    
        ----------------------------------------------------------------------------------                
                when I_TYPE_JALR =>
                                                 
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '0';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
        ----------------------------------------------------------------------------------                
                when I_TYPE_OTHERS =>
                
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    --alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';                    
                    if(funct3 = "001" or funct3 = "101") then
                        sign_ext_imm <= '0';
                    else
                        sign_ext_imm <= '1';--if
                    end if;
                    
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
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
                                                        
        ----------------------------------------------------------------------------------                
                when S_TYPE =>
                
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);                    
                    --rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    --rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                    
                    imm(11 downto 5) <= instr(31 downto 25);
                    imm(4 downto 0) <= instr(11 downto 7);
                    
        ----------------------------------------------------------------------------------                
                when SB_TYPE =>
                    
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);                    
                    --rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    --rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    --alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                                        
                    imm(12) <= instr(31);
                    imm(11) <= instr(7);
                    imm(10 downto 5) <= instr(30 downto 25);
                    imm(4 downto 1) <= instr(11 downto 8);
                    
                    case funct3 is
                        when "000" => --Branch Equal
                            bc_out <= BC_EQ;
                                                        
                        when "001" => --Branch Not Equal
                            bc_out <= BC_NE;
                        
                        when "100" => --Branch Less Than
                            bc_out <= BC_LT;
                        
                        when "101" => --Branch Greater Than or Equal
                            bc_out <= BC_GE;
                        
                        when "110" => --Branch Less Than Unsigned
                            bc_out <= BC_LTU;
                        
                        when "111" => --Branch Greater Than or Equal Unsigned
                            bc_out <= BC_GEU;
                        
                        when others => 
                            bc_out <= BC_EQ;
                    end case;
                    
        ----------------------------------------------------------------------------------            
                when U_TYPE_LUI =>
                    
                    rs1 <= "00000";
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '0';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
                    imm(31 downto 12) <= instr(31 downto 12);
                    imm(11 downto 0) <= (others => '0');
        ----------------------------------------------------------------------------------            
                when U_TYPE_AUIPC =>
                    
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '0';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
                    imm(31 downto 12) <= instr(31 downto 12);
                    imm(11 downto 0) <= (others => '0');
        ----------------------------------------------------------------------------------
                when UJ_TYPE =>
                                        
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '0';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                    
                    imm(20) <= instr(31);
                    imm(19 downto 12) <= instr(19 downto 12);
                    imm(11) <= instr(20);
                    imm(10 downto 1) <= instr(30 downto 21);
                    
        ----------------------------------------------------------------------------------                
                when E_TYPE => stop_flag <= '1';
        ----------------------------------------------------------------------------------                
                when F_TYPE =>   
                
                    rs1 <= "00000";
                    --rs2 <= instr(24 downto 20);                    
                    rd <= "00000"; 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';                    
                    sign_ext_imm <= '0';
                    
                    imm <= (others => '0');
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';     
        ----------------------------------------------------------------------------------        
                when others => null;
                
            end case;
        
        elsif(state = ST_3) then -- run next section
             case opc is
        ----------------------------------------------------------------------------------        
                when R_TYPE =>
                
                    pc <= "10";
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    use_rs1 <= '1';
                    use_rs2 <= '1';
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    use_alu <= '1';
                    
                                        
        ----------------------------------------------------------------------------------            
                when I_TYPE_LOAD =>
                
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    
                    if(funct3 = "000" or funct3 = "100") then --read byte
                        MEM_RE <= "001";
                    elsif(funct3 = "001" or funct3 = "101") then --read half word
                        MEM_RE <= "011";
                    elsif(funct3 = "010") then
                        MEM_RE <= "111";
                    end if;
                    
                    if(funct3 = "000" or funct3 = "001" or funct3 = "010") then
                        sign_ext_data <= '1'; 
                    else
                        sign_ext_data <= '0'; 
                    end if;
                    
                    use_alu <= '0';
                    
        ----------------------------------------------------------------------------------                
                when I_TYPE_JALR =>
                    
                    pc <= "00";                             
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '0';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
        ----------------------------------------------------------------------------------                
                when I_TYPE_OTHERS =>
                    
                    pc <= "10";
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    --alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';                    
                    if(funct3 = "001" or funct3 = "101") then
                        sign_ext_imm <= '0';
                    else
                        sign_ext_imm <= '1';--if
                    end if;
                    
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';                  
                                                                            
        ----------------------------------------------------------------------------------                
                when S_TYPE =>
                    
                    pc <= "10";
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);                    
                    --rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    --rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    if(funct3 = "000") then --write byte
                        MEM_WE <= "001";
                    elsif(funct3 = "001") then --write hlf_wrd
                        MEM_WE <= "011";
                    elsif(funct3 = "010") then
                        MEM_WE <= "111";
                    end if;
                    
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                    
                    imm(11 downto 5) <= instr(31 downto 25);
                    imm(4 downto 0) <= instr(11 downto 7);
                    
        ----------------------------------------------------------------------------------                
                when SB_TYPE =>
                    
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);                    
                    --rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    --rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    --alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                                        
                    imm(12) <= instr(31);
                    imm(11) <= instr(7);
                    imm(10 downto 5) <= instr(30 downto 25);
                    imm(4 downto 1) <= instr(11 downto 8);
                    
                    if(compare = '1') then
                        pc <= "00";
                    else
                        pc <= "10";
                    end if;                   
        ----------------------------------------------------------------------------------            
                when U_TYPE_LUI =>
                    
                    pc <= "10";
                    rs1 <= "00000";
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '0';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
                    imm(31 downto 12) <= instr(31 downto 12);
                    imm(11 downto 0) <= (others => '0');
        ----------------------------------------------------------------------------------            
                when U_TYPE_AUIPC =>
                    
                    pc <= "10";
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '0';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
                    imm(31 downto 12) <= instr(31 downto 12);
                    imm(11 downto 0) <= (others => '0');
        ----------------------------------------------------------------------------------
                when UJ_TYPE =>
                    
                    pc <= "00";                    
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '0';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                    
                    imm(20) <= instr(31);
                    imm(19 downto 12) <= instr(19 downto 12);
                    imm(11) <= instr(20);
                    imm(10 downto 1) <= instr(30 downto 21);
                    
        ----------------------------------------------------------------------------------              
                when F_TYPE =>   
                    pc <= "10";
                    rs1 <= "00000";
                    --rs2 <= instr(24 downto 20);                    
                    rd <= "00000"; 
                    REG_WE <= '1';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';                    
                    sign_ext_imm <= '0';
                    
                    imm <= (others => '0');
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';          
        ----------------------------------------------------------------------------------         
                when others => null;
                
            end case;
            
            
            
            
            
        elsif(state = ST_4) then -- update PC section
            pc <= (pc or "01"); 
            case opc is
        ----------------------------------------------------------------------------------        
                when R_TYPE =>
                    
                    
                    REG_WE <= '0';
                    
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";                                       
                                        
        ----------------------------------------------------------------------------------            
                when I_TYPE_LOAD =>
                
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '1';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    
                    if(funct3 = "000" or funct3 = "100") then --read byte
                        MEM_RE <= "001";
                    elsif(funct3 = "001" or funct3 = "101") then --read half word
                        MEM_RE <= "011";
                    elsif(funct3 = "010") then
                        MEM_RE <= "111";
                    end if;
                    
                    if(funct3 = "000" or funct3 = "001" or funct3 = "010") then
                        sign_ext_data <= '1'; 
                    else
                        sign_ext_data <= '0'; 
                    end if;
                    
                    use_alu <= '0';
                    
        ----------------------------------------------------------------------------------                
                when I_TYPE_JALR =>
                    
                                                 
                    rs1 <= instr(19 downto 15);
                                        
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
        ----------------------------------------------------------------------------------                
                when I_TYPE_OTHERS =>
                
                    rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    --alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';                    
                    if(funct3 = "001" or funct3 = "101") then
                        sign_ext_imm <= '0';
                    else
                        sign_ext_imm <= '1';--if
                    end if;
                    
                    imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';                  
                                                                            
        ----------------------------------------------------------------------------------                
                when S_TYPE =>
                
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);                    
                    --rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    --rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    MEM_WE <= "000";
                                        
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                    
                    imm(11 downto 5) <= instr(31 downto 25);
                    imm(4 downto 0) <= instr(11 downto 7);
                    
        ----------------------------------------------------------------------------------                
                when SB_TYPE =>
                    
                    rs1 <= instr(19 downto 15);
                    rs2 <= instr(24 downto 20);                    
                    --rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    --rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    --alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';                                      
                                       
                           
        ----------------------------------------------------------------------------------            
                when U_TYPE_LUI =>
                    
                    rs1 <= "00000";
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';
                    sign_ext_imm <= '0';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
                    imm(31 downto 12) <= instr(31 downto 12);
                    imm(11 downto 0) <= (others => '0');
        ----------------------------------------------------------------------------------            
                when U_TYPE_AUIPC =>
                    
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '0';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';
                    
                    imm(31 downto 12) <= instr(31 downto 12);
                    imm(11 downto 0) <= (others => '0');
        ----------------------------------------------------------------------------------
                when UJ_TYPE =>
                                        
                    --rs1 <= instr(19 downto 15);
                    --rs2 <= instr(24 downto 20);                    
                    rd <= instr(11 downto 7); 
                    REG_WE <= '0';
                    rd_input <= '0';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '0';
                    use_rs2 <= '0';
                    sign_ext_imm <= '1';
                    --imm(11 downto 0) <= instr(31 downto 20);
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    
                    --sign_ext_data <= '1'; 
                                        
                    --use_alu <= '1';
                    
                    
        ----------------------------------------------------------------------------------                
                when F_TYPE =>   
                    
                    rs1 <= "00000";
                    --rs2 <= instr(24 downto 20);                    
                    rd <= "00000"; 
                    REG_WE <= '0';
                    rd_input <= '1';
                    
                    --bc_out <= BC_EQ;
                    
                    alu_out <= ALU_ADD;
                    use_rs1 <= '1';
                    use_rs2 <= '0';                    
                    sign_ext_imm <= '0';
                    
                    imm <= (others => '0');
                    
                    MEM_WE <= "000";
                    MEM_RE <= "000";
                    --sign_ext_data <= '1'; 
                                        
                    use_alu <= '1';          
        ---------------------------------------------------------------------------------- 
                when others => null;
                
            end case;
        end if;
    end if;
                    
end process;

pc_set <= pc;

end cu_ach;
