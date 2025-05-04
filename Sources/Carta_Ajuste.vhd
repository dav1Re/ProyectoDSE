
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.VGA_PKG.ALL; 

entity pinta_barras is
  
Port (
    -- In ports
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);  
    enable       : in std_logic;   
        --Direccion de la memoria para representar los numeros del cronometro
    num_memo_segundos   : in std_logic_vector(4 downto 0);
    num_memo_decenas    : in std_logic_vector(4 downto 0);
    num_memo_minutos    : in std_logic_vector(4 downto 0); 
        --Direccion de la memoria para representar las vueltas de los jugadores
    vuelta_persona_memo : in unsigned(4 downto 0);          
    vuelta_bot_memo     : in unsigned(4 downto 0);                    
        --Para saber en que posicion estas moviendo el personaje
    btn_up      : in std_logic;
    btn_down    : in std_logic;
    btn_izq     : in std_logic;
    btn_dcha    : in std_logic;                  
        --Para pintar las figuras
    dato_memo_red    : in std_logic_vector(16-1 downto 0); 
    dato_memo_green  : in std_logic_vector(16-1 downto 0); 
    dato_memo_blue   : in std_logic_vector(16-1 downto 0);     
        --Para la pista
    dato_pista_red    : in std_logic_vector(32-1 downto 0); 
    dato_pista_green  : in std_logic_vector(32-1 downto 0); 
    dato_pista_blue   : in std_logic_vector(32-1 downto 0);     
        --Para la posicion de las figuras en pantalla (relacionado con la cuadricula de filas y columnas)
    fila_pos_persona : in unsigned(5 downto 0); 
    col_pos_persona  : in unsigned(5 downto 0);
    fila_pos_bot     : in unsigned(5 downto 0);  
    col_pos_bot      : in unsigned(5 downto 0);
    -- Out ports
    rojo         : out std_logic_vector(c_nb_red-1 downto 0);
    verde        : out std_logic_vector(c_nb_green-1 downto 0);
    azul         : out std_logic_vector(c_nb_blue-1 downto 0);
    addr_memo    : out std_logic_vector(9-1 downto 0); -- direccion memoria figuras
    addr_pista    : out std_logic_vector(5-1 downto 0) -- direccion memoria pista
  );
end pinta_barras;

architecture behavioral of pinta_barras is

    -- señales intermedias
    
        -- Para dividir en figuras y cuadriculas (Figuras de 16x16)
    signal fila_int: unsigned(3 downto 0);
    signal col_int: unsigned(3 downto 0);   
    signal fila_cuad: unsigned(5 downto 0);
    signal col_cuad: unsigned(5 downto 0);  
    signal fil_cuad_pista: unsigned(4 downto 0);  
     
    signal memo_cuad: unsigned(4 downto 0);  -- Selecciona la figura con los bits mas significativos  
    
    
    signal dato_memo_red_s: std_logic_vector(4-1 downto 0);    
    signal dato_memo_green_s: std_logic_vector(4-1 downto 0);    
    signal dato_memo_blue_s: std_logic_vector(4-1 downto 0);    
    
    signal dato_pista_red_s: std_logic_vector(4-1 downto 0);    
    signal dato_pista_green_s: std_logic_vector(4-1 downto 0);    
    signal dato_pista_blue_s: std_logic_vector(4-1 downto 0); 
    
       
    signal pixel_red: std_logic;    
    signal pixel_green: std_logic;    
    signal pixel_blue: std_logic;     
    
    signal pixel_red_pista: std_logic;    
    signal pixel_green_pista: std_logic;    
    signal pixel_blue_pista: std_logic; 
    
         
    signal fila_pos_persona_s: unsigned(5 downto 0);
    signal col_pos_persona_s: unsigned(5 downto 0);
    
    signal fila_pos_bot_s: unsigned(5 downto 0);
    signal col_pos_bot_s: unsigned(5 downto 0);   
       
    signal col_num_memo, fila_num_memo, col_pw_memo, fila_pw_memo : unsigned(5 downto 0);      
     
    
    signal fila_int_c,col_int_c: unsigned(3 downto 0);    

