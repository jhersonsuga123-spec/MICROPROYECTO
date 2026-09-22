library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Decodificador BCD a 7 seg
entity dec_7seg is
    port (
        num_bcd : in  std_logic_vector(3 downto 0);
        salida  : out std_logic_vector(6 downto 0)  
    );
end dec_7seg;

architecture Behavioral of dec_7seg is
begin
    process(num_bcd)
    begin
        case num_bcd is
            when "0000" => salida <= "1000000"; -- 0
            when "0001" => salida <= "1111001"; -- 1
            when "0010" => salida <= "0100100"; -- 2
            when "0011" => salida <= "0110000"; -- 3
            when "0100" => salida <= "0011001"; -- 4
            when "0101" => salida <= "0010010"; -- 5
            when "0110" => salida <= "0000010"; -- 6
            when "0111" => salida <= "1111000"; -- 7
            when "1000" => salida <= "0000000"; -- 8
            when "1001" => salida <= "0010000"; -- 9
            when others => salida <= "1111111"; 
        end case;
    end process;
end Behavioral;