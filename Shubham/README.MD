# Shubham's Contribution
# ALU 
- ALU.vhd and is tested by ALU_TB.vhd
# Register file (stack) 
- reg_file.vhd and is tested by regFile_TB.vhd
# Branch Comparisions
## BranchCmp.vhd and is tested by BC_TB.vhd
- rs1 : 5-bit specifier for source register 1
- rs2 : 5-bit specifier for source register 2           
- BC_Control : control signals for Branch Compare : BC_EQ, BC_NE, BC_LT, BC_GE, BC_LTU, BC_GEU
- compare    : output from BC component containing True/False for each control signals
