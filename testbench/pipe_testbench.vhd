library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.NUMERIC_STD.all;

entity test_pipe is
end test_pipe;

architecture behavior of test_pipe is

  -- component declaration
  component pipe is
    port (
      vert_sync     : in std_logic;
      init          : in  std_logic;
      pixel_row     : in  std_logic_vector(9 downto 0);
      pixel_column  : in  std_logic_vector(9 downto 0);
      game_state    : in  std_logic_vector(2 downto 0);
      game_level    : in  std_logic_vector(2 downto 0);
      random_index  : in  std_logic_vector(3 downto 0);
      init_next     : out std_logic;
      red           : out std_logic;
      green         : out std_logic;
      blue          : out std_logic;
	  pipe_on 		: out std_logic
    );
  end component;

  -- signal declaration
  signal vert_sync    : std_logic;
  signal init         : std_logic := '1';
  signal pixel_row    : std_logic_vector(9 downto 0) := (others => '0');
  signal pixel_column : std_logic_vector(9 downto 0) := (others => '0');
  signal pipe_on	  : std_logic;

begin

  -- UUT instantiation
  uut: pipe
    port map (
      vert_sync     => vert_sync,
      init          => init,
      pixel_row     => pixel_row,
      pixel_column  => pixel_column,
      game_state    => (others => '0'),
      game_level    => (others => '0'),
      random_index  => (others => '0'),
      init_next     => open,
      red           => open,
      green         => open,
      blue          => open,
	  pipe_on 		=> pipe_on
    );

  -- generate clock
  process
  begin
    while true loop
      vert_sync <= '0';
	  wait for 20 ns;
      vert_sync <= '1';
      wait for 20 ns;  -- VSYNC pulse width
    end loop;
  end process;

  -- generate pixel row and column signals
  process
  begin
    for i in 0 to 639 loop
      pixel_column <= std_logic_vector(to_unsigned(i, 10));
      for j in 0 to 479 loop
        pixel_row <= std_logic_vector(to_unsigned(j, 10));
        wait for 25 ns;  -- pixel clock period
      end loop;
    end loop;
    wait;
  end process;

end behavior;
