library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.RACETRACK_PKG.ALL;

entity FSM_bot_TB is
--  Port ( );
end FSM_bot_TB;

architecture Behavioral of FSM_bot_TB is

    component FSM_bot is 
        Port ( 
    clk: in std_logic;
    rst: in std_logic; 
    enable:in std_logic;   
    fil_pos_bot: out unsigned(5 downto 0);
    col_pos_bot: out unsigned(5 downto 0)
    );   
    
    end component;
    
    signal clk, rst, enable: std_logic;
    signal fil_pos_bot,col_pos_bot: unsigned(5 downto 0);
    

begin
    
    
    tb_bot:FSM_bot
    port map(
        clk=>clk,
        rst=>rst,
        enable=>enable,
        fil_pos_bot=>fil_pos_bot,
        col_pos_bot=>col_pos_bot  
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
        wait for 5ns;                       
        rst<='0'; 
        enable<='1';               
        wait for 100 ns;  
        rst<='0';  
          enable<='0';
        wait for 100 ns;  
        rst<='0';
          enable<='1';                     
        wait;     
   end process; 

end Behavioral;
