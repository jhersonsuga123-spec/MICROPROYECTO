library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec_7seg is
    Port (
        num_bcd : in  STD_LOGIC_VECTOR(3 downto 0);
        salida  : out STD_LOGIC_VECTOR(6 downto 0)  
    );
end dec_7seg;

architecture Behavioral of dec_7seg is
begin
    process(num_bcd)
    begin
        case num_bcd is
            when "0000" => salida <= "1111110";
            when "0001" => salida <= "0110000"; 
            when "0010" => salida <= "1101101"; 
            when "0011" => salida <= "1111001"; 
            when "0100" => salida <= "0110011"; 
            when "0101" => salida <= "1011011"; 
            when "0110" => salida <= "1011111"; 
            when "0111" => salida <= "1110000"; 
            when "1000" => salida <= "1111111"; 
            when "1001" => salida <= "1111011"; 
            when others => salida <= "0000000"; 
        end case;
    end process;
end Behavioral;
-- bloque que voy a utilizaer