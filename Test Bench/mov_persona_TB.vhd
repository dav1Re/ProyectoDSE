library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.RACETRACK_PKG.ALL;

entity mov_persona_TB is
--  Port ( );
end mov_persona_TB;

architecture Behavioral of mov_persona_TB is


    component FSM_persona is         
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
    end component;
    
    signal clk, rst, enable, btn_up, btn_down, btn_dcha, btn_izq: std_logic;
    signal fil_pos_persona,col_pos_persona: unsigned(5 downto 0);
    

begin
    
    
    tb_persona:FSM_persona
    port map(
        clk=>clk,
        rst=>rst,
        enable=>enable,
        btn_up=>btn_up,
        btn_down=>btn_down,
        btn_dcha=>btn_dcha,
        btn_izq=>btn_izq,
        fil_pos_persona=>fil_pos_persona,
        col_pos_persona=>col_pos_persona  
    );
    
uut: process
    begin
    clk<= '1';
    wait for 5ns;
    clk<= '0';
    wait for 5ns; 
    end process;
    
     prueba: process       
   begin     
        rst<='1';     
        enable<='1';  
        btn_up<='0';        
        btn_down<='0';        
        btn_izq<='0';        
        btn_dcha<='0';        
        wait for 50ns;                       
        rst<='0'; 
        enable<='1'; 
        btn_up<='1';        
        btn_down<='0';        
        btn_izq<='0';        
        btn_dcha<='0';        
        wait for 50 ns;  
        rst<='0'; 
        enable<='1'; 
        btn_up<='1';        
        btn_down<='0';        
        btn_izq<='0';        
        btn_dcha<='0'; 
        wait for 50 ns;  
        rst<='0'; 
        enable<='1'; 
        btn_up<='1';        
        btn_down<='1';        
        btn_izq<='0';        
        btn_dcha<='0';
        wait for 50 ns;  
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='1';        
        btn_izq<='0';        
        btn_dcha<='1';                            
        wait for 50 ns;  
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='1';        
        btn_izq<='1';        
        btn_dcha<='0';
        wait for 50 ns;  
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='0';        
        btn_izq<='1';        
        btn_dcha<='0'; 
        wait for 50 ns;         
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='0';        
        btn_izq<='1';        
        btn_dcha<='0'; 
        wait for 50 ns;
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='0';        
        btn_izq<='0';        
        btn_dcha<='0'; 
        wait for 50 ns;
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='1';        
        btn_izq<='0';        
        btn_dcha<='0'; 
        wait for 50 ns;
        rst<='0'; 
        enable<='1'; 
        btn_up<='1';        
        btn_down<='0';        
        btn_izq<='0';        
        btn_dcha<='0'; 
        wait for 50 ns;
        rst<='0'; 
        enable<='1'; 
        btn_up<='0';        
        btn_down<='0';        
        btn_izq<='0';        
        btn_dcha<='1'; 
        wait for 50 ns; 
        
              
   end process; 



end Behavioral;
