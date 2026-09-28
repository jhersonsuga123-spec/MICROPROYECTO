library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_1boton is
    Port (
        reloj       : in  STD_LOGIC; 
        boton       : in  STD_LOGIC; -- BOTON 2
        display_min : out STD_LOGIC_VECTOR(6 downto 0); 
        display_dec : out STD_LOGIC_VECTOR(6 downto 0); 
        display_uni : out STD_LOGIC_VECTOR(6 downto 0);
        punto_min   : out STD_LOGIC 
    );
end temporizador_1boton;

architecture Arq_Temp of temporizador_1boton is

    -- Componente del decodificador 7 segmentos BCD
    component dec_7seg is
        Port (
            num_bcd : in  STD_LOGIC_VECTOR(3 downto 0);
            salida  : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Divisor de 50MHz a 1Hz (Segundos)
    signal cnt_50mhz : integer range 0 to 49_999_999 := 0;
    signal pulso_1s  : std_logic := '0';

    -- Divisor de 50MHz a 100Hz (10ms para lectura precisa del botón)
    signal cnt_10ms   : integer range 0 to 499_999 := 0;
    signal pulso_10ms : std_logic := '0';

    -- Variables para el tiempo
    signal u_seg : integer range 0 to 9 := 0; 
    signal d_seg : integer range 0 to 5 := 0; 
    signal u_min : integer range 0 to 9 := 0; 
    
    -- Control del temporizador y botón
    signal activo       : std_logic := '0';
    signal boton_prev   : std_logic := '1';
    
    -- Contador de tiempo de presión en pasos de 10ms (200 * 10ms = 2 segundos)
    signal cnt_presion  : integer range 0 to 250 := 0; 
    signal reset_hecho  : boolean := false;

    -- Buses BCD
    signal bcd_u_seg : std_logic_vector(3 downto 0);
    signal bcd_d_seg : std_logic_vector(3 downto 0);
    signal bcd_u_min : std_logic_vector(3 downto 0);

begin

    -- Generador de pulsos de tiempo (1s y 10ms)
    process(reloj)
    begin
        if rising_edge(reloj) then
            -- Pulso de 1 segundo
            if cnt_50mhz = 49_999_999 then
                cnt_50mhz <= 0;
                pulso_1s <= '1';
            else
                cnt_50mhz <= cnt_50mhz + 1;
                pulso_1s <= '0';
            end if;

            -- Pulso de 10 milisegundos
            if cnt_10ms = 499_999 then
                cnt_10ms <= 0;
                pulso_10ms <= '1';
            else
                cnt_10ms <= cnt_10ms + 1;
                pulso_10ms <= '0';
            end if;
        end if;
    end process;

    -- Lógica principal del temporizador y control por botón (Un solo proceso)
    process(reloj)
    begin
        if rising_edge(reloj) then
            
            -- 1. LÓGICA DEL BOTÓN (Muestreado cada 10 ms)
            if pulso_10ms = '1' then
                boton_prev <= boton;

                if boton = '0' then
                    if cnt_presion < 200 then
                        cnt_presion <= cnt_presion + 1;
                    end if;

                    -- Si se mantiene presionado por 2 segundos (200 * 10ms)
                    if cnt_presion >= 200 and not reset_hecho then
                        u_seg <= 0;
                        d_seg <= 0;
                        u_min <= 0;
                        activo <= '0';
                        reset_hecho <= true;
                    end if;
                else
                    -- Al soltar el botón (Flanco de subida)
                    if boton_prev = '0' then 
                        if cnt_presion < 200 and not reset_hecho then
                            activo <= not activo; -- Pulsación corta: Start / Stop
                        end if;
                    end if;
                    
                    cnt_presion <= 0;
                    reset_hecho <= false;
                end if;
            end if;

            -- 2. AVANCE DEL TEMPORIZADOR (Muestreado cada 1 segundo)
            if pulso_1s = '1' and activo = '1' then
                if u_seg < 9 then
                    u_seg <= u_seg + 1;
                else
                    u_seg <= 0;
                    if d_seg < 5 then
                        d_seg <= d_seg + 1;
                    else
                        d_seg <= 0;
                        if u_min < 9 then
                            u_min <= u_min + 1;
                        else
                            activo <= '0'; -- Llega a 9:59 y se detiene
                        end if;
                    end if;
                end if;
            end if;

        end if;
    end process;

    -- Conversiones a BCD
    bcd_u_seg <= std_logic_vector(to_unsigned(u_seg, 4));
    bcd_d_seg <= std_logic_vector(to_unsigned(d_seg, 4));
    bcd_u_min <= std_logic_vector(to_unsigned(u_min, 4));

    -- Instancias del decodificador
    U1: dec_7seg port map (num_bcd => bcd_u_seg, salida => display_uni);
    U2: dec_7seg port map (num_bcd => bcd_d_seg, salida => display_dec);
    U3: dec_7seg port map (num_bcd => bcd_u_min, salida => display_min);
    
    punto_min <= '0'; 

end Arq_Temp;