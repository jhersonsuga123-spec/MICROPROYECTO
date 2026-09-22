library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_3botones is
    Port (
        reloj       : in  STD_LOGIC; 
        boton_start : in  STD_LOGIC; 
        boton_stop  : in  STD_LOGIC; 
        boton_reset : in  STD_LOGIC; 
        display_min : out STD_LOGIC_VECTOR(6 downto 0); 
        display_dec : out STD_LOGIC_VECTOR(6 downto 0); 
        display_uni : out STD_LOGIC_VECTOR(6 downto 0) 
    );
end temporizador_3botones;

architecture Arq_Temp of temporizador_3botones is

    component dec_7seg is
        Port (
            num_bcd : in  STD_LOGIC_VECTOR(3 downto 0);
            salida  : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    
    signal cnt_50mhz : integer range 0 to 49_999_999 := 0;
    signal pulso_1s  : std_logic := '0';

    
    signal u_seg : integer range 0 to 9 := 0; 
    signal d_seg : integer range 0 to 5 := 0;
    signal u_min : integer range 0 to 9 := 0; 
    
    signal activo : std_logic := '0';

   
    signal bcd_u_seg : std_logic_vector(3 downto 0);
    signal bcd_d_seg : std_logic_vector(3 downto 0);
    signal bcd_u_min : std_logic_vector(3 downto 0);

begin

    
    process(reloj, boton_reset)
    begin
        if boton_reset = '0' then 
            cnt_50mhz <= 0;
            pulso_1s <= '0';
        elsif rising_edge(reloj) then
            if cnt_50mhz = 49_999_999 then
                cnt_50mhz <= 0;
                pulso_1s <= '1';
            else
                cnt_50mhz <= cnt_50mhz + 1;
                pulso_1s <= '0';
            end if;
        end if;
    end process;

   
    process(reloj, boton_reset)
    begin
      
        if boton_reset = '0' then 
            u_seg  <= 0;
            d_seg  <= 0;
            u_min  <= 0;
            activo <= '0';

        elsif rising_edge(reloj) then

          
            if boton_start = '0' then     
                activo <= '1';
            elsif boton_stop = '0' then  
                activo <= '0';
            end if;

           
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
                            
                            activo <= '0';
                        end if;
                    end if;
                end if;
            end if;

        end if;
    end process;

    bcd_u_seg <= std_logic_vector(to_unsigned(u_seg, 4));
    bcd_d_seg <= std_logic_vector(to_unsigned(d_seg, 4));
    bcd_u_min <= std_logic_vector(to_unsigned(u_min, 4));

   
    U1: dec_7seg port map (num_bcd => bcd_u_seg, salida => display_uni);
    U2: dec_7seg port map (num_bcd => bcd_d_seg, salida => display_dec);
    U3: dec_7seg port map (num_bcd => bcd_u_min, salida => display_min);

end Arq_Temp;