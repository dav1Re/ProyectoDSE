library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ind_vuelta is
    port (
        clk : in STD_LOGIC;  -- Reloj
        reset : in STD_LOGIC; -- Reset 
        enable : in STD_LOGIC;  -- Enable (Para parar y continuar la cuenta)   
        fila_pos_persona : in unsigned(5 downto 0); 
        col_pos_persona  : in unsigned(5 downto 0);
        fila_pos_bot     : in unsigned(5 downto 0);  
        col_pos_bot      : in unsigned(5 downto 0);  
        num_memo_segundos: out STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Valor numerico de salida, indica el numero seleccionado en la memoria
        num_memo_decenas:  out std_logic_vector(4 downto 0);        
        num_memo_minutos:  out std_logic_vector(4 downto 0);       
        vuelta_persona_memo  : out unsigned(4 downto 0);          
        vuelta_bot_memo      : out unsigned(4 downto 0)          
    );
end ind_vuelta;

architecture Behavioral of ind_vuelta is

            -- Componentes del diseño estructural

    component contador is  -- Lleva la cuenta
    
    generic (N_BITS : integer := 10; --Numero de bits del contador
        END_COUNT : integer := 1024 --Valor fin de cuenta
    );
    port(
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        ud_count : in STD_LOGIC;
        fcount : out STD_LOGIC;
        count : out STD_LOGIC_VECTOR(N_BITS-1 downto 0)
    );
    end component;        

    --Señales cronometro
    
    signal S1dec, S1seg, S10seg, S60seg: std_logic; -- Señales de salida de contador    
    signal E10dec, E10seg, E60seg, Eminutos : std_logic; -- Señales de entrada de contador    
    signal decimas, segundos, decenas, minutos: std_logic_vector(3 downto 0);  
     
    signal fila_pos_meta, col_pos_meta, fila_pos_ref1, col_pos_ref1 : unsigned(5 downto 0);     
    signal checkpoint_persona, checkpoint_bot: std_logic; 
    signal vuelta_persona_s, vuelta_bot_s: unsigned(2 downto 0);         



