-- Morteza (March 2023)
-- VHDL code for BCD to 7-Segment conversion
-- In this case, LED is on when it is '0'   
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY BCD_to_SevenSeg IS
	PORT (
		BCD_digit : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		SevenSeg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END ENTITY;

ARCHITECTURE arc1 OF BCD_to_SevenSeg IS
BEGIN
	SevenSeg_out <= "1111001" WHEN BCD_digit = "0001" ELSE -- 1
		"0100100" WHEN BCD_digit = "0010" ELSE -- 2
		"0110000" WHEN BCD_digit = "0011" ELSE -- 3
		"0011001" WHEN BCD_digit = "0100" ELSE -- 4
		"0010010" WHEN BCD_digit = "0101" ELSE -- 5
		"0000010" WHEN BCD_digit = "0110" ELSE -- 6
		"1111000" WHEN BCD_digit = "0111" ELSE -- 7
		"0000000" WHEN BCD_digit = "1000" ELSE -- 8
		"0010000" WHEN BCD_digit = "1001" ELSE -- 9
		"1000000" WHEN BCD_digit = "0000" ELSE -- 0
		"1111111";
END ARCHITECTURE arc1;