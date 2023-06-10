library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_EXAMPLE_tb is
end VGA_EXAMPLE_tb;

architecture Behavioral of VGA_EXAMPLE_tb is

  -- Declare the signals
  signal clk50_in : std_logic := '0';

  -- Import the DUT
  component VGA_EXAMPLE is
    port(clk50_in : in std_logic;
         red      : out std_logic;
         green    : out std_logic;
         blue     : out std_logic;
         hs_out   : out std_logic;
         vs_out   : out std_logic);
  end component;

  -- Instantiate the DUT
  signal red, green, blue, hs_out, vs_out : std_logic;
  signal done : boolean := false;
begin

  -- Instantiate the DUT
  uut: VGA_EXAMPLE
    port map (clk50_in => clk50_in,
              red      => red,
              green    => green,
              blue     => blue,
              hs_out   => hs_out,
              vs_out   => vs_out);

  -- Generate the clock
  process
  begin
    while not done loop
      clk50_in <= not clk50_in;
      wait for 10 ns; -- 50MHz clock period is 20 ns
    end loop;
    wait;
  end process;

end Behavioral;

