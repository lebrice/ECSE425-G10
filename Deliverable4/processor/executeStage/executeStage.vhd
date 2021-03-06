library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

entity executeStage is
  port (
    instruction_in : in Instruction;
    val_a : in std_logic_vector(31 downto 0);
    val_b : in std_logic_vector(31 downto 0);
    imm_sign_extended : in std_logic_vector(31 downto 0);
    PC : in integer; 
    instruction_out : out Instruction;
    branch : out std_logic;
    ALU_result : out std_logic_vector(63 downto 0);
    branch_target_out : out std_logic_vector(31 downto 0);
    val_b_out : out std_logic_vector(31 downto 0);
    PC_out : out integer
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is
  COMPONENT ALU
  port (
    instruction_type : in INSTRUCTION_TYPE;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0) -- RD
  );
  END COMPONENT;
  
  --Signals for what go into the ALU
  SIGNAL input_a: std_logic_vector(31 downto 0);
  SIGNAL input_b: std_logic_vector(31 downto 0);
  SIGNAL internal_branch : std_logic;
  SIGNAL internal_ALU_result : std_logic_vector(63 downto 0);

  function signExtend(immediate : std_logic_vector(15 downto 0))
    return std_logic_vector is
  begin
    if(immediate(15) = '1') then
      return X"FFFF" & immediate;
    else
      return X"0000" & immediate;
    end if;
  end signExtend;



  --SIGNAL ALU_result : std_logic_vector(31 downto 0);
begin
  --define alu component
  exAlu: ALU port map (instruction_in.instruction_type, input_a, input_b, internal_ALU_result);

  --calculate the branch target
  branch <=
    '1' when instruction_in.INSTRUCTION_TYPE = BRANCH_IF_EQUAL AND val_a = val_b else
    '1' when instruction_in.INSTRUCTION_TYPE = BRANCH_IF_NOT_EQUAL AND val_a /= val_b else
    '1' when instruction_in.INSTRUCTION_TYPE = JUMP else
    '1' when instruction_in.INSTRUCTION_TYPE = JUMP_AND_LINK else
    '1' when instruction_in.INSTRUCTION_TYPE = JUMP_TO_REGISTER else
    '0';

  --ALU_result <= ALU_result; --from alu --not needed since done in port map
  instruction_out <= instruction_in; --pass through
  PC_out <= PC;
  branch_target_out <= internal_ALU_result(31 downto 0); --this won't always be a branch.
  ALU_result <= internal_ALU_result;
  val_b_out <= val_b; --used to send val b to the next stage
 
  -- Process 2: Pass in values to ALU and get result
  compute_inputs : process(instruction_in, val_a, val_b, imm_sign_extended)
  begin
 
    -- The instruction changes what is passed to the ALU
    -- We either pass in:
    --  a) values read from registers
    --  b) shamt
    --  c) address vector
    --  d) immediate sign extended
    --  e) branch target

    --TODO: Check divide mips command with hi lo stuff

    -- just going to go through every instruction type and act accordingly
    case instruction_in.INSTRUCTION_TYPE is
        when ADD | SUBTRACT | MULTIPLY | DIVIDE | SET_LESS_THAN | BITWISE_AND | BITWISE_OR | BITWISE_NOR | BITWISE_XOR =>
          input_a <= val_a; -- rs
          input_b <= val_b; -- rt
        when ADD_IMMEDIATE | SET_LESS_THAN_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | LOAD_UPPER_IMMEDIATE | LOAD_WORD | STORE_WORD =>
          input_a <= val_a; -- rs
          -- FIXME: temp fix:
          input_b <= signExtend(instruction_in.immediate_vect);
          -- input_b <= imm_sign_extended;
        when MOVE_FROM_HI =>
          -- This case is never reached (handled in decode)
          report "ERROR: MOVE_FROM_HI should not be given to ALU!" severity WARNING;
        when MOVE_FROM_LOW =>
          -- This case is never reached (handled in decode)
          report "ERROR: MOVE_FROM_LOW should not be given to ALU!" severity WARNING;
        when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
          input_a <= (31 downto 5 => '0') & instruction_in.shamt_vect;
          input_b <= val_b;
        when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL =>
          --with branches, we want "a" to have the PC, b the immediate
          input_a <= std_logic_vector(to_unsigned(PC, 32)); 
          input_b <= imm_sign_extended;
        when JUMP | JUMP_AND_LINK =>
          input_a <= std_logic_vector(to_unsigned(PC,32)(31 downto 26)) & instruction_in.address_vect; 
          input_b <= val_b; --doesn't matter
        when JUMP_TO_REGISTER =>
          input_a <= val_a;
          input_b <= val_b;
        when UNKNOWN => --this is unknown: report an error.
          report "ERROR: unknown instruction format in execute stage!" severity WARNING;
    end case;
  end process; -- compute_inputs
end architecture ; -- arch