library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.RACETRACK_PKG.ALL;


entity FSM_bot is
    Port ( 
    clk: in std_logic;
    rst: in std_logic; 
    enable: in std_logic;   
    fil_pos_bot: out unsigned(5 downto 0);
    col_pos_bot: out unsigned(5 downto 0)
    );
end FSM_bot;

architecture Behavioral of FSM_bot is

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

   type estado is (dcha, abajo, izq, arriba);  -- Declaracion de estados
   signal e_act, e_sig: estado;
   
   
   signal svel,svel_rg, pista_abajo, pista_dcha, pista_arriba, pista_izq: std_logic;
   signal col_pos_bot_s, fil_pos_bot_s: unsigned(5 downto 0);   


begin

    

    velocidad_mov: contador
        generic map (
            N_BITS => 24,  
            END_COUNT => 10**7   -- 10**7 -- 100 ms, para solo mueva una posicion cada decima
        )
        port map (
            clk => clk,
            reset => rst,
            enable => '1',
            ud_count => '1',
            fcount => svel,
            count =>OPEN           
        );            
        
    detec_pista: process(clk, rst)
    begin
        if rst = '1' then
            pista_abajo <= '0';
            pista_dcha <= '1';
            pista_arriba <= '1';
            pista_izq <= '1';
        elsif clk'event and clk='1' then
        if enable='1' then
            pista_abajo <= pista(to_integer(fil_pos_bot_s) + 1)(to_integer(col_pos_bot_s));
            pista_dcha  <= pista(to_integer(fil_pos_bot_s))(to_integer(col_pos_bot_s) + 1);
            pista_arriba <= pista(to_integer(fil_pos_bot_s) - 1)(to_integer(col_pos_bot_s));
            pista_izq  <= pista(to_integer(fil_pos_bot_s))(to_integer(col_pos_bot_s) - 1);
        end if;
        end if;
    end process;                                           




    P_fsm_seq: process (rst, clk)
    begin
        if rst ='1' then
            e_act <= dcha;
        elsif clk'event and clk='1' then
        if enable='1' then
            if svel_rg = '1' then            
                e_act <= e_sig;
            end if;
            end if;
        end if;
    end process;

    P_fsm_comb: process(e_act, pista_dcha, pista_arriba, pista_izq, pista_abajo) 
    begin
        e_sig <= e_act;        
        case e_act is       --El orden de prioridad es importante (Hay que mirar primero a la derecha, luego de frente y por ultimo a la izquierda desde la perspectiva del coche)        
            when dcha =>
                if pista_abajo= '1' then
                    e_sig <= abajo;                   
                elsif pista_dcha = '1' then
                    e_sig <= dcha;
                elsif pista_arriba = '1' then
                    e_sig <= arriba;
                elsif pista_izq = '1' then  --te da igual
                    e_sig <= izq;
                end if;                
            when arriba =>
                if pista_dcha = '1' then
                    e_sig <= dcha;                   
                elsif pista_arriba = '1' then
                    e_sig <= arriba;
                elsif pista_izq = '1' then
                    e_sig <= izq;
                elsif pista_abajo = '1' then  -- te da igual
                    e_sig <= abajo;
                end if;             
            when izq =>
                if pista_arriba = '1' then
                    e_sig <= arriba;                   
                elsif pista_izq = '1' then
                    e_sig <= izq;
                elsif pista_abajo = '1' then
                    e_sig <= abajo;
                elsif pista_dcha = '1' then  -- te da igual
                    e_sig <= dcha;
                end if;        
            when abajo =>
                if pista_izq= '1' then 
                    e_sig <= izq;                   
                elsif pista_abajo = '1' then
                    e_sig <= abajo;
                elsif pista_dcha = '1' then
                    e_sig <= dcha;
                elsif pista_arriba = '1' then  -- te da igual
                    e_sig <= arriba;
                end if;                      
        end case;     
    end process;      
        
    p_pos_aut: process(rst, clk)
    begin
        if rst = '1' then     
            svel_rg<='0';      
            col_pos_bot_s <= to_unsigned(13,6);
            fil_pos_bot_s <= to_unsigned(27,6);
        elsif clk'event and clk = '1' then    
        if enable='1' then    
            if svel = '1' then  
            svel_rg<='1';                         
                case e_sig is
                    when dcha =>
                        col_pos_bot_s <= col_pos_bot_s + 1;
                    when arriba =>
                        fil_pos_bot_s <= fil_pos_bot_s - 1;
                    when izq =>
                        col_pos_bot_s <= col_pos_bot_s - 1;
                    when abajo =>
                        fil_pos_bot_s <= fil_pos_bot_s + 1;
                end case;                   
            else 
            svel_rg<='0';
            end if;        
        end if; 
        end if; 
    end process;        
        
            fil_pos_bot<=fil_pos_bot_s;                    
            col_pos_bot<=col_pos_bot_s;     
                                        

end Behavioral;
