LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity sobel_h is 
	port ( 	iclk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
				pixout 	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
			);
end sobel_h ; 

ARCHITECTURE Behavior OF sobel_h IS
--	TYPE tab_ligne is array( 0 to 637 ) of STD_LOGIC_VECTOR(11 DOWNTO 0);
--	SIGNAL tab_fifo_ligne1 : tab_ligne ; 
--	SIGNAL tab_fifo_ligne2 : tab_ligne ; 
	TYPE tab_pix is array( 0 to 7 ) of signed(15 DOWNTO 0);
	SIGNAL tmp_pix : tab_pix ; 
	signal tmp : signed(15 DOWNTO 0) ;
	signal clk : STD_LOGIC;
	
	component line_buf is 
		port(clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN signed(15 DOWNTO 0);
				pixout	: OUT signed(15 DOWNTO 0)
			); 
	end component ;
	
begin

ligne1:line_buf port map (clk, reset, enable, pixvalid, tmp_pix(1), tmp_pix(2)) ; 
ligne2:line_buf port map (clk, reset, enable, pixvalid, tmp_pix(4), tmp_pix(5)) ; 


process (clk, reset) begin
	if(clk'Event and clk = '1' and pixvalid = '1') then
		tmp_pix(0) <= "0000" & signed(pixin); 
		tmp_pix(1) <= tmp_pix(0) ; 
		tmp_pix(3) <= tmp_pix(2) ; 
		tmp_pix(4) <= tmp_pix(3) ;
		tmp_pix(6) <= tmp_pix(5) ; 
		tmp_pix(7) <= tmp_pix(6) ;
	end if ; 
end process ; 



process (enable) begin 
	if (enable = '1') then
			-- sobel filtre
			tmp <= (tmp_pix(7) + (tmp_pix(6) + tmp_pix(6)) + tmp_pix(5) - tmp_pix(1) - (tmp_pix(0) + tmp_pix(0)) - ("0000" & signed(pixin))) + (tmp_pix(1) + (tmp_pix(4) + tmp_pix(4)) + tmp_pix(7) - ("0000" & signed(pixin)) - (tmp_pix(2) + tmp_pix(2)) - tmp_pix(5)) ;  
--		tmp <= (("0000" & tmp_pix(7)) + (("0000" & tmp_pix(6)) + ("0000" & tmp_pix(6))) + ("0000" & tmp_pix(5)) - ("0000" & tmp_pix(1)) - (("0000" & tmp_pix(0)) + ("0000" & tmp_pix(0))) - ("0000" & pixin));

		if (tmp < 0) then
			tmp <= "0000000000000000";
		end if;
		if (tmp > "0000011111111111") then
			tmp <= "0000011111111111";
		end if;
	else 
		tmp <= "0000" & signed(pixin) ; 
	end if ; 
end process ; 
pixout <= std_logic_vector(tmp)(11 downto 0) ; 
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity line_buf is
	port (	clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN signed(15 DOWNTO 0);
				pixout 	: OUT signed(15 DOWNTO 0)
			);
end line_buf ; 

ARCHITECTURE Behavior1 OF line_buf IS
	TYPE tab_ligne is array( 0 to 637 ) of STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL tab_fifo_ligne : tab_ligne ; 

begin
	
b1:for x in 0 to 637 generate 
	process (clk, reset, enable) begin
		if(clk'Event and clk = '1' and pixvalid = '1')then
			if (reset = '0') then 
				tab_fifo_ligne(x) <= "000000000000" ; 
			end if ; 
			if (enable = '1') then 
				if (x = 0) then
					tab_fifo_ligne(x) <= std_logic_vector(pixin(11 downto 0));
				else 
					tab_fifo_ligne(x) <= tab_fifo_ligne(x-1) ; 		
				end if ;
			end if ; 
		end if ; 
	end process ; 
	pixout <= "0000" & signed(tab_fifo_ligne(637));
end generate ; 

END Behavior1;