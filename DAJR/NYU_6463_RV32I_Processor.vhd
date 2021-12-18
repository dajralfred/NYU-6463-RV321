----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.12.2021 17:04:23
-- Design Name: 
-- Module Name: NYU_6463_RV32I_Processor - cpu_ach
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

entity NYU_6463_RV32I_Processor is
  Port ( 
    clk: in std_logic := '0';
    rst: in std_logic := '1'; --Active LOW, asynchronous
    
    --cpu_out: out std_logic_vector(31 downto 0); --output of cpu (to use --> write to register r0 using r_type, load or i_type_others instructions)
    
    SW : in std_logic_vector(15 downto 0) := (others => '0');
    LED : out std_logic_vector(15 downto 0) := (others => '0')
  );
end NYU_6463_RV32I_Processor;

architecture cpu_ach of NYU_6463_RV32I_Processor is

--************************************************************************--
--Muxes
signal rd_mux : std_logic_vector(31 downto 0); --to regfile

signal alu_mux_1 : std_logic_vector(31 downto 0); --to ALU input 1
signal alu_mux_2 : std_logic_vector(31 downto 0); --to ALU input 2

signal output_mux : std_logic_vector(31 downto 0) := (others => '0'); --to rd (& CPU output)

--************************************************************************--
--Control signals

signal t_use_next_addr: STD_LOGIC := '1'; --use PC+4 as PC input? 0 to use ALU output
signal t_advance_counter: STD_LOGIC := '0'; 

signal t_read_instr: STD_LOGIC := '1'; --control signal used to enable read of next instruction

signal t_rs1: std_logic_vector(4 downto 0) := "00000"; 
signal t_rs2: std_logic_vector(4 downto 0) := "00000";
signal t_rd: std_logic_vector(4 downto 0) := "00000";
signal t_REG_WE: std_logic := '0'; --Reg write enable(stack)
signal t_rd_input: std_logic := '1'; -- 1 to use ALU/ RAM output & 0 to use PC+4

signal t_bc_out: BCop;

signal t_alu_out: ALUop;
signal t_use_rs1: std_logic := '1'; --to ALU input, 0 to use PC value
signal t_use_rs2: std_logic := '1'; --to ALU input, 0 to use imm value

signal t_imm: std_logic_vector(31 downto 0) := X"00000000"; -- immediate (numerical value)

signal t_MEM_WE: std_logic_vector( 2 downto 0) := "000"; --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
signal t_MEM_RE: std_logic_vector( 2 downto 0) := "000"; --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)

signal t_use_alu: std_logic := '1'; -- zero to use data_ram output

signal t_compare: std_logic := '0'; --comparison result from BC block

signal t_opc_out: std_logic_vector(9 downto 0); -- (funct3 & opcode) output needed for imm and data extension

signal t_state_out : StateType := ST_4;

--************************************************************************--
--Other signals
signal t_pc_addr_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0'); --PC out to IM and alu_mux_1
signal t_pc_addr_next: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0'); --current PC+4

--IM
signal t_instr: std_logic_vector(31 downto 0);--instruction output to Control Unit
signal t_instr2: std_logic_vector(31 downto 0);--instruction output to Memory

--regfile
signal t_ReadData1 : std_logic_vector(31 downto 0); 
signal t_ReadData2 : std_logic_vector(31 downto 0);


--imm. ext.
signal t_imm_out: std_logic_vector(31 downto 0); --32 bits sign extended immediate to alu_mux_2

--ALU
signal t_ALU_RESULT: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0); --input of pc from alu output

--MEM
signal t_mem_data_out: STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');

--data ext.
signal t_data_ext: std_logic_vector(31 downto 0); --32 bits sign extended data to output_mux

--************************************************************************--
--I/O
signal t_SW : std_logic_vector(15 downto 0) := (others => '0');
signal t_LED : std_logic_vector(15 downto 0) := (others => '0');
signal out_con_sig: std_logic_vector(13 downto 0); --output control signal of cpu
signal sig_cpu_out: std_logic_vector(31 downto 0); --output of cpu

--************************************************************************--
--Unused
signal t_Flag_Zero : STD_LOGIC; --Unused CSVR reg signal from ALU             *************
signal t_Flag_Negative : STD_Logic; --Unused CSVR reg signal from ALU         ************

--************************************************************************--
--************************************************************************--
--Component Declarations

--PC
component Program_Counter is
  Port (
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    advance_counter: IN STD_LOGIC := '0'; -- control signal to allow advance of PC (Write enable)
    use_next_addr: IN STD_LOGIC := '1'; -- Mux control signal to select PC addr input (1 to increment by 4)
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
    addr_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    addr_next: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0')
   );
