LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY mem_wb_entity IS
	PORT (
        clock: IN STD_LOGIC;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        alu_result_in: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        alu_result_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        data_mem_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_mem_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END mem_wb_entity;

ARCHITECTURE mem_wb_architecture OF mem_wb_entity IS
    SIGNAL instruction_intermediate: INSTRUCTION;
    SIGNAL alu_result_intermediate: STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL data_mem_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    mem_wb_process: PROCESS (clock)
    BEGIN
        IF(clock'EVENT AND clock = '1') THEN

            instruction_intermediate <= instruction_in;
            instruction_out <= instruction_intermediate;

            data_mem_out <= data_mem_intermediate;
            data_mem_intermediate <= data_mem_in;

            alu_result_intermediate <= alu_result_in;
            alu_result_out <= alu_result_intermediate;
        END IF;
    END PROCESS;

END mem_wb_architecture;
