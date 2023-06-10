LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity pipe_start is
	port(
			clk: IN STD_LOGIC;
			game_state : IN STD_LOGIC_VECTOR(1 downto 0);
			pulse : OUT STD_LOGIC
		);
end entity pipe_start;

architecture behaviour of pipe_start is 
signal state : std_logic := '0';
begin
process (clk)
begin
	if Rising_Edge(clk) then
		if game_state = "00" or game_state = "11" then
			state <= '0';
		elsif game_state = "10" or game_state = "01" then
			case state is
				when '0' => 
					pulse <= '1';
					state <= '1';
				when '1'  =>
					pulse <= '0';
			end case;
		end if;
	end if;
end process;
end architecture;