end component;

--IM
component Instruction_Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1';--*******
    read_instr: IN STD_LOGIC := '1'; --control signal used to enable read of next instruction
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := IM_START_ADDR;
    addr_in2: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');--*******
    instr_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);
    instr_out2: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0);--*******
    read_enable: IN STD_LOGIC_VECTOR(2 downto 0) := "000" --control signal used to enable read of mem --*******
  );
end component;

--Control Unit
component Control_Unit is
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

    imm: out std_logic_vector(31 downto 0) := X"00000000"; -- immediate (numerical value)
    
    MEM_WE: out std_logic_vector( 2 downto 0) := "000"; --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
    MEM_RE: out std_logic_vector( 2 downto 0) := "000"; --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)
        
    use_alu: out std_logic := '1'; -- zero to use data_ram output
    
    compare: in std_logic := '0'; --comparison result from BC block
    
    opc_out: out std_logic_vector(9 downto 0); -- (funct3 & opcode) output needed for imm and data extension
    state_out : out StateType := ST_4
  );
end component; 

--regfile
component reg_file is
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
end component;

--b.c.
component BranchCmp is
    Port ( rs1        : in STD_LOGIC_VECTOR (31 downto 0); 
           rs2        : in STD_LOGIC_VECTOR (31 downto 0);
           BC_Control : in BCop;
           compare    : out STD_LOGIC
         );
end component;

--imm. ext.
component Imm_ext is
    Port (
        imm_in: in std_logic_vector(31 downto 0);   --32 bits immediate from the Control Unit
        imm_out: out std_logic_vector(31 downto 0); --32 bits sign extended immetiate to the ALU
        opc_in: in std_logic_vector(9 downto 0)     --10 bits funct3 & opcode from the Control Unit
    );
end component;

--ALU
component ALU is
    Port ( SrcA : in STD_LOGIC_VECTOR (31 downto 0);
           SrcB : in STD_LOGIC_VECTOR (31 downto 0);
           ALU_Control : in ALUop;
           ALU_Result : out STD_LOGIC_VECTOR (31 downto 0);
           Flag_Zero : out STD_LOGIC;
           Flag_Negative : out STD_Logic);
end component;

--MEM
component Memory is
  Port ( 
    clk : IN STD_LOGIC := '0';
    rst : IN STD_LOGIC := '1'; --asynchronous, active LOW
    
    --(word write enable bits, write enable bit) 
    MEM_WE: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable write of mem
    
    --(word read enable bits, read enable bit) 
    MEM_RE: IN STD_LOGIC_VECTOR(2 downto 0) := "000"; --control signal used to enable read of mem
    addr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := DM_START_ADDR;
    data_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    data_out: OUT STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    instr_in: IN STD_LOGIC_VECTOR((LENGTH_ADDR_BITS-1) downto 0) := (others => '0');
    SW_IN: IN STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --********
    LED_OUT: OUT STD_LOGIC_VECTOR(15 downto 0) := (others => '0') --******
  );
end component;

--data ext.
component Data_ext is
    Port (
        data_in: in std_logic_vector(31 downto 0);   --32 bits data from the DM
        data_out: out std_logic_vector(31 downto 0); --32 bits sign extended data to the MUX
        opc_in: in std_logic_vector(9 downto 0)      --10 bits funct3 & opcode from the Control Unit
    );
end component;


--******************************************************************************************************************--
begin
--************************************************************************--
--************************************************************************--
--Component Instantiations
--PC
MU1: Program_Counter 
  Port Map(
    clk => clk,
    rst => rst, --asynchronous, active LOW
    advance_counter => t_advance_counter, -- control signal to allow advance of PC (Write enable)
    use_next_addr => t_use_next_addr, -- Mux control signal to select PC addr input (1 to increment by 4)
    addr_in => t_ALU_RESULT,
    addr_out => t_pc_addr_out,
    addr_next => t_pc_addr_next
   );

--IM
MU2: Instruction_Memory 
  Port Map( 
    clk => clk,
    rst => rst,
    read_instr => t_read_instr, --control signal used to enable read of next instruction
    addr_in => t_pc_addr_out,
    addr_in2 => t_ALU_RESULT,
    instr_out => t_instr,
    instr_out2 => t_instr2,
    read_enable => t_MEM_RE
  );

