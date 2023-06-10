LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

entity sprite_8bit is 
	generic ( 
			sprite_width : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(8,10); 
		  	sprite_height : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(8,10); 
		  	scale : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(3, 10);
			bits : Integer := 3
		);
	port (
			clk, reset, horiz_sync : IN STD_LOGIC;
			rom_address : IN STD_LOGIC_VECTOR(5 downto 0);
			sprite_row, sprite_column, 
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			sprite_on: OUT STD_LOGIC
		 );
end sprite_8bit;

architecture behaviour of sprite_8bit is
TYPE state_type is (IDLE, DRAW_SPRITE, WAIT_SPRITE);

SIGNAL state : state_type := IDLE;
SIGNAL bmap_column, bmap_row : STD_LOGIC_VECTOR(bits-1 downto 0);
SIGNAL new_sprite_row, new_sprite_column: STD_LOGIC_VECTOR(9 downto 0);
SIGNAL t_sprite_on : STD_LOGIC;
 
component char_rom 
PORT 
(
	character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
	font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	clock				: 	IN STD_LOGIC;
	rom_mux_output		:	OUT STD_LOGIC
);
end component;
begin

char_rom_component : char_rom
port map(
			character_address => rom_address,
			font_row => bmap_row,
			font_col => bmap_column,
			clock => clk,
			rom_mux_output => t_sprite_on  
	 	);


process (clk)
variable count : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(0,10);
variable count_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(0,10);
begin
	if rising_edge(clk) then
		case state is
			when IDLE =>
				if pixel_row > sprite_row and pixel_row <= sprite_row + (sprite_height * scale) 
				and pixel_column > sprite_column and pixel_column < sprite_column + (sprite_width * scale)  
				then
					state <= DRAW_SPRITE;

					if (count_y > scale - CONV_STD_LOGIC_VECTOR(1,10)) then
						count_y := CONV_STD_LOGIC_VECTOR(0,10);
						bmap_row <= bmap_row + "001";
					end if;

					new_sprite_column <= CONV_STD_LOGIC_VECTOR(0,10);
					bmap_column <= new_sprite_column(2 downto 0);
				end if;

			when DRAW_SPRITE =>
				state <= WAIT_SPRITE;

			when WAIT_SPRITE =>
				if "0000000" & bmap_column >= sprite_width - CONV_STD_LOGIC_VECTOR(1,10) then
					state <= IDLE;
					count_y := count_y + CONV_STD_LOGIC_VECTOR(1, 10);
				else
					state <= DRAW_SPRITE;
					if (count > scale - CONV_STD_LOGIC_VECTOR(1,10)) then
						count := CONV_STD_LOGIC_VECTOR(0,10);
						bmap_column <= bmap_column + "001";
					else 
						count := count + CONV_STD_LOGIC_VECTOR(1, 10);
					end if;
				end if;

			when others =>
				state <= IDLE;
		end case;
	end if;
end process;

process (state, t_sprite_on)
begin
	case state is
		when DRAW_SPRITE =>
			sprite_on <= t_sprite_on;
		when WAIT_SPRITE =>
			sprite_on <= t_sprite_on;
		when others =>
			sprite_on <= '0';
	end case;
end process;


end architecture behaviour;

