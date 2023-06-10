LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

entity sprite_16bit is 
	generic ( 
			sprite_width : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(16,10); 
		  	sprite_height : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(16,10); 
		  	scale : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(1, 10)
		);
	port (
			clk, reset, horiz_sync : IN STD_LOGIC;
			character_address : IN STD_LOGIC_VECTOR(12 downto 0);
			sprite_row, sprite_column, 
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			sprite_on: OUT STD_LOGIC
		 );
end sprite_16bit;

architecture behaviour of sprite_16bit is
TYPE state_type is (IDLE, DRAW_SPRITE, WAIT_SPRITE);

SIGNAL state : state_type := IDLE;
SIGNAL bmap_col, bmap_row : integer;
SIGNAL in_region : std_logic;
SIGNAL t_sprite_on : STD_LOGIC;
SIGNAL t_rom_data : STD_LOGIC_VECTOR(11 downto 0);
SIGNAL t_rom_address : STD_LOGIC_VECTOR(12 downto 0);

function index_2d_to_1d(row : integer; col : integer) return STD_LOGIC_VECTOR is
begin
	return CONV_STD_LOGIC_VECTOR(row * 16 + col, 13);
end function index_2d_to_1d;
 
component color_rom
GENERIC
(
	t_init_file : STRING;
	t_numwords_a : NATURAL
);
PORT 
(
	rom_address			:	IN STD_LOGIC_VECTOR (12 DOWNTO 0);
	clock				: 	IN STD_LOGIC;
	rom_output		:	OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
end component;
begin

char_rom_component : color_rom
generic map(
			t_init_file => "powerups.mif",
			t_numwords_a => 768
		   )
port map(
			rom_address => t_rom_address,
			clock => clk,
			rom_output => t_rom_data  
	 	);

rgb <= t_rom_data;

in_region <= '1' when pixel_row >= sprite_row and pixel_row < sprite_row + (sprite_height) 
			 and pixel_column >= sprite_column and pixel_column < sprite_column + (sprite_width) else '0';  
t_sprite_on <= '0' when in_region = '0' or t_rom_data = "000000000000" else '1';

bmap_row <= CONV_INTEGER(pixel_row -sprite_row);
bmap_col <= CONV_INTEGER(pixel_column - sprite_column);
t_rom_address <= character_address + index_2d_to_1d(bmap_row, bmap_col);
process (clk)
variable count : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(0,10);
variable count_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(0,10);
variable x_check : Integer range 0 to 64 := 0;


begin
	if rising_edge(clk) then
		case state is
			when IDLE =>
				if in_region = '1' then
					state <= DRAW_SPRITE;
					if (count_y > scale - CONV_STD_LOGIC_VECTOR(1,10)) then
						count_y := CONV_STD_LOGIC_VECTOR(0,10);
					end if;
				end if;

			when DRAW_SPRITE =>
				state <= WAIT_SPRITE;

			when WAIT_SPRITE =>
				if bmap_col = 16 then
					state <= IDLE;
					count_y := count_y + CONV_STD_LOGIC_VECTOR(1, 10);
				else
					state <= DRAW_SPRITE;
					if (count > scale - CONV_STD_LOGIC_VECTOR(1,10)) then
						count := CONV_STD_LOGIC_VECTOR(0,10);
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

