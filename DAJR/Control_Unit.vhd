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
USE WORK.RV321_pkg.ALL; -- include the package to your design

entity Control_Unit is
  Port ( 
    clk: in std_logic := '0';
    rst: in std_logic := '1'; --Active LOW, asynchronous
    instr: in std_logic_vector(31 downto 0);--instruction input
    
    --pc_set: out std_logic_vector(1 downto 0) := "10"; --(use_addr_4 bit, advance PC bit)
    use_next_addr: OUT STD_LOGIC := '1'; --use PC+4 as PC input? 0 to use ALU output
    advance_counter: OUT STD_LOGIC := '0'; 
    
    
    
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
    --sign_ext_imm: out std_logic := '1'; --*****This will be handled by imm. ext. logic ******
    imm: out std_logic_vector(31 downto 0) := X"00000000"; -- immediate (numerical value)
    
    MEM_WE: out std_logic_vector( 2 downto 0) := "000"; --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
    MEM_RE: out std_logic_vector( 2 downto 0) := "000"; --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)
    --sign_ext_data: out std_logic := '0'; --zero for zero-extend --*****This will be handled by data. ext. logic *******
    
    use_alu: out std_logic := '1'; -- zero to use data_ram output
    
    compare: in std_logic := '0'; --comparison result from BC block
    
    opc_out: out std_logic_vector(9 downto 0) -- (funct3 & opcode) output needed for imm and data extension
  );
end Control_Unit;

architecture cu_ach of Control_Unit is

signal opc: opcode;
signal funct7: std_logic_vector(6 downto 0);
signal funct3: std_logic_vector(2 downto 0);
TYPE StateType IS (ST_1, ST_2, ST_3, ST_4, ST_STOP);
SIGNAL state : StateType := ST_4;
signal stop_flag : std_logic := '0';
signal opkey: std_logic_vector(16 downto 0);
signal prekey: std_logic_vector(9 downto 0);

begin

opc <= instr(6 downto 0);


with opc select funct3 <= 
    "000" when "0110111" | "0010111" | "1101111",
    instr(14 downto 12) when others;
    
prekey <= funct3 & opc;

opc_out <= prekey;

with prekey select funct7 <=
    instr(31 downto 25) when "1010110011" | "1010010011" | "0000110011",
    "0000000" when others;

opkey <= funct7 & funct3 & opc;


with opkey select alu_out <= --alu_out assignment
    ALU_SUB  when "01000000000110011",
    ALU_SLL  when "00000000010110011" | "00000000010010011",
    ALU_SLT  when "00000000100110011" | "00000000100010011",
    ALU_SLTU when "00000000110110011" | "00000000110010011",
    ALU_XOR  when "00000001000110011" | "00000001000010011",
    ALU_SRL  when "00000001010110011" | "00000001010010011",
    ALU_SRA  when "01000001010110011" | "01000001010010011",
    ALU_OR   when "00000001100110011" | "00000001100010011",
    ALU_AND  when "00000001110110011" | "00000001110010011",
    ALU_ADD  when others;

with prekey select bc_out <= --bc_out assignment
    BC_NE  when "0011100011",
    BC_LT  when "1001100011",
    BC_GE  when "1011100011",
    BC_LTU when "1101100011",
    BC_GEU when "1111100011",
    BC_EQ  when others;

with opc select rs1 <= --rs1 assignment
    "00000" when F_TYPE,
    instr(19 downto 15) when others; 

rs2  <= instr(24 downto 20);--rs2 assignment

with opc select rd  <= --rd assignment
    "00000" when F_TYPE,
    instr(11 downto  7) when others; 

with prekey select rd_input <= --rd_input assignment
    '0' when "0001101111" | "0001100111",
    '1' when others;
    
with prekey select use_rs1 <= --use_rs1 assignment
    '0' when "0000010111" | "0001101111" | (funct3 & "1100011"),
    '1' when others; 
    
with prekey select use_rs2 <= --use_rs2 assignment
    '1' when (funct3 & "0110011"),
    '0' when others; 
    
--with prekey select sign_ext_imm <= --sign_ext_imm assignment
--    '0' when "0000110111" | "0000010111" | "0010010011" | "1010010011",
--    '1' when others; 

