library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Clock_Divider is
  port (
    Clk_In: in std_logic;
    Clk_Out: out std_logic
  );
end entity Clock_Divider;

architecture Behavioral of Clock_Divider is
  signal Clk_Half: std_logic;
begin
  process(Clk_In)
  begin
    if rising_edge(Clk_In) then
      Clk_Half <= not Clk_Half;
    end if;
  end process;
  
  Clk_Out <= Clk_Half;
end architecture Behavioral;

