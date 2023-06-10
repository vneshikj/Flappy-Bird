LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity display_text is 
	port(
			clk : IN STD_LOGIC;
			horiz_sync : IN STD_LOGIC;
			score : IN STD_LOGIC_VECTOR(11 downto 0);
			health_percentage : IN STD_LOGIC_VECTOR(11 downto 0);
			game_state, level: IN STD_LOGIC_VECTOR(1 downto 0);
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			text_rgb : OUT STD_LOGIC_VECTOR(11 downto 0);
			text_on : OUT STD_LOGIC 
		);
end display_text;

architecture behaviour of display_text is
--CONSTANTS
CONSTANT score_start_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(70, 10);
CONSTANT health_start_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(30, 10);
CONSTANT game_over_start_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(220,10);
CONSTANT train_button_start_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(200, 10);
CONSTANT game_button_start_y : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(250,10);

CONSTANT score_rad_100_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(250, 10);
CONSTANT score_rad_10_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(300, 10);
CONSTANT score_rad_1_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(350, 10);

CONSTANT heart_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(472, 10);
CONSTANT health_rad_100_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(512, 10);
CONSTANT health_rad_10_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(552, 10);
CONSTANT health_rad_1_start_x : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(592, 10);

CONSTANT button_height : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(50,10);
CONSTANT button_width : STD_LOGIC_VECTOR(9 downto 0) := CONV_STD_LOGIC_VECTOR(250, 10);
CONSTANT number_rom_offset : STD_LOGIC_VECTOR(5 downto 0) := CONV_STD_LOGIC_VECTOR(48,6);

--SIGNALS
SIGNAL temp_text_on, temp_text_on_1,temp_text_on_10,temp_text_on_100, 
	temp_percent_on_1, temp_percent_on_10, temp_percent_on_100, heart_on, t_go_G_on, t_go_a_on, t_go_m_on, t_go_e1_on, t_go_space_on, t_go_O_on, t_go_v_on, t_go_e2_on, t_go_r_on, t_lv_l1_on, t_lv_e1_on, t_lv_v_on, t_lv_e2_on, t_lv_l2_on, t_curr_lvl_on, t_trb_t_on, t_trb_r_on, t_trb_a_on, t_trb_i_on, t_trb_n_on, t_gmb_g_on, t_gmb_a_on, t_gmb_m_on, t_gmb_e_on, buttons_on, train_button_on, game_button_on, level_on, game_over_on: STD_LOGIC;
SIGNAL radix_100_score, radix_10_score, radix_1_score: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL radix_100_score_add, radix_10_score_add, radix_1_score_add, radix_100_health, radix_10_health, radix_1_health : STD_LOGIC_VECTOR(5 downto 0);
component sprite_8bit
	generic (
		  	scale : STD_LOGIC_VECTOR(9 downto 0) 			
		);
	port (
			clk, reset, horiz_sync : IN STD_LOGIC;
			rom_address : IN STD_LOGIC_VECTOR(5 downto 0);
			sprite_row, sprite_column, 
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 downto 0);
			sprite_on: OUT STD_LOGIC
		 );
end component;
begin

radix_100_score <= score(11 downto 8);
radix_10_score <= score(7 downto 4);
radix_1_score <= score(3 downto 0);

radix_100_health <= "00" & health_percentage(11 downto 8) + number_rom_offset;
radix_10_health <= "00" & health_percentage(7 downto 4) + number_rom_offset;
radix_1_health <= "00" & health_percentage(3 downto 0) + number_rom_offset;

radix_1_score_add <= "00" & radix_1_score + number_rom_offset; 
radix_10_score_add <= "00" & radix_10_score + number_rom_offset; 
radix_100_score_add <= "00" & radix_100_score + number_rom_offset; 

-- ---------------------------------------------------------
-- score
-- ---------------------------------------------------------
radix_1_score_text : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(3,10)
			)
port map(
		clk, '0', horiz_sync,radix_1_score_add,score_start_y,score_rad_1_start_x, pixel_row, pixel_column, temp_text_on_1
		);

radix_10_score_text : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(3,10)
			)
port map(
		clk, '0', horiz_sync,radix_10_score_add,score_start_y,score_rad_10_start_x, pixel_row, pixel_column, temp_text_on_10
		);

radix_100_score_text : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(3,10)
			)
port map(
		clk, '0', horiz_sync,radix_100_score_add,score_start_y,score_rad_100_start_x, pixel_row, pixel_column, temp_text_on_100
		);
-- ---------------------------------------------------------
-- ---------------------------------------------------------
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- HEALTH
-- ---------------------------------------------------------
heart : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync,CONV_STD_LOGIC_VECTOR(36,6),health_start_y,heart_start_x, pixel_row, pixel_column, heart_on

		);
radix_1_health_text : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync,radix_1_health,health_start_y,health_rad_1_start_x, pixel_row, pixel_column, temp_percent_on_1

		);

radix_10_health_text : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, radix_10_health,health_start_y,health_rad_10_start_x, pixel_row, pixel_column, temp_percent_on_10
		);

radix_100_health_text : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, radix_100_health,health_start_y,health_rad_100_start_x, pixel_row, pixel_column, temp_percent_on_100
		);

-- ---------------------------------------------------------
-- ---------------------------------------------------------
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- GAME OVER (GO)
-- ---------------------------------------------------------

go_G : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(7,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(140,10), pixel_row, pixel_column, t_go_G_on
		);


go_A : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(1,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(180,10), pixel_row, pixel_column, t_go_a_on
		);

go_M : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(13,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(220,10), pixel_row, pixel_column, t_go_m_on
		);

