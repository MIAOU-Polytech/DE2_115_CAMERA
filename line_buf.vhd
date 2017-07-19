LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

entity line_buf is
	port (	clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				pixout 	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
			);
end line_buf ; 

ARCHITECTURE Behavior1 OF line_buf IS
	TYPE tab_ligne is array( 0 to 797 ) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL tab_fifo_ligne : tab_ligne ; 

begin
	
b1:for x in 0 to 797 generate 
	process (clk, reset, enable, pixvalid) begin
		if(clk'Event and clk = '1' and pixvalid = '1')then
			if (reset = '0') then 
				tab_fifo_ligne(x) <= "0000000000000000" ; 
			end if ; 
			if (enable = '1') then 
				if (x = 0) then
					tab_fifo_ligne(x) <= pixin ; 
				else 
					tab_fifo_ligne(x) <= tab_fifo_ligne(x-1) ; 		
				end if ;
			end if ; 
		end if ; 
	end process ; 
	pixout <= tab_fifo_ligne(797) ;
end generate ; 

END Behavior1;