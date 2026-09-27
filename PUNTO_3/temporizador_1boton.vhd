library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_1boton is
    Port (
        reloj       : in  STD_LOGIC; 
        boton       : in  STD_LOGIC; -- Boton unico para Start/Stop y Reset (BOTON 0)
        display_min : out STD_LOGIC_VECTOR(6 downto 0); 
        display_dec : out STD_LOGIC_VECTOR(6 downto 0); 
        display_uni : out STD_LOGIC_VECTOR(6 downto 0)  
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

    -- Contador para el reloj (50MHz a 1Hz)
    signal cnt_50mhz : integer range 0 to 49_999_999 := 0;
    signal pulso_1s  : std_logic := '0';

    -- Variables para el tiempo(el minutero puede llegar hasta 9, segundo nunmero a 5 y tercero a 9)
    signal u_seg : integer range 0 to 9 := 0; -- Unidades de segundo (0 a 9)
    signal d_seg : integer range 0 to 5 := 0; -- Decenas de segundo (0 a 5)
    signal u_min : integer range 0 to 9 := 0; -- Minutos (0 a 9)
    
    -- Bandera para saber si el temporizador esta contando o pausado
    signal activo       : std_logic := '0';
    signal boton_prev   : std_logic := '1';
    signal cnt_presion  : integer range 0 to 2 := 0; -- Contador para medir el tiempo del boton
    signal reset_hecho  : boolean := false;

    -- Buses BCD para conectar a los displays
    signal bcd_u_seg : std_logic_vector(3 downto 0);
    signal bcd_d_seg : std_logic_vector(3 downto 0);
    signal bcd_u_min : std_logic_vector(3 downto 0);

begin

    -- Divisor de frecuencia: genera un pulso de 1 segundo
    process(reloj)
    begin
        if rising_edge(reloj) then
            if cnt_50mhz = 49_999_999 then
                cnt_50mhz <= 0;
                pulso_1s <= '1';
            else
                cnt_50mhz <= cnt_50mhz + 1;
                pulso_1s <= '0';
            end if;
        end if;
    end process;

    -- Control del boton unico y avance del tiempo
    process(reloj)
    begin
        if rising_edge(reloj) then
            
            -- Evalua el tiempo presionado del boton cada segundo
            if pulso_1s = '1' then
                
                -- Si el boton esta presionado (activo en 0)
                if boton = '0' then
                    if cnt_presion < 2 then
                        cnt_presion <= cnt_presion + 1;
                    end if;
                    
                    -- Reset al mantener presionado mas de 2 segundos
                    if cnt_presion >= 1 and not reset_hecho then
                        u_seg <= 0;
                        d_seg <= 0;
                        u_min <= 0;
                        activo <= '0';
                        reset_hecho <= true;
                    end if;
                else
                    cnt_presion <= 0;
                    reset_hecho <= false;
                end if;

                -- Incremento del temporizador cada segundo
                if activo = '1' then
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
                                activo <= '0'; -- Al llegar a 9:59 se detiene
                            end if;
                        end if;
                    end if;
                end if;
            end if;

            -- Detecta cuando se suelta el boton (pulsacion corta para Start/Stop)
            boton_prev <= boton;
            if boton_prev = '0' and boton = '1' then 
                if cnt_presion < 2 and not reset_hecho then
                    activo <= not activo; -- Alterna entre iniciar y pausar
                end if;
                cnt_presion <= 0;
            end if;

        end if;
    end process;

    -- Conversion de las variables enteras a vectores BCD de 4 bits
    bcd_u_seg <= std_logic_vector(to_unsigned(u_seg, 4));
    bcd_d_seg <= std_logic_vector(to_unsigned(d_seg, 4));
    bcd_u_min <= std_logic_vector(to_unsigned(u_min, 4));

    -- Instancias del decodificador para enviar la señal a cada pantalla
    U1: dec_7seg port map (num_bcd => bcd_u_seg, salida => display_uni);
    U2: dec_7seg port map (num_bcd => bcd_d_seg, salida => display_dec);
    U3: dec_7seg port map (num_bcd => bcd_u_min, salida => display_min);

end Arq_Temp;