library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- la libreria para convertir el integer a binario

entity temporizador_3botones is
    Port (
        reloj       : in  STD_LOGIC; -- la senal de 1Hz
        boton_start : in  STD_LOGIC; -- pulsador para arrancar
        boton_stop  : in  STD_LOGIC; -- pulsador para pausar
        boton_reset : in  STD_LOGIC; -- pulsador para poner todo a cero
        display_min : out STD_LOGIC_VECTOR(6 downto 0); -- display de los minutos
        display_dec : out STD_LOGIC_VECTOR(6 downto 0); -- decenas de segundo (0 a 5)
        display_uni : out STD_LOGIC_VECTOR(6 downto 0)  -- unidades de segundo (0 a 9)
    );
end temporizador_3botones;

architecture Arq_Temp of temporizador_3botones is

    -- Traigo el decodificador de 7 segmentos que hice en el otro archivo
    component dec_7seg is
        Port (
            num_bcd : in  STD_LOGIC_VECTOR(3 downto 0);
            salida  : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Variables para el conteo de tiempo (los puse como integer para no complicarme con binarios)
    signal u_seg : integer range 0 to 9 := 0; 
    signal d_seg : integer range 0 to 5 := 0; -- este solo llega a 5 porque son los segundos
    signal u_min : integer range 0 to 9 := 0; 
    
    -- Esta variable es para saber si el reloj se mueve o esta en pausa
    signal activo : std_logic := '0';

    -- Cables auxiliares para mandarle los datos al decodificador
    signal bcd_u_seg : std_logic_vector(3 downto 0);
    signal bcd_d_seg : std_logic_vector(3 downto 0);
    signal bcd_u_min : std_logic_vector(3 downto 0);

begin

    -- Proceso principal para los botones y los contadores
    process(reloj, boton_reset)
    begin
        -- Si hundo el reset se borra todo
        if boton_reset = '1' then
            u_seg  <= 0;
            d_seg  <= 0;
            u_min  <= 0;
            activo <= '0';
        elsif rising_edge(reloj) then
            
            -- Reviso los botones de start y stop
            if boton_start = '1' then
                activo <= '1'; -- empieza a contar
            elsif boton_stop = '1' then
                activo <= '0'; -- se congela el tiempo
            end if;

            -- Solo avanza si activo esta en '1'
            if activo = '1' then
                if u_seg < 9 then
                    u_seg <= u_seg + 1;
                else
                    u_seg <= 0; -- si llega a 9 pasa a 0 y suma a las decenas
                    if d_seg < 5 then
                        d_seg <= d_seg + 1;
                    else
                        d_seg <= 0; -- cuando llega a 59 segundos pasa a 0 y suma un minuto
                        if u_min < 9 then
                            u_min <= u_min + 1;
                        else
                            -- Si llega al tope (9:59) se para solo para que no se desborde
                            activo <= '0';
                        end if;
                    end if;
                end if;
            end if;

        end if;
    end process;

    -- Convierto los integers a 4 bits para que los entienda el decodificador
    bcd_u_seg <= std_logic_vector(to_unsigned(u_seg, 4));
    bcd_d_seg <= std_logic_vector(to_unsigned(d_seg, 4));
    bcd_u_min <= std_logic_vector(to_unsigned(u_min, 4));

    -- Conecto las salidas a los 3 displays usando el decodificador
    U1: dec_7seg port map (num_bcd => bcd_u_seg, salida => display_uni);
    U2: dec_7seg port map (num_bcd => bcd_d_seg, salida => display_dec);
    U3: dec_7seg port map (num_bcd => bcd_u_min, salida => display_min);

end Arq_Temp;