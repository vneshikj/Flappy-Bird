LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

ENTITY tb_pipe IS
END tb_pipe;

ARCHITECTURE behavior OF tb_pipe IS 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT pipe
    PORT(
        vert_sync : IN  std_logic;
        init : IN  std_logic;
        pixel_row : IN  std_logic_vector(9 downto 0);
        pixel_column : IN  std_logic_vector(9 downto 0);
        game_state : IN  std_logic_vector(1 downto 0);
        random_index : IN  std_logic_vector(3 downto 0);
        init_next : OUT  std_logic;
        score_pulse : OUT  std_logic;
        pipe_on : OUT  std_logic;
        red : OUT  std_logic;
        green : OUT  std_logic;
        blue : OUT  std_logic
    );
    END COMPONENT;

   --Inputs
   signal vert_sync : std_logic := '0';
   signal init : std_logic := '1';
   signal pixel_row : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(100, 10);
   signal pixel_column : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(200, 10) ;
   signal game_state : std_logic_vector(1 downto 0) := "01";
   signal random_index : std_logic_vector(3 downto 0) := "0000";

    --Outputs
   signal init_next : std_logic;
   signal score_pulse : std_logic;
   signal pipe_on : std_logic;
   signal red : std_logic;
   signal green : std_logic;
   signal blue : std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: pipe PORT MAP (
          vert_sync => vert_sync,
          init => init,
          pixel_row => pixel_row,
          pixel_column => pixel_column,
          game_state => game_state,
          random_index => random_index,
          init_next => init_next,
          score_pulse => score_pulse,
          pipe_on => pipe_on,
          red => red,
          green => green,
          blue => blue
       );

END;
