LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;

entity sobel_h is 
	port ( 	clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
				pixout 	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
			);
end sobel_h ; 

ARCHITECTURE Behavior OF sobel_h IS
--	TYPE tab_ligne is array( 0 to 397 ) of STD_LOGIC_VECTOR(11 DOWNTO 0);
--	SIGNAL tab_fifo_ligne1 : tab_ligne ; 
--	SIGNAL tab_fifo_ligne2 : tab_ligne ; 
	TYPE tab_pix is array( 0 to 7 ) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL tmp_pix : tab_pix ; 
	signal tmp : STD_LOGIC_VECTOR(15 DOWNTO 0) ;
	signal tmp2 : STD_LOGIC_VECTOR(15 DOWNTO 0) ;

	
	component line_buf is 
		port(clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				pixout	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
			); 
	end component ;
	
begin


ligne1:line_buf port map (clk, reset, enable, pixvalid, tmp_pix(1), tmp_pix(2)) ; 
ligne2:line_buf port map (clk, reset, enable, pixvalid, tmp_pix(4), tmp_pix(5)) ; 


process (clk, reset, pixvalid) begin
	if(clk'Event and clk = '1' and pixvalid = '1') then
		tmp_pix(0) <= "0000" & pixin ; 
		tmp_pix(1) <= tmp_pix(0) ; 
		tmp_pix(3) <= tmp_pix(2) ; 
		tmp_pix(4) <= tmp_pix(3) ;
		tmp_pix(6) <= tmp_pix(5) ; 
		tmp_pix(7) <= tmp_pix(6) ;
	end if ; 
end process ; 



process (clk, enable, pixvalid) begin 
	if (enable = '1' and pixvalid = '1') then
		-- sobel filtre
		--tmp <= (tmp_pix(1) + (tmp_pix(4) + tmp_pix(4)) + tmp_pix(7) - ("0000" & pixin) - (tmp_pix(2) + tmp_pix(2)) - tmp_pix(5)) ;  
		--tmp <= abs(tmp);
		tmp2 <= (tmp_pix(7) + (tmp_pix(6) + tmp_pix(6)) + tmp_pix(5) - tmp_pix(1) - (tmp_pix(0) + tmp_pix(0)) - ("0000" & pixin)) + (tmp_pix(1) + (tmp_pix(4) + tmp_pix(4)) + tmp_pix(7) - ("0000" & pixin) - (tmp_pix(2) + tmp_pix(2)) - tmp_pix(5)) ;  
		tmp <= abs(tmp2);
	else 
		--tmp <= "0000" & pixin ; 
		tmp <= "0000000000000000";
	end if ; 
end process ; 
pixout <= tmp(11 downto 0) ; 
END Behavior;

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