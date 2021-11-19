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
