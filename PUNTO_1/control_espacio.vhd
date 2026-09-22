library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_espacio is
    Port (
        reloj_50mhz      : in  STD_LOGIC;
        reiniciar        : in  STD_LOGIC;
        persona_presente : in  STD_LOGIC; 
        alarma_led       : out STD_LOGIC;
        felicitacion_led : out STD_LOGIC;
        display_decenas  : out STD_LOGIC_VECTOR(6 downto 0);
        display_unidades : out STD_LOGIC_VECTOR(6 downto 0)
    );
end control_espacio;

architecture Comportamiento of control_espacio is

    type estado_tipo is (LIBRE, CONTEO_35S, ALARMA_EXCESO, FELICITACION);
    signal estado_actual : estado_tipo := LIBRE;

    -- Divisor de reloj
    signal cnt_50mhz : integer range 0 to 49_999_999 := 0;
    signal pulso_1s  : STD_LOGIC := '0';
    
    -- Variables de tiempo
    signal seg : integer range 0 to 99 := 0;
    signal dec : integer range 0 to 9 := 0;
    signal uni : integer range 0 to 9 := 0;

    -- Decodificador BCD a 7 Segmentos
    function decodificar_7seg(digito : integer) return STD_LOGIC_VECTOR is
    begin
        case digito is
            when 0 => return "1000000"; -- 0
            when 1 => return "1111001"; -- 1
            when 2 => return "0100100"; -- 2
            when 3 => return "0110000"; -- 3
            when 4 => return "0011001"; -- 4
            when 5 => return "0010010"; -- 5
            when 6 => return "0000010"; -- 6
            when 7 => return "1111000"; -- 7
            when 8 => return "0000000"; -- 8
            when 9 => return "0010000"; -- 9
            when others => return "1111111"; -- Apagado
        end case;
    end function;

begin

    process(reloj_50mhz, reiniciar)
    begin
        if reiniciar = '0' then
            cnt_50mhz <= 0;
            pulso_1s <= '0';
        elsif rising_edge(reloj_50mhz) then
            if cnt_50mhz = 49_999_999 then
                cnt_50mhz <= 0;
                pulso_1s <= '1';
            else
                cnt_50mhz <= cnt_50mhz + 1;
                pulso_1s <= '0';
            end if;
        end if;
    end process;

    process(reloj_50mhz, reiniciar)
    begin
        -- Reset 
        if reiniciar = '0' then
            estado_actual <= LIBRE;
            seg <= 0;
            alarma_led <= '0';
            felicitacion_led <= '0';

        elsif rising_edge(reloj_50mhz) then
            alarma_led <= '0';
            felicitacion_led <= '0';

            case estado_actual is

                when LIBRE =>
                    seg <= 0;
                    if persona_presente = '1' then
                        estado_actual <= CONTEO_35S;
                    end if;

                when CONTEO_35S =>
                    if persona_presente = '0' then
                        -- Si la persona sale antes de los 35s, pasa a FELICITACION
                        estado_actual <= FELICITACION;
                    elsif pulso_1s = '1' then
                        if seg >= 35 then
                            estado_actual <= ALARMA_EXCESO;
                            seg <= 0; -- Reinicia contador a 0 para medir el tiempo extra
                        else
                            seg <= seg + 1;
                        end if;
                    end if;

                when ALARMA_EXCESO =>
                    alarma_led <= '1';
                    if persona_presente = '0' then
                        -- Al salir la persona tras la alarma, regresa a vacio osea 0
                        estado_actual <= LIBRE;
                    elsif pulso_1s = '1' then
                        if seg < 99 then
                            seg <= seg + 1; -- Incrementa tiempo de exceso
                        end if;
                    end if;

                when FELICITACION =>
                    felicitacion_led <= '1';
                    -- Se mantiene en FELICITACION con el LED encendido 
                    -- hasta que el switch baje a '0' Y se presione reiniciar o entre otra persoma
                    if persona_presente = '1' then
                        estado_actual <= CONTEO_35S;
                    end if;

            end case;
        end if;
    end process;

    -- Asignacion de las salidas a los displays
    dec <= seg / 10;
    uni <= seg rem 10;

    display_decenas  <= decodificar_7seg(dec);
    display_unidades <= decodificar_7seg(uni);

end Comportamiento;