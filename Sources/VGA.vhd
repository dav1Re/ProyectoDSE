
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.VGA_PKG.ALL;

entity VGA is
    Port ( 
        -- In ports
        clk: in std_logic;
        rst:in std_logic; 
        enable:in std_logic; -- Parametro que habilita en cronometro y el mov de los jugadores
            -- Movimiento de personaje controlado por botones
        btn_up: in std_logic;
        btn_down: in std_logic;
        btn_izq: in std_logic;
        btn_dcha: in std_logic; 
        -- Out ports               
        hsinc:out std_logic;
        vsinc:out std_logic;        
        rojo:out std_logic_vector(3 downto 0);
        verde:out std_logic_vector(3 downto 0);
        azul:out std_logic_vector(3 downto 0)               
    );
end VGA;

architecture Behavioral of VGA is

    component sincroVGA is
        Port ( 
            -- In ports
            clk: in std_logic;
            rst:in std_logic;     
            -- Out ports   
            visible:out std_logic;
            hsinc:out std_logic;
            vsinc:out std_logic;        
            col:out std_logic_vector(9 downto 0);
            fila:out std_logic_vector(9 downto 0)        
        ); 
    end component; 
    
    component pinta_barras is 
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
    end component; 
    
            -- Memorias de figuras
    component ROM1b_1f_red_num32_play_sprite16x16 is 
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(9-1 downto 0);
            dout : out std_logic_vector(16-1 downto 0) 
        );    
    end component;
    
    component ROM1b_1f_green_num32_play_sprite16x16 is 
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(9-1 downto 0);
            dout : out std_logic_vector(16-1 downto 0) 
        );    
    end component;  
    
    component ROM1b_1f_blue_num32_play_sprite16x16 is 
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(9-1 downto 0);
            dout : out std_logic_vector(16-1 downto 0) 
        );    
    end component;
    
        -- Componente del movimiento del jugador principal
    component FSM_persona is 
        Port ( 
            clk: in std_logic;
            rst: in std_logic;            
            enable:in std_logic;
                --Movimiento del jugador en funcion de los parametros de entrada
            btn_up: in std_logic;
            btn_down: in std_logic;
            btn_izq: in std_logic;
            btn_dcha: in std_logic;
                --Posiciones de salida (Cuadriculas)
            fil_pos_persona: out unsigned(5 downto 0);
            col_pos_persona: out unsigned(5 downto 0)    
        );
    end component; 
    
    
    component FSM_bot is 
        Port ( 
            --In ports
            clk: in std_logic;
            rst: in std_logic;
            enable:in std_logic;
                --Posiciones de salida (Cuadriculas)    
            fil_pos_bot: out unsigned(5 downto 0);
            col_pos_bot: out unsigned(5 downto 0)
        );
    end component; 
    
        -- Memorias de pista
    
    component ROM1b_1f_red_racetrack_1 is
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(5-1 downto 0);
            dout : out std_logic_vector(32-1 downto 0) 
        ); 
    end component;   
       
    component ROM1b_1f_green_racetrack_1 is
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(5-1 downto 0);
            dout : out std_logic_vector(32-1 downto 0) 
        ); 
    end component;  
        
    component ROM1b_1f_blue_racetrack_1 is
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(5-1 downto 0);
            dout : out std_logic_vector(32-1 downto 0) 
        ); 
    end component;  
    
    -- Componente que indica el cronometro y la vuelta de los jugadores
        
    component ind_vuelta
    port (
        --In ports
        clk : in STD_LOGIC;  -- Reloj
        reset : in STD_LOGIC; -- Reset 
        enable : in STD_LOGIC;  -- Enable (Para parar y continuar la cuenta)
            --Posicion persona (cuadricula)   
        fila_pos_persona : in unsigned(5 downto 0); 
        col_pos_persona  : in unsigned(5 downto 0);
            --Posicion bot (cuadricula)   
        fila_pos_bot     : in unsigned(5 downto 0);  
        col_pos_bot      : in unsigned(5 downto 0); 
        --Out ports 
            -- Valor numerico de salida, indica el numero seleccionado en la memoria
        num_memo_segundos: out STD_LOGIC_VECTOR(4 DOWNTO 0);  
        num_memo_decenas: out std_logic_vector(4 downto 0);        
        num_memo_minutos: out std_logic_vector(4 downto 0);
            --Indica la vuelta de los jugadores
        vuelta_persona_memo  : out unsigned(4 downto 0);          
        vuelta_bot_memo      : out unsigned(4 downto 0)     
    );      
    end component;
    
    --señales intermedias para las conexiones
                   
    signal  visible_s : std_logic;
    signal  col_s, fila_s: std_logic_vector(9 downto 0);
    signal  col_unsigned, fila_unsigned: unsigned(9 downto 0);
    
    signal dato_memo_red_s: std_logic_vector(16-1 downto 0);   
    signal dato_memo_green_s: std_logic_vector(16-1 downto 0);   
    signal dato_memo_blue_s: std_logic_vector(16-1 downto 0);     
    
    
    signal dato_pista_red_s: std_logic_vector(32-1 downto 0);   
    signal dato_pista_green_s: std_logic_vector(32-1 downto 0);   
    signal dato_pista_blue_s: std_logic_vector(32-1 downto 0);   
    

    signal addr_s: std_logic_vector(9-1 downto 0); --indica el pixel la direccion de la memoria
    signal addr_pista_s: std_logic_vector(5-1 downto 0); --indica el pixel la direccion de la pista
    
    
    signal fil_pos_persona_s, col_pos_persona_s,fil_pos_bot_s,col_pos_bot_s: unsigned(5 downto 0); 
    
    signal num_memo_segundos_s,num_memo_decenas_s, num_memo_minutos_s: std_logic_vector(4 downto 0);
    
    signal vuelta_persona_memo_s, vuelta_bot_memo_s: unsigned(4 downto 0);
    
        

