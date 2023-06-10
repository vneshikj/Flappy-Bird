LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity ground is
	port(
			vga_sync : IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			ground_rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			ground_on: OUT STD_LOGIC
		);
end entity ground;

architecture behaviour of ground is
--CONSTANTS
CONSTANT ground_top_y : Integer := 420;
--SIGNALS
SIGNAL temp_ground_on : STD_LOGIC;
begin
temp_ground_on <= '1' when (ground_top_y <= to_integer(unsigned(pixel_row))) else '0'; 
ground_on <= temp_ground_on;
process(pixel_row)
begin
	case to_integer(unsigned(pixel_row)) is
		when ground_top_y to ground_top_y + 9 => ground_rgb <= "001111000000";
		when ground_top_y + 10 to ground_top_y + 19 => ground_rgb <= "010000100010";
		when ground_top_y + 20 to ground_top_y + 29 => ground_rgb <= "010100110011";
		when ground_top_y + 30 to ground_top_y + 39 => ground_rgb <= "011101000100";
		when ground_top_y + 40 to ground_top_y + 60 => ground_rgb <= "101001110111";
    when others => null;
end case;
end process;

end architecture behaviour; 