begin
    
    -- Operaciones intermedias entre señales de contadores
    
    E10dec <= enable and S1dec;
    E10seg <= E10dec and S1seg;
    E60seg <= E10seg and S10seg;
    Eminutos <= E60seg and S60seg;                  

        -- Conexion entre componentes y señales

    contador1decima: contador
        generic map (
            N_BITS => 24,
            END_COUNT => 10**7  --10**7 para simulacion
        )
        port map (
            clk => clk,
            reset => reset,
            enable => enable,
            ud_count => '1',
            fcount => S1dec,
            count =>OPEN           
        ); 
        
        
    contador10decimas: contador
        generic map (
            N_BITS => 4,
            END_COUNT => 10
        )
        port map (
            clk => clk,
            reset => reset,
            enable => E10dec,
            ud_count => '1',
            fcount => S1seg,
            count => decimas            
        );              
        
      contador10segundos: contador
        generic map (
            N_BITS => 4,
            END_COUNT =>10 
        )
        port map (
            clk => clk,
            reset => reset,
            enable => E10seg,
            ud_count => '1',
            fcount => S10seg,
            count => segundos            
        );    
        
      contador60segundos: contador
        generic map (
            N_BITS => 4,
            END_COUNT =>6
        )
        port map (
            clk => clk,
            reset => reset,
            enable => E60seg,
            ud_count => '1',
            fcount => S60seg,
            count => decenas            
        );        
        
       contador10minutos: contador
        generic map (
            N_BITS => 4,
            END_COUNT => 10
        )
        port map (
            clk => clk,
            reset => reset,
            enable => Eminutos,
            ud_count => '1',
            fcount => OPEN,
            count => minutos           
        );                                                                                
        
        
        -- Asignacion del tiempo con su numero en la memoria
        
        process(segundos)
        begin 
        if segundos="0000" then
            num_memo_segundos<="00000";
        elsif segundos="0001"then
            num_memo_segundos<="00001";      
        elsif segundos="0010"then
            num_memo_segundos<="00010";
        elsif segundos="0011"then
            num_memo_segundos<="00011";
        elsif segundos="0100"then
            num_memo_segundos<="00100";
        elsif segundos="0101"then
            num_memo_segundos<="00101";
        elsif segundos="0110"then
            num_memo_segundos<="00110";
        elsif segundos="0111"then
            num_memo_segundos<="00111";
        elsif segundos="1000"then
            num_memo_segundos<="01000";
        elsif segundos="1001"then
            num_memo_segundos<="01001";            
        else 
            num_memo_segundos<="00000";
        end if;
        end process;         
        
        process(decenas)
        begin 
        if decenas="0000" then
            num_memo_decenas<="00000";
        elsif decenas="0001"then
            num_memo_decenas<="00001";      
        elsif decenas="0010"then
            num_memo_decenas<="00010";
        elsif decenas="0011"then
            num_memo_decenas<="00011";
        elsif decenas="0100"then
            num_memo_decenas<="00100";
        elsif decenas="0101"then
            num_memo_decenas<="00101";
        elsif decenas="0110"then
            num_memo_decenas<="00110";
        elsif decenas="0111"then
            num_memo_decenas<="00111";
        elsif decenas="1000"then
            num_memo_decenas<="01000";
        elsif decenas="1001"then
            num_memo_decenas<="01001";            
        else 
            num_memo_decenas<="00000";
        end if;
        end process;         
        
        process(minutos)
        begin 
        if minutos="0000" then
            num_memo_minutos<="00000";
        elsif minutos="0001"then
            num_memo_minutos<="00001";      
        elsif minutos="0010"then
            num_memo_minutos<="00010";
        elsif minutos="0011"then
            num_memo_minutos<="00011";
        elsif minutos="0100"then
            num_memo_minutos<="00100";
        elsif minutos="0101"then
            num_memo_minutos<="00101";
        elsif minutos="0110"then
            num_memo_minutos<="00110";
        elsif minutos="0111"then
            num_memo_minutos<="00111";
        elsif minutos="1000"then
            num_memo_minutos<="01000";
        elsif minutos="1001"then
            num_memo_minutos<="01001";            
        else 
            num_memo_minutos<="00000";
        end if;
        end process;   
         
        
   --Para contar vueltas  
   
   --Para que te cuente una vuelta tiene que pasar por la meta y por la referencia1, situada en el otro extremo del circuito
   
   fila_pos_meta<=to_unsigned(27,6);  
   col_pos_meta<=to_unsigned(14,6);
           
   fila_pos_ref1<=to_unsigned(5,6);
   col_pos_ref1<=to_unsigned(13,6);             
        
        
        process(clk,reset)
        begin
            if reset='1' then
            
            vuelta_bot_s<=to_unsigned(0,3);
            checkpoint_bot <= '0';
        
            elsif rising_edge(clk) then
            
                -- Detecta si pasa por el checkpoint
                
                if (fila_pos_bot >= fila_pos_ref1 and fila_pos_bot <= fila_pos_ref1+5 and col_pos_bot = col_pos_ref1) then                    
                    checkpoint_bot <= '1';                       
                end if;

                -- Detecta si pasa por la meta
                
                if (fila_pos_bot <= fila_pos_meta and fila_pos_bot >= fila_pos_meta-5 and col_pos_bot = col_pos_meta) then
                    if checkpoint_bot = '1' then
                        vuelta_bot_s <= vuelta_bot_s + 1;
                        checkpoint_bot <= '0';
                    end if;
                end if;
            end if;
        end process;        
        
        process(clk,reset)
        begin
            if reset='1' then
            
            vuelta_persona_s<=to_unsigned(0,3);
            checkpoint_persona <= '0';
                    
            elsif rising_edge(clk) then
            
                -- Detecta si pasa por el checkpoint
                
                if (fila_pos_persona >= fila_pos_ref1 and fila_pos_persona <= fila_pos_ref1+5 and col_pos_persona = col_pos_ref1) then                    
                    checkpoint_persona <= '1';                       
                end if;

                -- Detecta si pasa por la meta
                
                if (fila_pos_persona <= fila_pos_meta and fila_pos_persona >= fila_pos_meta-5 and col_pos_persona = col_pos_meta) then
                    if checkpoint_persona = '1' then
                        vuelta_persona_s <= vuelta_persona_s + 1;
                        checkpoint_persona <= '0';
                    end if;
                end if;
            end if;
        end process;    
        
        --Para asignar el numero de vuelta con la direccion en la memoria          
        
        process(vuelta_bot_s)
        begin 
        if vuelta_bot_s="000" then
            vuelta_bot_memo<="00000";
        elsif vuelta_bot_s="001"then
            vuelta_bot_memo<="00001";      
        elsif vuelta_bot_s="010"then
            vuelta_bot_memo<="00010";
        elsif vuelta_bot_s="011"then
            vuelta_bot_memo<="00011";
        elsif vuelta_bot_s="100"then
            vuelta_bot_memo<="00100";
        elsif vuelta_bot_s="101"then
            vuelta_bot_memo<="00101";
        elsif vuelta_bot_s="110"then
            vuelta_bot_memo<="00110";           
        else 
            vuelta_bot_memo<="00111";
        end if;
        end process;      
          
        process(vuelta_persona_s)
        begin 
        if vuelta_persona_s="000" then
            vuelta_persona_memo<="00000";
        elsif vuelta_persona_s="001"then
            vuelta_persona_memo<="00001";      
        elsif vuelta_persona_s="010"then
            vuelta_persona_memo<="00010";
        elsif vuelta_persona_s="011"then
            vuelta_persona_memo<="00011";
        elsif vuelta_persona_s="100"then
            vuelta_persona_memo<="00100";
        elsif vuelta_persona_s="101"then
            vuelta_persona_memo<="00101";
        elsif vuelta_persona_s="110"then
            vuelta_persona_memo<="00110";           
        else 
            vuelta_persona_memo<="00111";
        end if;
        end process;        
        
        
end Behavioral;