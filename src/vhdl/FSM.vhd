LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY FSM IS

   PORT (
      clk_in, reset, mouse_click : IN STD_LOGIC;
   	collision : IN STD_LOGIC_VECTOR(2 downto 0);
   	mouse_row, mouse_column : IN STD_LOGIC_VECTOR(9 downto 0);
   	invincible : OUT STD_LOGIC;
      state_out : OUT STD_LOGIC_VECTOR(1 downto 0) := "00";	  
	  health : OUT STD_LOGIC_VECTOR(11 downto 0));
END ENTITY FSM;
-- Output of FSM is game state (menu, NORMAL GAME, GAME OVER, training)


ARCHITECTURE Moore OF FSM IS
	CONSTANT debounce_time : Integer := 4000000;
	CONSTANT pipe_collision_debounce_time :Integer := 24000000;
	CONSTANT invincibility_period : Integer := 35000000;

	CONSTANT train_button_start_y : STD_LOGIC_VECTOR(9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(200, 10));
	CONSTANT game_button_start_y : STD_LOGIC_VECTOR(9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(250, 10));
	CONSTANT button_start_x : STD_LOGIC_VECTOR(9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(225,10));
	CONSTANT button_height : STD_LOGIC_VECTOR(9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(30,10));
	CONSTANT button_width : STD_LOGIC_VECTOR(9 downto 0) := STD_LOGIC_VECTOR(to_unsigned(250, 10));

	SIGNAL max_collisions : INTEGER range 0 to 1000000:= 15000;
   -- define states
   type state_type is (game_start, normal_mode, training_mode, game_over);
   SIGNAL current_state, next_state : state_type := game_start;
   SIGNAL in_game_button, in_train_button : STD_LOGIC;
   SIGNAL count : Integer range 0 to 25000000;
   SIGNAL collision_count : Integer range 0 to 1000000 := 0;
	SIGNAL mouse_click_prev : std_logic := '0';
   SIGNAL health_percentage : unsigned(6 downto 0);

BEGIN
	in_game_button <= '1' 
					  when mouse_row >= game_button_start_y 
					  and mouse_row <= game_button_start_y + button_height 
					  and mouse_column >= button_start_x 
					  and mouse_column <= button_start_x + button_width else '0';
	in_train_button <= '1' 
					  when mouse_row >= train_button_start_y 
					  and mouse_row <= train_button_start_y + button_height 
					  and mouse_column >= button_start_x 
					  and mouse_column <= button_start_x + button_width else '0';

  calculate_percentage : process(collision_count, max_collisions)
    variable temp : integer;
  begin
    if max_collisions = 0 then
      temp := 100;
	elsif current_state = game_over then
		temp:= 100;
	elsif current_state = game_start then
		temp:= 0;
    else
      temp := (collision_count * 100) / max_collisions;
    end if;

    health_percentage <= unsigned(to_signed(100 - temp, health_percentage'length));
   health <= std_logic_vector(to_unsigned(to_integer(health_percentage)/100, 4))
              & std_logic_vector(to_unsigned((to_integer(health_percentage) mod 100)/10, 4))
              & std_logic_vector(to_unsigned(to_integer(health_percentage) mod 10, 4));
  end process calculate_percentage;
   -- process to describe state transitions
   transition : process (clk_in, current_state, collision, mouse_click)
	variable invincibility_count : Integer range 0 to 750000000:= 0;
	variable is_invincible : STD_LOGIC := '0';
   BEGIN
	   if Rising_Edge(clk_in) then
		  CASE (current_state) IS
			 WHEN game_start =>
				 state_out <= "00";
				if count >= debounce_time and mouse_click = '1' and mouse_click_prev ='0' and in_game_button = '1' then
				   next_state <= normal_mode;
				elsif count >= debounce_time and mouse_click = '1' and mouse_click_prev ='0' and in_train_button = '1' then
				   next_state <= training_mode;
			   elsif count >= debounce_time then
				   count <= debounce_time;
				else
					count <= count + 1;
				   next_state <= game_start; 
				end if;
			 WHEN normal_mode =>
				 state_out <= "01";
				 case collision is 
					 when "000" => 
						next_state <= normal_mode;
						if invincibility_count <= invincibility_period and is_invincible = '1' then
							invincibility_count := invincibility_count + 1;
						elsif invincibility_count >= invincibility_period and is_invincible = '1' then  
							invincibility_count := 0;
							is_invincible := '0';
						end if;
					 when "001" => 
						 if invincibility_count <= invincibility_period and is_invincible = '1' then
							next_state <= normal_mode;
							invincibility_count := invincibility_count + 1;
						elsif invincibility_count >= invincibility_period and is_invincible = '1' then  
							invincibility_count := 0;
							is_invincible := '0';
						else 
							if (collision_count > max_collisions) then
							  next_state <= game_over;
							  count <= 0;
							  collision_count <= 0;
							else
								collision_count <= collision_count + 1;
							end if;
						end if;
					 when "010" => 
						 next_state <= game_over;
						 collision_count <= 0;
						 count <= 0;
					when "011" =>
						next_state <= normal_mode;
						collision_count <= 0;
					when "100" =>
						next_state <= normal_mode;
						invincibility_count := 0;
						is_invincible := '1';
						
					when "101" =>
						 next_state <= game_over;
						 collision_count <= 0;
						 count <= 0;
					 when others => 
						 next_state <= normal_mode;
				end case;
			 WHEN game_over =>
				 state_out <= "11";
				 is_invincible := '0';

				if count >= debounce_time and mouse_click = '1' and mouse_click_prev ='0' then
				   next_state <= game_start;
				   count <= 0;
			   elsif count >= debounce_time then
				   count <= debounce_time;
				else
					count <= count + 1;
				   next_state <= game_over; 
				end if;
			 WHEN training_mode =>
				 state_out <= "10";
				 case collision is 
					 when "000" => next_state <= training_mode;
					 when "001" => 
						if (collision_count > max_collisions) then
						  next_state <= game_over;
						  count <= 0;
						  collision_count <= 0;
						else
							collision_count <= collision_count + 1;
						end if;

					 when "010" => 
						 next_state <= game_over;
						 collision_count <= 0;
						 count <= 0;
					 when others => 
						 next_state <= training_mode;
				end case;
		  END CASE;
		current_state <= next_state;
		invincible <= is_invincible;
		mouse_click_prev <= mouse_click;
		end if;
	  
   end process;

END ARCHITECTURE Moore;