begin

        --Conexiones entre componentes y señales

    SINCRO_VGA: sincroVGA
        port map(
        clk=>clk,
        rst=>rst,
        visible=>visible_s,
        col=>col_s,
        fila=>fila_s,
        hsinc=>hsinc,
        vsinc=>vsinc        
        );
        
        col_unsigned<=UNSIGNED(col_s);
        fila_unsigned<=UNSIGNED(fila_s);                   
        
    PINTA_VGA: pinta_barras
        port map(
            col=>col_unsigned,
            fila=>fila_unsigned,     
            enable=>enable,      
            num_memo_segundos=>num_memo_segundos_s,
            num_memo_decenas=>num_memo_decenas_s,
            num_memo_minutos=>num_memo_minutos_s, 
            vuelta_persona_memo=>vuelta_persona_memo_s,          
            vuelta_bot_memo=>vuelta_bot_memo_s, 
            visible=>visible_s,
            rojo=>rojo,
            verde=>verde,
            azul=>azul,
            fila_pos_persona=>fil_pos_persona_s,
            col_pos_persona=>col_pos_persona_s,
            fila_pos_bot=>fil_pos_bot_s,
            col_pos_bot=>col_pos_bot_s,    
            btn_up=>btn_up,
            btn_down=>btn_down,
            btn_izq=>btn_izq,
            btn_dcha=>btn_dcha,                                 
            dato_memo_red=>dato_memo_red_s,
            dato_memo_green=>dato_memo_green_s,
            dato_memo_blue=>dato_memo_blue_s,
            dato_pista_red=> dato_pista_red_s,  
            dato_pista_green=> dato_pista_green_s,  
            dato_pista_blue=> dato_pista_blue_s,   
            addr_pista=>addr_pista_s,            
            addr_memo=>addr_s                                 
        );  
        
     red_mem: ROM1b_1f_red_num32_play_sprite16x16  
        port map(
        clk=>clk,
        addr=>addr_s,
        dout=>dato_memo_red_s
        );        
        
     green_mem: ROM1b_1f_green_num32_play_sprite16x16  
        port map(
        clk=>clk,
        addr=>addr_s,
        dout=>dato_memo_green_s
        );       
         
     blue_mem: ROM1b_1f_blue_num32_play_sprite16x16  
        port map(
        clk=>clk,
        addr=>addr_s,
        dout=>dato_memo_blue_s
        );    
        
     mov_persona: FSM_persona
        port map(
            clk=>clk,
            rst=>rst,
            enable=>enable,
            btn_up=>btn_up,
            btn_down=>btn_down,
            btn_izq=>btn_izq,
            btn_dcha=>btn_dcha,
            fil_pos_persona=>fil_pos_persona_s,
            col_pos_persona=>col_pos_persona_s            
        ); 
     mov_bot: FSM_bot
        port map(
            clk=>clk,
            rst=>rst,
            enable=>enable,
            fil_pos_bot=>fil_pos_bot_s,
            col_pos_bot=>col_pos_bot_s
        );
        
     red_pista: ROM1b_1f_red_racetrack_1  
        port map(
        clk=>clk,
        addr=>addr_pista_s,
        dout=>dato_pista_red_s
        );     
     green_pista: ROM1b_1f_green_racetrack_1  
        port map(
        clk=>clk,
        addr=>addr_pista_s,
        dout=>dato_pista_green_s
        );
        
     blue_pista: ROM1b_1f_blue_racetrack_1  
        port map(
        clk=>clk,
        addr=>addr_pista_s,
        dout=>dato_pista_blue_s
        );      
        
    ind_vueltas: ind_vuelta
        port map(
        clk=>clk,
        reset=>rst,
        enable=>enable,
        fila_pos_persona=>fil_pos_persona_s,
        col_pos_persona=>col_pos_persona_s,
        fila_pos_bot=>fil_pos_bot_s,
        col_pos_bot=>col_pos_bot_s, 
        num_memo_segundos=>num_memo_segundos_s,
        num_memo_decenas=>num_memo_decenas_s,
        num_memo_minutos=>num_memo_minutos_s,
        vuelta_persona_memo=>vuelta_persona_memo_s,          
        vuelta_bot_memo=>vuelta_bot_memo_s       
        );        

end Behavioral;
