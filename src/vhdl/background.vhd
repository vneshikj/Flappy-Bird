LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.NUMERIC_STD.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity background is 
	port(
			vert_sync: IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			background_rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			background_on  : OUT STD_LOGIC
		);
end entity;

architecture behaviour of background is
CONSTANT ground_top_y : integer := 420;

SIGNAL temp_background_on : STD_LOGIC;
begin
temp_background_on <= '1' when to_integer(unsigned(pixel_row)) < ground_top_y else '0';
background_on <= temp_background_on;
process(pixel_row)
  begin
	if temp_background_on = '1' then
		case to_integer(unsigned(pixel_row)) is
			when 0 to 79 => background_rgb <= "000000111000";
			when 80 to 139 => background_rgb <= "000000111000";
			when 140 to 189 => background_rgb <= "000001111011";
			when 190 to 229 => background_rgb <= "000010011100";
			when 230 to 264 => background_rgb <= "000010011100";
			when 265 to 294 => background_rgb <= "000010111101";
			when 295 to 319 => background_rgb <= "010011001110";
			when 320 to ground_top_y => background_rgb <= "010011001110";
			when others => null;
		end case;
	end if;
end process;

process(vert_sync)
begin
	if Rising_Edge(vert_sync) then
	end if;
end process;
end architecture behaviour;