--Control Unit
MU3: Control_Unit 
  Port Map( 
    clk => clk,
    rst => rst,--Active LOW, asynchronous
    instr => t_instr,--instruction input
    
    use_next_addr => t_use_next_addr, --use PC+4 as PC input? 0 to use ALU output
    advance_counter => t_advance_counter,
    
    
    
    read_instr => t_read_instr, --control signal used to enable read of next instruction
    
    rs1 => t_rs1, 
    rs2 => t_rs2,
    rd => t_rd,
    REG_WE => t_REG_WE, --Reg write enable(stack)
    rd_input => t_rd_input, -- 1 to use ALU/ RAM output & 0 to use PC+4
    
    bc_out => t_bc_out,
    
    alu_out => t_alu_out,
    use_rs1 => t_use_rs1, --to ALU input, 0 to use PC value
    use_rs2 => t_use_rs2, --to ALU input, 0 to use imm value
    
    imm => t_imm, -- immediate (numerical value)
    
    MEM_WE => t_MEM_WE, --control signal used to enable write of data ram --([00]byte[01]hlf-wrd[11]word, write enable bit)
    MEM_RE => t_MEM_RE, --control signal used to enable read of data ram --([00]byte[01]hlf-wrd[11]word, read enable bit)
    
    
    use_alu => t_use_alu, -- zero to use data_ram output
    
    compare => t_compare, --comparison result from BC block
    
    opc_out => t_opc_out, -- (funct3 & opcode) output needed for imm and data extension
    
    state_out => t_state_out
  );

--regfile
MU4: reg_file 
    Port Map(
            CLK                  => clk,
            ReadReg1             => t_rs1,
            ReadReg2             => t_rs2,
            ReadData1            => t_ReadData1,
            ReadData2            => t_ReadData2,
            WriteReg             => t_rd,
            WriteData            => rd_mux,
            WriteEnable          => t_REG_WE,
            opc_in               => t_opc_out,
            state_in             => t_state_out
    );

--b.c.
MU5: BranchCmp 
    Port Map(  rs1        => t_ReadData1,
               rs2        => t_ReadData2,
               BC_Control => t_bc_out,
               compare    => t_compare
             );

--imm. ext.
MU6: Imm_ext 
    Port Map(
        imm_in => t_imm,   --32 bits immediate from the Control Unit
        imm_out => t_imm_out, --32 bits sign extended immetiate to the ALU
        opc_in => t_opc_out     --10 bits funct3 & opcode from the Control Unit
    );

--ALU
MU7: ALU 
    Port Map(SrcA => alu_mux_1,
             SrcB => alu_mux_2,
             ALU_Control => t_alu_out,
             ALU_Result => t_ALU_RESULT,
             Flag_Zero => t_Flag_Zero,
             Flag_Negative => t_Flag_Negative);

--MEM
MU8: Memory 
  Port Map( 
    clk => clk,
    rst => rst, --asynchronous, active LOW
    
    --(word write enable bits, write enable bit) 
    MEM_WE => t_MEM_WE, --control signal used to enable write of mem
    
    --(word read enable bits, read enable bit) 
    MEM_RE => t_MEM_RE, --control signal used to enable read of mem
    addr_in => t_ALU_RESULT,
    data_in => t_ReadData2,
    data_out => t_mem_data_out,
    instr_in => t_instr2,
    SW_IN => t_SW,
    LED_OUT => t_LED
  );

--data ext.
MU9: Data_ext 
    Port Map(
        data_in => t_mem_data_out,   --32 bits data from the DM
        data_out => t_data_ext, --32 bits sign extended data to the MUX
        opc_in => t_opc_out      --10 bits funct3 & opcode from the Control Unit
    );

--************************************************************************--
--Muxes
with t_rd_input select rd_mux <= --to regfile
    output_mux when '1',
    t_pc_addr_next when others;
    
with t_use_rs1 select alu_mux_1 <= --to ALU input 1
    t_ReadData1 when '1',
    t_pc_addr_out when others;
    
with t_use_rs2 select alu_mux_2 <= --to ALU input 2
    t_ReadData2 when '1',
    t_imm_out when others;    

with t_use_alu select output_mux <= --to rd (& CPU output)
    t_ALU_RESULT when '1',
    t_data_ext when others;    

--************************************************************************--
--I/O
out_con_sig <= t_REG_WE & t_rd_input & t_rd & t_opc_out(6 downto 0);
with out_con_sig select sig_cpu_out <= --output of cpu
    output_mux when "1100000"&R_TYPE | "1100000"&I_TYPE_LOAD | "1100000"&I_TYPE_OTHERS,
    (others => '0') when others;    

--cpu_out <= sig_cpu_out;

t_SW <= SW;
LED <= t_LED;-- or SW;

end cpu_ach;
