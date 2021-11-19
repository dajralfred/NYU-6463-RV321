----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/17/2021 07:00:53 PM
-- Design Name: 
-- Module Name: tb_control_unit - Behavioral
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
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use work.opcodes.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_control_unit is
--  Port ( );
end tb_control_unit;

architecture Behavioral of tb_control_unit is
    
    component control_unit port (
        clk: in std_logic;
        clr: in std_logic;
        instr: in std_logic_vector(31 downto 0);
        current_pc: in std_logic_vector(31 downto 0); --PC content for AUIPC
        rs1: out std_logic_vector(4 downto 0); 
        rs2: out std_logic_vector(4 downto 0);
        rd: out std_logic_vector(4 downto 0);
        imm: out std_logic_vector(31 downto 0);
        en_IMM: out std_logic;
        alu_out: out ALUop;
        en_MEM_Write: out std_logic;
        en_REG_Write: out std_logic;
        offset: out std_logic_vector(31 downto 0);
        pc_set: out std_logic_vector(1 downto 0);
        zero_flag: in boolean;
        enable: in std_logic
        );
    end component;
    
    file file_pointer: text;
    
    --inputs
    signal tb_clk: std_logic;
    signal tb_clr: std_logic := '1';
    signal tb_instr: std_logic_vector(31 downto 0);
    signal tb_current_pc: std_logic_vector(31 downto 0) := X"12345678"; --PC content for AUIPC
    signal tb_zero_flag: boolean;
    signal tb_enable: std_logic := '1';
    
    --outputs
    signal tb_rs1: std_logic_vector(4 downto 0); 
    signal tb_rs2: std_logic_vector(4 downto 0);
    signal tb_rd: std_logic_vector(4 downto 0);
    signal tb_imm: std_logic_vector(31 downto 0);
    signal tb_alu_out: ALUop;
    signal tb_en_MEM_Write: std_logic;
    signal tb_en_REG_Write: std_logic;
    signal tb_en_IMM: std_logic;
    signal tb_offset: std_logic_vector(31 downto 0);
    signal tb_pc_set: std_logic_vector(1 downto 0);
    
    --clock period
    constant tb_clk_period : time := 10ns;
    
begin

    uut: control_unit port map (
        clk => tb_clk,
        clr => tb_clr,
        instr => tb_instr,
        current_pc => tb_current_pc,
        zero_flag => tb_zero_flag,
        rs1 => tb_rs1,
        rs2 => tb_rs2,
        rd => tb_rd,
        imm => tb_imm,
        alu_out => tb_alu_out,
        en_MEM_Write => tb_en_MEM_Write,
        en_REG_Write => tb_en_REG_Write,
        en_IMM => tb_en_IMM,
        offset => tb_offset,
        pc_set => tb_pc_set,
        enable => tb_enable
    );
    
    CLK_GEN: process begin
        tb_clk <= '0';
        wait for 5ns;
        tb_clk <= '1';
        wait for 5ns;
    end process;
    
    process 
    
        variable file_line: line;
        variable input: std_logic_vector(31 downto 0);
        variable file_space: character;
        variable immediate: std_logic_vector(11 downto 0);
        variable offset_test: std_logic_vector(11 downto 0);
        variable reg_dest: std_logic_vector(1 downto 0);
        variable reg_source_1: std_logic_vector(1 downto 0);
        variable reg_source_2: std_logic_vector(1 downto 0);
        
    begin
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_R_type.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = R_TYPE) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, reg_source_1);
            read(file_line, file_space);
            hread(file_line, reg_source_2);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
        end loop;
        file_close(file_pointer);
        report"R_Type is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_I_type_others.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = I_TYPE_OTHERS) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, reg_source_1);
            read(file_line, file_space);
            hread(file_line, immediate);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;

            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"I_Type_Others is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_I_type_load.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = I_TYPE_LOAD) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, reg_source_1);
            read(file_line, file_space);
            hread(file_line, immediate);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;

            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"I_Type_Load is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_I_type_jalr.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = I_TYPE_JALR) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, reg_source_1);
            read(file_line, file_space);
            hread(file_line, immediate);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"I_Type_Jalr is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_S_type.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = S_TYPE) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, reg_source_1);
            read(file_line, file_space);
            hread(file_line, immediate);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"S_Type is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_SB_type.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = SB_TYPE) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_source_1);
            read(file_line, file_space);
            hread(file_line, reg_source_2);
            read(file_line, file_space);
            hread(file_line, offset_test);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"SB_Type is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_U_type_lui.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = U_TYPE_LUI) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, offset_test);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"U_Type_Lui is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_U_type_auipc.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = U_TYPE_AUIPC) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, immediate);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"U_Type_Auipc is OK!";
        
        wait for 10ns;--tb_clk_period;
        file_open(file_pointer, "Test_inputs_UJ_type.txt", read_mode);
        
        while not endfile(file_pointer) loop
            
            tb_clr <= '0';
            readline(file_pointer, file_line);
            hread(file_line, input);
            assert(input'length = 32) report"Input is not 32 bits" severity FAILURE;
            assert(input(6 downto 0) = UJ_TYPE) report"Wrong opcode" severity FAILURE;
            read(file_line, file_space);
            hread(file_line, reg_dest);
            read(file_line, file_space);
            hread(file_line, offset_test);
                        
            wait for tb_clk_period/2;
            tb_clr <= '1';
            tb_instr <= input;
            
            wait for tb_clk_period/2;
            
        end loop;
        file_close(file_pointer);
        report"UJ_Type is OK!";
        
    wait;
    end process;

end Behavioral;
