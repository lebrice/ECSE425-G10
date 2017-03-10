LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.INSTRUCTION_TOOLS.all;
USE work.registers.all;

ENTITY decode_tb IS
END decode_tb;

architecture behaviour of decode_tb is

    constant clock_period : time := 1 ns;

    component decodeStage is
        port (
            clock : in std_logic;

            -- Inputs coming from the IF/ID Register
            PC : in integer;
            instruction_in : in INSTRUCTION;


            -- Instruction and data coming from the Write-Back stage.
            write_back_instruction : in INSTRUCTION;
            write_back_data : in std_logic_vector(31 downto 0);


            -- Outputs to the ID/EX Register
            val_a : out std_logic_vector(31 downto 0);
            val_b : out std_logic_vector(31 downto 0);
            i_sign_extended : out std_logic_vector(31 downto 0);
            PC_out : out integer;
            instruction_out : out INSTRUCTION;

            -- Register file
            register_file : in REGISTER_BLOCK;

            -- Stall signal out.
            stall_out : out std_logic
            
        );
    end component;

signal clock : std_logic;
signal PC : integer;
signal instruction_in : INSTRUCTION;
signal write_back_instruction : INSTRUCTION;
signal write_back_data : std_logic_vector(31 downto 0);
signal val_a : std_logic_vector(31 downto 0);
signal val_b : std_logic_vector(31 downto 0);
signal i_sign_extended : std_logic_vector(31 downto 0);
signal PC_out : integer;
signal instruction_out : INSTRUCTION;
signal register_file : REGISTER_BLOCK;
signal stall_out : std_logic;

begin

    dec : decodeStage port map (
        clock,
        PC,
        instruction_in,
        write_back_instruction,
        write_back_data,
        val_a,val_b,
        i_sign_extended,
        PC_out,
        instruction_out,
        register_file,
        stall_out
    );

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    test_process : process
    variable registers : register_block;
    begin
        -- TODO: figure out if the return value really needs to be used or not.
        registers := reset_register_block(registers);

        for I in 0 to NUM_REGISTERS loop
            registers(I).data := std_logic_vector(to_unsigned(I, 32));
            registers(I).busy := '0';
        end loop;

        PC <= 0;
        instruction_in <= makeInstruction(ALU_OP, 1,2,3,0, ADD_FN); -- ADD R1 R2 R3


        wait;

    end process;


end behaviour;