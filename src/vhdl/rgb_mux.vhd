LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity rgb_mux is
	port(
			select_bit : IN STD_LOGIC; 
			rgb_in_0, rgb_in_1: IN STD_LOGIC_VECTOR(11 downto 0);
			rgb_out : OUT STD_LOGIC_VECTOR(11 downto 0)
		);
end rgb_mux; 

architecture behaviour of rgb_mux is
begin
rgb_out <= rgb_in_1 when select_bit = '1' else rgb_in_0;
end architecture behaviour;
