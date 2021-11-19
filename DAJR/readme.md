<h1><b>File Description </h1></b> 
Program counter in Program_Counter.vhd tested by Testbench_PC.vhd <br>
<br> Instruction Memory in Instruction_Memory.vhd and is tested by Testbench_IM.vhd<br>
<br> Data Memory (RAM) is in Data_Memory.vhd and is tested by Testbench_DM.vhd<br>
<br> N-number ROM in Nnum_Memory.vhd and is tested by Testbench_NM.vhd<br>
<br> LED Memory in Led_Memory.vhd and is tested by Testbench_LED.vhd<br>
<br> Switch Memory in Switch_Memory.vhd and is tested by Testbench_SW.vhd<br>
<br> Control Unit Version 2.0 in Control_Unit.vhd. Since the CU was done by Artem, this is my version. <br>
His original version has a testbench but this new trial version does not. <br>



<h1><b> Control Signals </h1></b>
<h2><b>Program Counter </h2></b>
  <b>advance_counter</b>: IN STD_LOGIC := '0'; -- control signal to allow advance of PC (Write enable)
  <br><b>use_next_addr</b>: IN STD_LOGIC := '1'; -- Mux control signal to select PC addr input (1 to increment by 4)  
<h2><b>Instruction Memory </h2></b>
  <b>read_instr</b>: IN STD_LOGIC := '1'; --control signal used to enable read of next instruction
<h2><b>Data Memory </h2></b>  
  <b>write_enable</b>: IN STD_LOGIC_VECTOR(1 downto 0) := "00"; --control signal used to enable write of data ram --(word write enable bit, write enable bit) 
  <br><b>read_enable</b>: IN STD_LOGIC_VECTOR(1 downto 0) := "00"; --control signal used to enable read of data ram  --(word read enable bit, read enable bit) 
<h2><b>Led Memory </h2></b>  
  <b>write_enable</b>: IN STD_LOGIC_VECTOR(1 downto 0) := "00"; --control signal used to enable write of data ram --(word write enable bit, write enable bit) 
  <br><b>read_enable</b>: IN STD_LOGIC_VECTOR(1 downto 0) := "00"; --control signal used to enable read of data ram  --(word read enable bit, read enable bit) 
<h2><b>Switch Memory </h2></b>  
  <b>read_sw</b>: IN STD_LOGIC := '1'; --control signal used to enable read of switches
<h2><b>N-number Memory </h2></b>  
  <b>read_num</b>: IN STD_LOGIC := '1'; --control signal used to enable read of Nnumber 

