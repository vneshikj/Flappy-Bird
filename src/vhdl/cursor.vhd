LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity cursor is
	port(
			clk,vert_sync, mouse_click: IN STD_LOGIC;
			pixel_row, pixel_column, mouse_row, mouse_column : IN STD_LOGIC_VECTOR(9 downto 0);
			game_state : IN STD_LOGIC_VECTOR(1 downto 0);
			cursor_rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			cursor_on : OUT STD_LOGIC 
		);
end cursor;

architecture behaviour of cursor is

--SIGNALS
SIGNAL temp_cursor_on : STD_LOGIC;

SIGNAL t_mouse_row, t_mouse_column : STD_LOGIC_VECTOR(9 downto 0);
SIGNAL t_cursor_rgb : STD_LOGIC_VECTOR(11 downto 0);

component sprite_32bit 
	port (
			clk, reset, horiz_sync : IN STD_LOGIC;
			character_address : IN STD_LOGIC_VECTOR(12 downto 0);
			sprite_row, sprite_column, 
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			sprite_on: OUT STD_LOGIC
		 );
end component;
begin

sprite_component : sprite_32bit 
port map(
		clk, '0', vert_sync,CONV_STD_LOGIC_VECTOR(4096,13),t_mouse_row,t_mouse_column, pixel_row, pixel_column, t_cursor_rgb, temp_cursor_on
		);

cursor_rgb <= t_cursor_rgb 
			when temp_cursor_on = '1' and mouse_click = '0' 
		 	else "000000000000" 
			when temp_cursor_on ='1' and mouse_click ='1' 
			else "000000000000";
cursor_on <= temp_cursor_on;

process(vert_sync)
begin
	if Rising_Edge(vert_sync) then
		t_mouse_row <= mouse_row;
		t_mouse_column <= mouse_column;
	end if;
end process;

end architecture behaviour;

