LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity DownsamplingFilter is 
	port ( 	clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				pixin 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
				pixout 	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
				iX_Cont  : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
				iY_Cont  : IN STD_LOGIC_VECTOR(10 DOWNTO 0)
			);
end DownsamplingFilter ; 

ARCHITECTURE Behavior OF DownsamplingFilter IS
--	TYPE tab_ligne is array( 0 to 397 ) of STD_LOGIC_VECTOR(11 DOWNTO 0);
--	SIGNAL tab_fifo_ligne1 : tab_ligne ; 
--	SIGNAL tab_fifo_ligne2 : tab_ligne ; 
	TYPE tab_pix is array( 0 to 7 ) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL tmp_pix : tab_pix ; 
	signal tmp : STD_LOGIC_VECTOR(11 DOWNTO 0) ;
	signal tmp2 : signed(15 DOWNTO 0) ;
	
	signal samplen : integer range 0 to 840 := 0;
--	signal samplen : unsigned(15 DOWNTO 0) := to_unsigned(0, 16);
	signal cnt : integer range 0 to 840 := 0;
--	signal cnt     : unsigned(15 DOWNTO 0) := to_unsigned(0, 16);

	signal CoordX : unsigned(10 DOWNTO 0);
	signal CoordY : unsigned(10 DOWNTO 0);
	constant SIZE : unsigned := to_unsigned(28, 5);

	TYPE tab_samples is array( 0 to 783 ) of STD_LOGIC_VECTOR(11 DOWNTO 0) ;
	SIGNAL tmp_samples : tab_samples := (others => "000000000000"); 

	
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


ligne1:line_buf port map (clk, reset, '1', pixvalid, tmp_pix(1), tmp_pix(2)) ; 
ligne2:line_buf port map (clk, reset, '1', pixvalid, tmp_pix(4), tmp_pix(5)) ; 



CoordX <= unsigned(iX_Cont);
CoordY <= unsigned(iY_Cont);

--process (clk, reset, pixvalid) begin
--	if(clk'Event and clk = '1' and pixvalid = '1') then
--		tmp_pix(0) <= "0000" & pixin; 
--		tmp_pix(1) <= tmp_pix(0) ; 
--		tmp_pix(3) <= tmp_pix(2) ; 
--		tmp_pix(4) <= tmp_pix(3) ;
--		tmp_pix(6) <= tmp_pix(5) ; 
--		tmp_pix(7) <= tmp_pix(6) ;
--	end if ; 
--end process ; 



process (clk, enable, pixvalid) begin 
	if (rising_edge(clk)) then
		if (pixvalid = '1') then
		
		
			tmp_pix(0) <= "0000" & pixin; 
		tmp_pix(1) <= tmp_pix(0) ; 
		tmp_pix(3) <= tmp_pix(2) ; 
		tmp_pix(4) <= tmp_pix(3) ;
		tmp_pix(6) <= tmp_pix(5) ; 
		tmp_pix(7) <= tmp_pix(6) ;
		
		if (enable = '1' and CoordX >= 200 and CoordY >= 200) then 
			if (CoordX < (3*SIZE + 200) and CoordY < (3*SIZE + 200)) then
				if (((CoordX - 200) mod 3) = 1 and ((CoordY - 200) mod 3) = 1) then
					-- mean filtre
					tmp2 <= (signed(tmp_pix(7)) + signed(tmp_pix(6)) + signed(tmp_pix(5)) + signed(tmp_pix(4)) + signed(tmp_pix(3)) + signed(tmp_pix(2)) + signed(tmp_pix(1)) + signed(tmp_pix(0)) + signed("0000" & unsigned(pixin))) / 9;
					tmp_samples(samplen) <= std_logic_vector(tmp2)(11 DOWNTO 0);
					samplen <= samplen + 1;
					tmp <= std_logic_vector(tmp2)(11 DOWNTO 0);
				else
					tmp <= "110000000000";
				end if;
			elsif (CoordX < (4*SIZE + 200) and CoordY < (4*SIZE + 200) and CoordX >= (3*SIZE + 200) and CoordY >= (3*SIZE + 200)) then
				--cnt <= 1;
				tmp <= tmp_samples(cnt);
				cnt <= cnt + 1;
			elsif (CoordX >= (4*SIZE + 200) and CoordY >= (4*SIZE +200)) then
				tmp <= pixin;
				cnt <= 0;
				samplen <= 0;
			else
				tmp <= pixin;
			end if;
		elsif (CoordX < 200 and CoordY < 200) then
			cnt <= 0;
			samplen <= 0;
			tmp <= pixin;
		else
			tmp <= pixin;
		end if;
	else
		tmp <= pixin;
	end if ; 
	end if;
end process ; 
pixout <= tmp; 
END Behavior;
