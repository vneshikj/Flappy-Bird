LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_SIGNED.all;
USE IEEE.NUMERIC_STD.all;

entity pipe is
	PORT(
		clk, vert_sync, init, pause_switch : IN STD_LOGIC;
        pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		level,game_state: IN STD_LOGIC_VECTOR(1 downto 0);
		random_index : IN STD_LOGIC_VECTOR(3 downto 0);
		pipe_rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
		init_next, score_pulse, pipe_on, 
		health_pickup_on, invincibility_pickup_on, death_pickup_on,
		pipes_powerups_on : OUT STD_LOGIC
	);
end entity;

architecture behaviour of pipe is 

-- Typedef
type speed_vector is array (0 to 4) of integer;
type preset_vector is array (0 to 16) of integer;

--CONSTANTS
CONSTANT preset_scroll_speeds : speed_vector := (2, 4, 8, 15, 18);
CONSTANT preset_pipe_heights : preset_vector:= (81, 242, 80, 171, 213, 99, 261, 174, 36, 151, 82, 37, 142, 264, 147, 234, 131);
CONSTANT preset_powerup_heights : preset_vector := (90, 111, 91, 153, 73, 86, 180, 118, 127, 218, 135, 224, 146, 203, 61, 158, 71);
CONSTANT preset_powerups : preset_vector := (0,0,2,0,1,0,0,0,2,0,1,2,0,1,0,0,1);
CONSTANT preset_show : std_logic_vector := "1101111101010111";
CONSTANT pipe_gap : Integer := 130; 
CONSTANT pipe_width : Integer := 65; 
CONSTANT pipe_spacing : Integer := 140;
CONSTANT pipe_spacing_center : Integer := pipe_spacing/2;
CONSTANT screen_max_x : Integer := 639;
CONSTANT screen_halfway : Integer := 320;
CONSTANT score_pulse_debounce : Integer := 40;

-- SIGNALS
SIGNAL current_powerup : Integer;
SIGNAL powerup_address : STD_LOGIC_VECTOR(12 downto 0);
SIGNAL powerup_rgb : STD_LOGIC_VECTOR(11 downto 0);
SIGNAL powerup_x_pos, powerup_y_pos : Integer;
SIGNAL pipe_x_pos : Integer := screen_max_x + pipe_width;
SIGNAL pipe_x_motion : Integer;
SIGNAL pipe_height : Integer;
SIGNAL t_powerup_on, powerup_on, current_show_status, temp_pipe_on, top_pipe_on, bottom_pipe_on,appear : STD_LOGIC; 
SIGNAL enable : STD_LOGIC;
SIGNAL current_index : Integer;
SIGNAL scroll_speed : Integer;

component sprite_16bit 
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

sprite_component : sprite_16bit 
port map( clk, '0', vert_sync, powerup_address,std_logic_vector(to_unsigned(powerup_y_pos, 10)),std_logic_vector(to_unsigned(powerup_x_pos, 10)), pixel_row, pixel_column, powerup_rgb, t_powerup_on
);

bottom_pipe_on <= '1' when (pipe_x_pos > to_integer(unsigned(pixel_column)) 
and to_integer(unsigned(pixel_column)) > pipe_x_pos - pipe_width 
and pipe_height + pipe_gap < pixel_row) else '0'; 

top_pipe_on <= '1' when (pipe_x_pos > to_integer(unsigned(pixel_column)) 
and to_integer(unsigned(pixel_column)) > pipe_x_pos - pipe_width 
and pixel_row < pipe_height) else '0'; 

temp_pipe_on <= '1' when ( top_pipe_on = '1' or bottom_pipe_on = '1' ) and appear = '1' else '0';

pipes_powerups_on <= '1' when temp_pipe_on = '1' or powerup_on = '1' else '0';

pipe_rgb <= "001001100100" when temp_pipe_on = '1' else 
			powerup_rgb when powerup_on = '1' else 
			"000000000000";
current_index <= to_integer(unsigned(random_index));

powerup_x_pos <= pipe_x_pos + pipe_spacing_center;

pipe_on <= '1' when temp_pipe_on = '1' else '0';

powerup_on <= '1' when t_powerup_on = '1' and game_state /= "10" and current_show_status = '1' else '0';

death_pickup_on <= '1' when powerup_on = '1' and current_powerup = 0 and game_state /= "10" else '0';
health_pickup_on <= '1' when powerup_on = '1' and current_powerup = 1 and game_state /= "10" else '0';
invincibility_pickup_on <= '1' when powerup_on = '1' and current_powerup = 2 and game_state /= "10" else '0';


move_pipe : process(vert_sync) 	
variable flash_count : INTEGER := 0;
begin
		if Rising_Edge(vert_sync) then
			case current_powerup is
				when 0 =>
					powerup_address <= std_logic_vector(to_unsigned(0,13));
				when 1 =>
					powerup_address <= std_logic_vector(to_unsigned(256,13));
				when 2 =>
					powerup_address <= std_logic_vector(to_unsigned(512,13));
				when others => null;
			end case;
			
			case game_state is
				when "00" => appear <= '1';
				when "01" => 
					scroll_speed <= preset_scroll_speeds(to_integer(unsigned(level-"01")));
					if(level = "11") then
						flash_count :=flash_count +1;
						case flash_count is
							when 10 to 12 =>
								appear <='0';
							when 27 =>
								appear <= '1';
								flash_count := 0;
							when others =>
								appear <= '1';
						end case;
					end if;
				when "10" => scroll_speed <= 2;
				when "11" => appear <= '1';
			end case;
			--allow movement of current pipe
			if game_state = "11" or game_state = "00" then 
				enable <= '0';
			elsif init = '1' then
				enable <= '1';
			end if;
			-- start the next pipe
			if pipe_x_pos < screen_max_x - pipe_spacing then
				init_next <= '1';
			else 
				init_next <= '0';
			end if;
			-- reset the pipe
			if (pipe_x_pos < 0) or game_state = "00" then
				enable <= '0';
				pipe_x_pos <= screen_max_x + pipe_width;
				pipe_x_motion <= 0;
				pipe_height <= preset_pipe_heights(current_index);
				powerup_y_pos <= preset_powerup_heights(current_index);
				current_powerup <= preset_powerups(current_index);
				current_show_status <= preset_show(current_index);
			end if;
			--move the pipe
			if enable = '1' then
				if (pause_switch = '1') then
					pipe_x_motion <= 0;
				else
					pipe_x_motion <= scroll_speed;
				end if;
				pipe_x_pos <= pipe_x_pos - pipe_x_motion;
			elsif game_state /= "11" then
				pipe_height <= preset_pipe_heights(current_index);
				powerup_y_pos <= preset_powerup_heights(current_index);
				current_powerup <= preset_powerups(current_index);
				current_show_status <= preset_show(current_index);
			end if;
			--score pulse generation
			if pipe_x_pos < screen_halfway and pipe_x_pos > screen_halfway - score_pulse_debounce then
				score_pulse <= '1';
			else 
				score_pulse <= '0';
			end if;
		end if;
end process move_pipe;
end behaviour;