begin
    
    fila_cuad<=unsigned(fila(9 downto 4));
    col_cuad<=unsigned(col(9 downto 4)); 
    
    fil_cuad_pista<= unsigned(fila(8 downto 4));      
    
   
    addr_memo(3 downto 0)<= std_logic_vector(fila_int); 
    addr_memo(8 downto 4)<=std_logic_vector(memo_cuad);      
    
    col_num_memo(5 downto 0)<="000001";
    fila_num_memo(5 downto 0)<="000001";
        
    col_pw_memo(5 downto 0)<="001111";
    fila_pw_memo(5 downto 0)<="001101";
    
       
      
    process(dato_memo_red, dato_memo_green, dato_memo_blue, col_int) -- Este proceso lo que hace es indicar el color del pixel en la posicion de la columna seleccionada
    begin 
    pixel_red<= dato_memo_red(to_integer(not(col_int))); 
    pixel_green<= dato_memo_green(to_integer(not(col_int))); 
    pixel_blue<= dato_memo_blue(to_integer(not(col_int))); 
    end process;    

    
    addr_pista(4 downto 0)<= std_logic_vector(fil_cuad_pista);
    
    
    process(dato_pista_red, dato_pista_green, dato_pista_blue, col_cuad) -- Este proceso lo que hace es indicar el color del pixel en la posicion de la columna seleccionada
    begin 
    pixel_red_pista<= dato_pista_red(to_integer(col_cuad)); 
    pixel_green_pista<= dato_pista_green(to_integer(col_cuad)); 
    pixel_blue_pista<= dato_pista_blue(to_integer(col_cuad)); 
    end process;            
    
    -- Se asigna la posicion de la persona y el bot en funcion de la FSM
    
    col_pos_persona_s<=col_pos_persona; 
    fila_pos_persona_s<=fila_pos_persona; 
    
    col_pos_bot_s<=col_pos_bot;  
    fila_pos_bot_s<=fila_pos_bot; 
       
       
    
    -- Las salidas rojo,verde,azul necesitan ser un bus de 4 (No tocar)
               
        dato_memo_red_s<= (others=>pixel_red);        
        
        dato_memo_blue_s<= (others=>pixel_blue);        
        
        dato_memo_green_s<= (others=>pixel_green);        
        
        
        dato_pista_red_s<= (others=>pixel_red_pista);        
        
        dato_pista_blue_s<= (others=>pixel_blue_pista);        
        
        dato_pista_green_s<= (others=>pixel_green_pista);        
    
     
    P_pinta: Process (visible, dato_memo_red,dato_memo_green,dato_memo_blue, col, fila)
    begin
        rojo <= (others=>'0');
        verde <= (others=>'0');
        azul <= (others=>'0');
        
        if visible = '1' then        
            if col_cuad<32 then    -- a partir de la col=32 se pinta todo negro                                                            
                if col_cuad=col_pos_persona and fila_cuad=fila_pos_persona then  --Dibuja la posicion de la persona         
                
                        if btn_dcha='1' and btn_up='1' then
                            col_int_c<=unsigned(col(3 downto 0));    
                            fila_int_c<=unsigned(fila(3 downto 0));   
                            memo_cuad<="11111"; --para seleccionar el coche diagonal                      
                        elsif btn_izq='1' and btn_up='1' then
                            col_int_c<=unsigned(not(col(3 downto 0)));    
                            fila_int_c<=unsigned(fila(3 downto 0));                                                     
                            memo_cuad<="11111"; --para seleccionar el coche diagonal  
                        elsif btn_izq='1' and btn_down='1' then                
                            col_int_c<=unsigned(fila(3 downto 0));             
                            fila_int_c<=unsigned(col(3 downto 0));             
                            memo_cuad<="11111"; --para seleccionar el coche diagonal          
                                            
                        elsif btn_dcha='1' and btn_down='1' then
                            col_int_c<=unsigned(fila(3 downto 0));         
                            fila_int_c<=unsigned(not(col(3 downto 0)));   
                            memo_cuad<="11111"; --para seleccionar el coche diagonal                                                                                                                                         
                        elsif btn_up='1' then 
                            col_int_c<=unsigned(col(3 downto 0));    
                            fila_int_c<=unsigned(fila(3 downto 0));
                            memo_cuad<="11110"; --para seleccionar el coche                            
                        elsif btn_down='1' then
                            col_int_c<=unsigned(col(3 downto 0));    
                            fila_int_c<=unsigned(not(fila(3 downto 0))); 
                            memo_cuad<="11110"; --para seleccionar el coche                          
                        elsif btn_izq='1' then
                            col_int_c<=unsigned(fila(3 downto 0));    
                            fila_int_c<=unsigned(col(3 downto 0));
                            memo_cuad<="11110"; --para seleccionar el coche    
                        elsif btn_dcha='1' then
                            col_int_c<=unsigned(fila(3 downto 0));    
                            fila_int_c<=unsigned(not(col(3 downto 0)));   
                            memo_cuad<="11110"; --para seleccionar el coche                                                                         
                        else
                            col_int_c<=unsigned(col(3 downto 0));                                  
                            fila_int_c<=unsigned(fila(3 downto 0));                                
                            memo_cuad<="11110"; --para seleccionar el coche                          
                        end if;  
                                                                                                                       
                    fila_int<=fila_int_c;
                    col_int<=col_int_c;  
                                   
                    rojo <=  dato_memo_red_s;
                    verde <= dato_memo_green_s;
                    azul <= dato_memo_blue_s;
                    
                elsif col_cuad=col_pos_bot and fila_cuad=fila_pos_bot then      --Dibuja la posicion del bot
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0));
                        
                        
                    memo_cuad<="11010"; -- Para seleccionar el fantasma     
                    rojo <=  dato_memo_red_s;
                    verde <= dato_memo_green_s;
                    azul <= dato_memo_blue_s;
                    
                elsif col_cuad=col_num_memo and fila_cuad=fila_num_memo then  -- Para el cronometro
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0));              
                    
                    memo_cuad<=unsigned(num_memo_minutos);                    
                    
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                                    
              
                elsif col_cuad=col_num_memo + 1 and fila_cuad=fila_num_memo then      
                        
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0));  
                    
                    memo_cuad<="10101";
                    
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                 
                    
                elsif col_cuad=col_num_memo + 2 and fila_cuad = fila_num_memo then  
              
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0));                
                    
                    memo_cuad<=unsigned(num_memo_decenas);
                    
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                 
                    
                elsif col_cuad=col_num_memo + 3 and fila_cuad=fila_num_memo then
              
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0));                  
                   
                    memo_cuad<=unsigned(num_memo_segundos);
                    
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');  
                    
                elsif   col_cuad=col_pw_memo and fila_cuad=fila_pw_memo then --Para el play, win
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                if enable='0' then                         
                    memo_cuad<="01010"; -- P 
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                                                             
                else   
                    if   (vuelta_persona_memo>=to_unsigned(3,5) and vuelta_bot_memo<vuelta_persona_memo)  then              --Para win
                        memo_cuad<="10001"; -- W
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0');                    
                    else
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;
                    end if;
                end if;                            
 
                                  
                elsif   col_cuad=col_pw_memo + 1 and fila_cuad=fila_pw_memo then --Para el play, win
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                if enable='0' then                         
                    memo_cuad<="01011"; -- L   
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                                                                              
                else                 
                    if   (vuelta_persona_memo>=to_unsigned(3,5) and vuelta_bot_memo<vuelta_persona_memo)    then          --Para win
                        memo_cuad<="10010"; -- I
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0');                    
                    else
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;
                    end if;
                end if;     
                         
  
                                  
                elsif   col_cuad=col_pw_memo+2 and fila_cuad=fila_pw_memo then --Para el play, win
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                if enable='0' then                         
                    memo_cuad<="01100"; -- A
                    rojo <= (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                                                                                 
                else                 
                    if   (vuelta_persona_memo>=to_unsigned(3,5) and vuelta_bot_memo<vuelta_persona_memo) then              --Para win
                        memo_cuad<="10011"; -- N
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0');                    
                    else
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;
                    end if;
                end if;        
                                
                elsif   col_cuad=col_pw_memo+3 and fila_cuad=fila_pw_memo then --Para el play, win
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                if enable='0' then                         
                    memo_cuad<="01101"; -- Y
                    rojo <=  (others=>'0');
                    verde <= dato_memo_green_s;
                    azul <= (others=>'0');                                                                                  
                else              
                    if   (vuelta_persona_memo>=to_unsigned(3,5) and vuelta_bot_memo<vuelta_persona_memo)  then              --Para win
                        memo_cuad<="10100"; -- !
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0');                     
                    else
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;
                    end if;
                end if;
                 
                --Vueltas
                
                elsif   col_cuad="011011" and fila_cuad="011011" then --Para vuelta persona
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                    if enable='0' then                         
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;                                                                                
                    else                 
                        memo_cuad<=vuelta_persona_memo;
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0');
                    end if;
                                               
                elsif   col_cuad="011110" and fila_cuad="011011" then --Para vuelta bot
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                    if enable='0' then                         
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;                                                                                
                    else                 
                        memo_cuad<=vuelta_bot_memo;
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0'); 
                    end if;  
                     
                elsif   col_cuad="011011" and fila_cuad="011001" then --Para P1
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                    if enable='0' then                         
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;                                                                                
                    else                 
                        memo_cuad<="00001";  --1
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0'); 
                    end if;    
                               
                elsif   col_cuad="011010" and fila_cuad="011001" then --Para P1
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                    if enable='0' then                         
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;                                                                                
                    else                 
                        memo_cuad<="01010";  -- P
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0'); 
                    end if;  
                                                               
                elsif   col_cuad="011110" and fila_cuad="011001" then --Para P2
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                    if enable='0' then                         
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;                                                                                
                    else                 
                        memo_cuad<="00010";  -- 2
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0'); 
                    end if;      
                    
                elsif   col_cuad="011101" and fila_cuad="011001" then --Para P2
                
                        fila_int<=unsigned(fila(3 downto 0));
                        col_int<=unsigned(col(3 downto 0)); 
                            
                    if enable='0' then                         
                        memo_cuad<=(others=>'0');
                        rojo <=  dato_pista_red_s;
                        verde <= dato_pista_green_s;
                        azul <= dato_pista_blue_s;                                                                                
                    else                 
                        memo_cuad<="01010";  -- P
                        rojo <=  (others=>'0');
                        verde <= dato_memo_green_s;
                        azul <= (others=>'0');
                    end if;
                                                                                               
                else
                
                    col_int<=unsigned(col(3 downto 0));    
                    fila_int<=unsigned(fila(3 downto 0));
                    
                    
                    memo_cuad<=(others=>'0');
                    rojo <=  dato_pista_red_s;
                    verde <= dato_pista_green_s;
                    azul <= dato_pista_blue_s;
                end if;
            else
                rojo <= (others=>'0');
                verde <= (others=>'0');
                azul <= (others=>'0');
            end if;
        end if;
    end process; 
    
end Behavioral;