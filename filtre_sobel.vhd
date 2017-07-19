LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity SobelFilter is 
	port ( 	clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
				pixout 	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
			);
end SobelFilter ; 

ARCHITECTURE Behavior OF SobelFilter IS
--	TYPE tab_ligne is array( 0 to 397 ) of STD_LOGIC_VECTOR(11 DOWNTO 0);
--	SIGNAL tab_fifo_ligne1 : tab_ligne ; 
--	SIGNAL tab_fifo_ligne2 : tab_ligne ; 
	TYPE tab_pix is array( 0 to 7 ) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL tmp_pix : tab_pix ; 
	signal tmp : STD_LOGIC_VECTOR(11 DOWNTO 0) ;
	signal tmp2 : signed(31 DOWNTO 0) ;
	signal tmp3 : signed(31 DOWNTO 0) ;


	
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
		tmp_pix(0) <= "0000" & pixin; 
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
		tmp3 <= (signed(tmp_pix(7)) + 2*signed(tmp_pix(6)) + signed(tmp_pix(5)) - signed(tmp_pix(1)) - 2*signed(tmp_pix(0)) - ("0000" & signed(pixin))) + (signed(tmp_pix(1)) + 2*signed(tmp_pix(4)) + signed(tmp_pix(7)) - ("0000" & signed(pixin)) - 2*signed(tmp_pix(2)) - signed(tmp_pix(5))) ;  
		if (tmp3 > 4095 or tmp3 < -4095) then
			tmp2 <= to_signed(4095, 32);
		else
			tmp2 <= abs(tmp3);
		end if;
		tmp <= std_logic_vector(tmp2(11 downto 0));
	else
		tmp <= pixin;
	end if ; 
end process ; 
pixout <= tmp; 
END Behavior;