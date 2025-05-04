
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.RACETRACK_PKG.ALL;

entity FSM_persona is
    Port ( 
    clk: in std_logic;
    rst: in std_logic;
    enable:in std_logic;
    btn_up: in std_logic;
    btn_down: in std_logic;
    btn_izq: in std_logic;
    btn_dcha: in std_logic;
    fil_pos_persona: out unsigned(5 downto 0);
    col_pos_persona: out unsigned(5 downto 0)
    );
end FSM_persona;

architecture Behavioral of FSM_persona is

    component contador is 
    generic (N_BITS : integer := 10;   -- Numero de bits necesarios para que el contador alcance el valor deseado 
             END_COUNT : integer := 1024  -- Valor hasta el que debe contar el contador
    );
    port(
        clk     : in  STD_LOGIC;  
        reset   : in  STD_LOGIC;
        enable  : in  STD_LOGIC;
        ud_count: in  STD_LOGIC;  -- Indica si el contador es ascendente('1') o descendente ('0')
        fcount  : out STD_LOGIC;  -- Otorga '1' al final de cuenta
        count   : out STD_LOGIC_VECTOR(N_BITS-1 downto 0) -- Indica cual es el valor de cuenta
    );
    end component;    
    
    signal fil_pos_persona_s,col_pos_persona_s: unsigned(5 downto 0); -- Para guardar el cambio de posicion al pulsar btn    
    signal pulso_btn, pulso_btn_100ms, pulso_btn_500ms, pulso_btn_200ms, pulso_btn_diag: std_logic; -- señal para indicar el tiempo que tarda en cambiar de posicion
    
begin

    pulso_boton_100ms: contador
        generic map (
            N_BITS => 24,
            END_COUNT => 10**7 -- 100 ms, para solo mueva una posicion cada decima
        )
        port map (
            clk => clk,
            reset => rst,
            enable => '1',
            ud_count => '1',
            fcount => pulso_btn_100ms,
            count =>OPEN           
        );      
        
        pulso_boton_200ms: contador
        generic map (
            N_BITS => 25,
            END_COUNT => 2*10**7  -- 200 ms
        )
        port map (
            clk => clk,
            reset => rst,
            enable => '1',
            ud_count => '1',
            fcount => pulso_btn_200ms,
            count =>OPEN           
        );  
          
        pulso_boton_500ms: contador
        generic map (
            N_BITS => 26,
            END_COUNT => 5*10**7  --500 ms
        )
        port map (
            clk => clk,
            reset => rst,
            enable => '1',
            ud_count => '1',
            fcount => pulso_btn_500ms,
            count =>OPEN           
        );   
        
    Vel_persona: Process (clk, rst, col_pos_persona_s, fil_pos_persona_s)   
    begin  
        if rst='1' then
           pulso_btn<=pulso_btn_100ms;
        elsif rising_edge(clk) then   
        if enable='1' then       
            if pista(to_integer(fil_pos_persona_s))(to_integer(col_pos_persona_s))='1' then -- Si esta en pista se mueve cada, si no a 500 ms
                pulso_btn<=pulso_btn_100ms;
                pulso_btn_diag<=pulso_btn_200ms; -- En diagonal se mueve mas despacio
            else 
                pulso_btn<= pulso_btn_500ms;  
                pulso_btn_diag<= pulso_btn_500ms;            
            end if;
        end if;
     end if;
    end process;    

    -- Proceso mediante el cual se le asignan unas salida a cada estado y se transiciona de un estado a otro en funcion de como varie la lista de sensibilidad  
    
    P_SEC: Process (clk, rst, pulso_btn, pulso_btn_diag, btn_up, btn_down, btn_izq, btn_dcha)   
    begin 
    if rst='1' then
            col_pos_persona_s <= to_unsigned(13,6);
            fil_pos_persona_s <= to_unsigned(25,6);   
    elsif rising_edge(clk) then    
    if enable='1' then     
    
        if pulso_btn_diag='1' then
            if btn_up='1' and btn_dcha='1' then --arriba
                fil_pos_persona_s<=fil_pos_persona_s-1; 
                col_pos_persona_s<=col_pos_persona_s+1;                
            elsif btn_up='1' and btn_izq='1' then --abajo             
                fil_pos_persona_s<=fil_pos_persona_s-1; 
                col_pos_persona_s<=col_pos_persona_s-1;              
            elsif btn_down='1' and btn_izq='1' then  --izquierda                
                fil_pos_persona_s<=fil_pos_persona_s+1; 
                col_pos_persona_s<=col_pos_persona_s-1;              
            elsif btn_down='1' and btn_dcha='1' then --derecha                 
                fil_pos_persona_s<=fil_pos_persona_s+1;
                col_pos_persona_s<=col_pos_persona_s+1;        
            end if;
        end if;    
            
        if pulso_btn='1' and not((btn_up='1' and btn_dcha='1') or 
                (btn_up='1' and btn_izq='1') or 
                (btn_down='1' and btn_izq='1') or 
                (btn_down='1' and btn_dcha='1'))then  --pulso de btn     
             
            if btn_up='1' then --arriba
                fil_pos_persona_s<=fil_pos_persona_s-1; 
                col_pos_persona_s<=col_pos_persona_s;            
            elsif btn_down='1' then --abajo             
                fil_pos_persona_s<=fil_pos_persona_s+1; 
                col_pos_persona_s<=col_pos_persona_s;              
            elsif btn_izq='1' then  --izquierda                
                fil_pos_persona_s<=fil_pos_persona_s; 
                col_pos_persona_s<=col_pos_persona_s-1;              
            elsif btn_dcha='1' then --derecha                 
                fil_pos_persona_s<=fil_pos_persona_s; 
                col_pos_persona_s<=col_pos_persona_s+1;
            end if;                                           
        end if;
    end if;    
    end if;         
   end process;     
    
    fil_pos_persona<=fil_pos_persona_s; 
    col_pos_persona<=col_pos_persona_s;
    
end Behavioral;
