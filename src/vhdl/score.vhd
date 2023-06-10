LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity score is 
    port(
        clk : IN STD_LOGIC;
        score_pulse : IN STD_LOGIC;
        game_state : IN STD_LOGIC_VECTOR(1 downto 0);
		level 		: OUT STD_LOGIC_VECTOR(1 downto 0);
        score_digits : OUT STD_LOGIC_VECTOR(11 downto 0)
    );
end entity;

architecture behaviour of score is
    signal current_score, high_score : integer range 0 to 999 := 0;
    signal last_score_pulse : STD_LOGIC := '0';
begin
	process(current_score) 
	begin
		case current_score is
			when 0 to 14 => level <= CONV_STD_LOGIC_VECTOR(1,2);
			when 15 to 34 => level <= CONV_STD_LOGIC_VECTOR(2,2);
			when others => level <= CONV_STD_LOGIC_VECTOR(3,2);
		end case;
	end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if game_state = "00" then
                current_score <= 0;
            end if;
            if score_pulse = '1' and last_score_pulse = '0' then
                current_score <= current_score + 1;
                if current_score >= high_score then
                    high_score <= current_score;
                end if;
            end if;
            last_score_pulse <= score_pulse;
        end if;
    end process;

    score_digits <= CONV_STD_LOGIC_VECTOR(current_score/100, 4)  
                    & CONV_STD_LOGIC_VECTOR((current_score/10) mod 10,4) 
                    & CONV_STD_LOGIC_VECTOR(current_score mod 10, 4);
end architecture behaviour;
