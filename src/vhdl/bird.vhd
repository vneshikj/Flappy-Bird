LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bird IS
	PORT
		(clk, vert_sync, invincible, left_click, pipe_on, health_pickup_on, invincibility_pickup_on, 
		 death_pickup_on, pause_switch: IN std_logic;
		character_select : IN STD_LOGIC_VECTOR(1 downto 0);
          pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  game_state : IN std_logic_vector(1 downto 0); -- 00 game over, 01 game start, 10 gameplay
		  collision : OUT STD_LOGIC_VECTOR(2 downto 0);
			bird_rgb : OUT STD_LOGIC_VECTOR(11 downto 0); 
		  bird_on		: OUT std_logic);		-- collision and mode are connected to the FSM
END bird;

architecture behavior of bird is
-- CONSTANTS
CONSTANT ACCELERATION_RATE_DOWN : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(1,10);
CONSTANT UPWARDS_SPEED : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(10, 10);
CONSTANT MAX_FALL_SPEED : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(11, 10);
CONSTANT BIRD_SCALE : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(1, 10);
CONSTANT GROUND_Y_PIXEL : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(420,10);
CONSTANT CENTRE_Y : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(240, 10);
CONSTANT SCREEN_MAX_Y : STD_LOGIC_VECTOR := CONV_STD_LOGIC_VECTOR(480, 10);

signal left_click_prev : std_logic := '0';
SIGNAL temp_bird_on					: std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(32,10);
SIGNAL bird_y_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL bird_x_pos				: std_logic_vector(9 DOWNTO 0);
SIGNAL bird_y_motion			: std_logic_vector(9 DOWNTO 0);
SIGNAL t_collision : STD_LOGIC_VECTOR(2 downto 0);
SIGNAL character_address 		: std_logic_vector(12 DOWNTO 0);
SIGNAL t_bird_rgb :  STD_LOGIC_VECTOR(11 downto 0);

component sprite_32bit 
	generic (
			scale : STD_LOGIC_VECTOR	
			);
	port (
			clk, reset, horiz_sync : IN STD_LOGIC;
			character_address : IN STD_LOGIC_VECTOR(12 downto 0);
			sprite_row, sprite_column, 
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			sprite_on: OUT STD_LOGIC
		 );
end component;

BEGIN           

bird_x_pos <= CONV_STD_LOGIC_VECTOR(300,10);
with character_select select character_address <=
	CONV_STD_LOGIC_VECTOR(0, 13) when "00",
	CONV_STD_LOGIC_VECTOR(1024, 13) when "01",
	CONV_STD_LOGIC_VECTOR(2048, 13) when "10",
	CONV_STD_LOGIC_VECTOR(3072, 13) when others;

sprite_component : sprite_32bit 
generic map(
			BIRD_SCALE
		   ) 
port map( clk, '0', vert_sync, character_address,bird_y_pos,bird_x_pos, pixel_row, pixel_column, t_bird_rgb, temp_bird_on
);

t_collision <=
	"001" when temp_bird_on = '1' and pipe_on = '1' else
	"010" when bird_y_pos >= GROUND_Y_PIXEL - SIZE else
	"011" when temp_bird_on = '1' and health_pickup_on = '1' else
	"100" when invincibility_pickup_on = '1' and temp_bird_on = '1' else
	"101" when death_pickup_on = '1' and temp_bird_on = '1' else
	"000"; 

collision <= t_collision;


bird_rgb <= "111111111111" when temp_bird_on = '1' and invincible = '1' else
			t_bird_rgb when temp_bird_on = '1' and t_collision /= "001" else  
			"111100000000" when temp_bird_on = '1' and t_collision = "001" else "000000000000";
bird_on <= temp_bird_on;



Move_Bird: process (vert_sync) -- Add left_click to sensitivity list
begin
	if Rising_Edge(vert_sync) then

		if left_click = '1' and left_click_prev = '0' then
			if game_state /= "11" then 
				-- Go up
				if bird_y_pos > 0 then -- Check if ball is not at the top of the screen
					bird_y_motion <= -UPWARDS_SPEED; -- Set upward motion
				else
					bird_y_motion <= (others => '0'); -- Dont move
				end if;
			end if;
		else
			-- Apply gravity
			if bird_y_pos < (GROUND_Y_PIXEL - size) and game_state /= "00" then -- Check if ball is not at the bottom of the screen
				if bird_y_motion < MAX_FALL_SPEED then -- Limit fall speed
					bird_y_motion <= bird_y_motion + ACCELERATION_RATE_DOWN; -- Make it fall faster
				end if;
			else
				bird_y_motion <= (others => '0'); -- Stop downward motion
			end if;
		end if;

		if game_state = "00" then
			bird_y_pos <= CENTRE_Y;
		elsif pause_switch = '1' then
			bird_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
		elsif bird_y_pos + bird_y_motion >= (GROUND_Y_PIXEL - size) then
			bird_y_pos <= GROUND_Y_PIXEL - size; --Make it fall to bottom gracefully
		elsif bird_y_pos + bird_y_motion >= SCREEN_MAX_Y then
			bird_y_pos <= CONV_STD_LOGIC_VECTOR(0, 10);
		else
			bird_y_pos <= bird_y_pos + bird_y_motion; -- normal
		end if;

		left_click_prev <= left_click;

	end if;

end process Move_Bird;

END behavior;