with opc select imm <= --imm assignment
    X"00000" & instr(31 downto 20)                                                          when "0000011" | "1100111" | "0010011",
    X"00000" & instr(31 downto 25) & instr(11 downto 7)                                     when "0100011",
    "000" & X"0000" & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0' when "1100011",
    instr(31 downto 12) & X"000"                                                            when "0110111" | "0010111",
    "000" & X"00" & instr(31) & instr(30 downto 21) & instr(20) & instr(19 downto 12) & '0' when "1101111",
    (others => '0')                                                                         when others;

--with prekey select sign_ext_data <= --sign_ext_data assignment
--    '1' when "0000000011" | "0010000011",
--    '0' when others; 

with opc select use_alu <= --use_alu assignment
    '0' when "0000011",
    '1' when others;

with (compare&opc) select use_next_addr <= --use_next_addr assignment
    '0' when "11100011" | (compare & "1101111") | (compare & "1100111"),
    '1' when others;

process(rst,opc) begin--stop_flag process **********
    if(rst = '0') then
        stop_flag <= '0';
    elsif(opc = E_TYPE) then
        stop_flag <= '1';
    end if;
end process;





--***********************************************************************************************--
    
--state machine
PROCESS(rst, clk) BEGIN --4 clk cycle FSM
    IF(rst='0') THEN
        state <= ST_4;
        
    ELSIF(rising_edge(clk)) THEN
        IF(stop_flag = '1') THEN
            state <= ST_STOP;
        ELSE
            CASE state IS
                WHEN ST_1 =>
                    state <= ST_2;
                WHEN ST_2=>
                    state<=ST_3;
                WHEN ST_3=>
                    state <= ST_4;
                WHEN ST_4 =>
                    state <= ST_1;
                WHEN ST_STOP =>
                    if(stop_flag = '1') then
                        NULL;--state <= ST_STOP;
                    else
                        state <= ST_1;
                    end if;
            END CASE;
        END IF;
    END IF;
END PROCESS;


--***********************************************************************************************--

process(rst,state) begin --advance_counter
    if(rst = '0') then
        advance_counter <= '0';
    elsif(state'event) then
        if(state=ST_3) then
            advance_counter <= '1';
        else
            advance_counter <= '0';
        end if;
    end if;
end process;

process(rst,state) begin --read_instr
    if(rst='0') then
        read_instr <= '1';
    elsif(state'event) then
        if(state=ST_4) then
            read_instr <= '1';
        else
            read_instr <= '0';
        end if;
    end if;
end process;

process(rst,state) begin --REG_WE
    if(rst='0') then
        REG_WE <= '0';
    elsif(state'event) then
        if(state=ST_1) then
            if(opc = U_TYPE_AUIPC or opc = U_TYPE_LUI or opc = UJ_TYPE or opc = I_TYPE_JALR) then
                REG_WE <= '1';
            else
                REG_WE <= '0';
            end if;
            
        elsif(state=ST_2) then
            if(opc =R_TYPE or opc = I_TYPE_OTHERS or opc = F_TYPE) then
                REG_WE <= '1';
            else
                REG_WE <= '0';
            end if;
            
        elsif(state=ST_3) then
            if(opc = I_TYPE_LOAD) then
                REG_WE <= '1';
            else
                REG_WE <= '0';
            end if;
               
        else
            REG_WE <= '0';
        end if;
    end if;
end process;

process(rst,state) begin --MEM_WE
    if(rst='0') then
        MEM_WE <= "000";
    elsif(state'event) then
        if(state=ST_2) then
            if(prekey = ("000"&S_TYPE)) then
                MEM_WE <= "001";            
            elsif(prekey = ("001"&S_TYPE)) then
                MEM_WE <= "011";
            elsif(prekey = ("010"&S_TYPE)) then
                MEM_WE <= "111";
            else
                MEM_WE <= "000";
            end if;
   
        else
            MEM_WE <= "000";
        end if;
    end if;
end process;

process(rst,state) begin --MEM_RE
    if(rst='0') then
        MEM_RE <= "000";
    elsif(state'event) then
        if(state=ST_2) then
            if(prekey = ("000"&I_TYPE_LOAD) or prekey = ("100"&I_TYPE_LOAD)) then
                MEM_RE <= "001";            
            elsif(prekey = ("001"&I_TYPE_LOAD) or prekey = ("101"&I_TYPE_LOAD)) then
                MEM_RE <= "011";
            elsif(prekey = ("010"&I_TYPE_LOAD)) then
                MEM_RE <= "111";
            else
                MEM_RE <= "000";
            end if;
        
        else
            MEM_RE <= "000";
        end if;
    end if;
end process;


--***********************************************************************************************--

end cu_ach;