go_E1 : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(5,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(260,10), pixel_row, pixel_column, t_go_e1_on
		);

go_O : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(15,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(340,10), pixel_row, pixel_column, t_go_O_on
		);

go_V : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(22,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(380,10), pixel_row, pixel_column, t_go_v_on
		);

go_E2 : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(5,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(420,10), pixel_row, pixel_column, t_go_e2_on
		);


go_R : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(18,6),game_over_start_y,CONV_STD_LOGIC_VECTOR(460,10), pixel_row, pixel_column, t_go_r_on
		);

game_over_on <= '1' when (t_go_G_on = '1' or t_go_a_on = '1' or t_go_m_on = '1' or t_go_e1_on = '1' or t_go_space_on = '1' or t_go_O_on = '1' or t_go_v_on = '1' or t_go_e2_on = '1' or t_go_r_on = '1') and game_state ="11" else '0'; 
-- ---------------------------------------------------------
-- ---------------------------------------------------------
-- ---------------------------------------------------------


-- ---------------------------------------------------------
-- LEVEL (LV)
-- ---------------------------------------------------------

lv_l1 : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(12,6),health_start_y,CONV_STD_LOGIC_VECTOR(10,10), pixel_row, pixel_column, t_lv_l1_on
		);

lv_e1 : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(5,6),health_start_y,CONV_STD_LOGIC_VECTOR(50,10), pixel_row, pixel_column, t_lv_e1_on
		);

lv_v : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(22,6),health_start_y,CONV_STD_LOGIC_VECTOR(90,10), pixel_row, pixel_column, t_lv_v_on
		);

lv_e2 : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(5,6),health_start_y,CONV_STD_LOGIC_VECTOR(130,10), pixel_row, pixel_column, t_lv_e2_on
		);

lv_l2 : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(12,6),health_start_y,CONV_STD_LOGIC_VECTOR(170,10), pixel_row, pixel_column, t_lv_l2_on
		);

current_level : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, "0000" & level + number_rom_offset,health_start_y,CONV_STD_LOGIC_VECTOR(220,10), pixel_row, pixel_column, t_curr_lvl_on
		);

level_on <= '1' when (t_lv_l1_on = '1' or t_lv_e1_on = '1' or t_lv_v_on = '1' or t_lv_e2_on = '1' or t_lv_l2_on = '1' or t_curr_lvl_on = '1') and game_state = "01" else '0';
-- ---------------------------------------------------------
-- ---------------------------------------------------------
-- ---------------------------------------------------------


-- ---------------------------------------------------------
-- MENU 
-- TRAIN BUTTON (TRB)
-- GAME BUTTON (GMB)
-- ---------------------------------------------------------

-- Train 
trb_t : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(20,6),train_button_start_y,CONV_STD_LOGIC_VECTOR(225,10), pixel_row, pixel_column, t_trb_t_on
		);

trb_r : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(18,6),train_button_start_y,CONV_STD_LOGIC_VECTOR(265,10), pixel_row, pixel_column, t_trb_r_on
		);

trb_a : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(1,6),train_button_start_y,CONV_STD_LOGIC_VECTOR(305,10), pixel_row, pixel_column, t_trb_a_on
		);

trb_i : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(9,6),train_button_start_y,CONV_STD_LOGIC_VECTOR(345,10), pixel_row, pixel_column, t_trb_i_on
		);

trb_n : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(14,6),train_button_start_y,CONV_STD_LOGIC_VECTOR(385,10), pixel_row, pixel_column, t_trb_n_on
		);
train_button_on <= '1' when (t_trb_t_on = '1' or t_trb_r_on ='1' or t_trb_a_on = '1' or t_trb_i_on = '1' or t_trb_n_on ='1') else '0';
-- Game
gmb_g : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(7,6),game_button_start_y,CONV_STD_LOGIC_VECTOR(260,10), pixel_row, pixel_column, t_gmb_g_on
		);

gmb_a : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(1,6),game_button_start_y,CONV_STD_LOGIC_VECTOR(300,10), pixel_row, pixel_column, t_gmb_a_on
		);

gmb_m : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(13,6),game_button_start_y,CONV_STD_LOGIC_VECTOR(340,10), pixel_row, pixel_column, t_gmb_m_on
		);

gmb_e : sprite_8bit 
generic map (
				CONV_STD_LOGIC_VECTOR(2,10)
			)
port map(
		clk, '0', horiz_sync, CONV_STD_LOGIC_VECTOR(5,6),game_button_start_y,CONV_STD_LOGIC_VECTOR(380,10), pixel_row, pixel_column, t_gmb_e_on
		);

game_button_on <= '1' when (t_gmb_g_on = '1' or t_gmb_a_on = '1' or t_gmb_m_on = '1' or t_gmb_e_on = '1') else '0';

--both
buttons_on <= '1' when (game_button_on = '1' or train_button_on = '1') and game_state = "00" else '0';
-- ---------------------------------------------------------
-- ---------------------------------------------------------
-- ---------------------------------------------------------

temp_text_on <= '1' when (level_on ='1' or game_over_on='1' or buttons_on = '1' or temp_text_on_1 = '1' or temp_text_on_10 = '1' or temp_text_on_100 = '1' or heart_on = '1' or temp_percent_on_1 = '1' or temp_percent_on_10 ='1' or temp_percent_on_100 = '1') else '0';
text_rgb <= "111111111111" 
			when temp_text_on = '1' and heart_on = '0' 
		else "111000000000" when temp_text_on = '1' and heart_on = '1'
		else "000000000000";

text_on <= temp_text_on; --when


end architecture behaviour;

