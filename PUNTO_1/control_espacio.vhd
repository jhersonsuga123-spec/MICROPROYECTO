library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_espacio is
    Port (
        reloj_50mhz      : in  STD_LOGIC; -- Reloj DE0
        reiniciar        : in  STD_LOGIC; -- Boton reset (BTN0)
        persona_presente : in  STD_LOGIC; -- Switch sensor (SW0)
        alarma_led       : out STD_LOGIC; -- LED alarma
        felicitacion_led : out STD_LOGIC; -- LED bien hecho
        display_decenas  : out STD_LOGIC_VECTOR(6 downto 0);
        display_unidades : out STD_LOGIC_VECTOR(6 downto 0)  
    );
end control_espacio;

architecture Comportamiento of control_espacio is

    -- Para el pulso de 1 segundo (50MHz / 1Hz = 50M)
    signal contador_clk : integer range 0 to 49999999 := 0;
    signal tick_1s      : STD_LOGIC := '0';
    
    -- Contadores de tiempo
    signal segundos : integer range 0 to 99 := 0;
    signal decenas  : integer range 0 to 9 := 0;
    signal unidades : integer range 0 to 9 := 0;

    -- Banderas de control
    signal en_alarma       : std_logic := '0';
    signal en_felicitacion : std_logic := '0';
    signal persona_prev    : std_logic := '0';

    -- Decodificador a 7 seg
    function conv_7seg(num : integer) return STD_LOGIC_VECTOR is
    begin
        case num is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when others => return "1111111"; -- apagar
        end case;
    end function;

begin

    -- Divisor de 50MHz a 1Hz
    process(reloj_50mhz, reiniciar)
    begin
        if reiniciar = '0' then
            contador_clk <= 0;
            tick_1s <= '0';
        elsif rising_edge(reloj_50mhz) then
            if contador_clk = 49999999 then
                contador_clk <= 0;
                tick_1s <= '1';
            else
                contador_clk <= contador_clk + 1;
                tick_1s <= '0';
            end if;
        end if;
    end process;

    -- Control de tiempo
    process(reloj_50mhz, reiniciar)
    begin
        if reiniciar = '0' then
            segundos <= 0;
            en_alarma <= '0';
            en_felicitacion <= '0';
            persona_prev <= '0';

        elsif rising_edge(reloj_50mhz) then
            
            persona_prev <= persona_presente;

            -- Si sube el switch
            if persona_presente = '1' and persona_prev = '0' then
                en_felicitacion <= '0';
                en_alarma <= '0';
                segundos <= 0;

            -- Si baja el switch
            elsif persona_presente = '0' and persona_prev = '1' then
                if en_alarma = '0' then
                    en_felicitacion <= '1'; -- salio a tiempo
                else
                    en_alarma <= '0';
                    segundos <= 0;
                end if;
            end if;

            -- Conteo de segundos
            if persona_presente = '1' and tick_1s = '1' then
                if en_alarma = '0' then
                    if segundos >= 35 then
                        en_alarma <= '1'; -- sobrepaso el limite
                        segundos <= 0;
                    else
                        segundos <= segundos + 1;
                    end if;
                else
                    -- cuenta tiempo extra
                    if segundos < 99 then
                        segundos <= segundos + 1;
                    end if;
                end if;
            end if;

        end if;
    end process;

    -- Leds
    alarma_led       <= en_alarma;
    felicitacion_led <= en_felicitacion;

    -- Calculo para los dos displays
    decenas <= segundos / 10;
    unidades <= segundos rem 10;

    -- Salidas a los displays
    display_decenas  <= conv_7seg(decenas);
    display_unidades <= conv_7seg(unidades);

end Comportamiento;