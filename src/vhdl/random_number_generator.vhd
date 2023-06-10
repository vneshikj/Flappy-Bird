LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;

entity random_number_generator is
    port (clk : in std_logic;
          reset : in std_logic;
          random_out : out std_logic_vector(3 downto 0));
end random_number_generator;

architecture Behavioral of random_number_generator is
    signal lfsr_reg : std_logic_vector(3 downto 0) := "0001"; -- Initial seed value
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            lfsr_reg <= "0001"; -- Reset the LFSR to the initial seed value
        elsif (rising_edge(clk)) then
            -- and operation acts as shift to produce next state
            lfsr_reg <= lfsr_reg(2 downto 0) & (lfsr_reg(3) XOR lfsr_reg(2)); -- LFSR update equation
        end if;
    end process;

    random_out <= lfsr_reg; -- Output the current state of the LFSR as the pseudo-random 3 bit number
end Behavioral;
