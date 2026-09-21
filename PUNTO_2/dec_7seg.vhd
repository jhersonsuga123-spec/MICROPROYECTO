library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Decodificador de BCD a 7 segmentos
entity dec_7seg is
    port (
        num_bcd : in  std_logic_vector(3 downto 0);
        salida  : out std_logic_vector(6 downto 0)  
    );
end dec_7seg;

architecture Behavioral of dec_7seg is
begin
    -- Evaluamos el numero de entrada para activar los segmentos
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