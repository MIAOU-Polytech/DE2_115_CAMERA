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
	constant SIZE : integer := 28;
	constant DOWNSAMPLE_FACTOR : integer := 4; -- tmp_pix needs to be adjusted, linear filter too
	constant OFFSETX : integer := 200;
	constant OFFSETY : integer := 200;


--	TYPE tab_ligne is array( 0 to 397 ) of STD_LOGIC_VECTOR(11 DOWNTO 0);
--	SIGNAL tab_fifo_ligne1 : tab_ligne ; 
--	SIGNAL tab_fifo_ligne2 : tab_ligne ; 
	TYPE tab_pix is array( 0 to 14 ) of STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL tmp_pix : tab_pix ; 
	signal tmp : STD_LOGIC_VECTOR(11 DOWNTO 0) ;
	signal tmp2 : signed(15 DOWNTO 0) ;

	signal CoordX : unsigned(10 DOWNTO 0);
	signal CoordY : unsigned(10 DOWNTO 0);
	
	signal arrayoffset : integer range 0 to SIZE*SIZE-1 := 0;


	TYPE tab_samples is array( 0 to SIZE*SIZE-1 ) of STD_LOGIC_VECTOR(11 DOWNTO 0) ;
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

ligne1:line_buf port map (clk, reset, '1', pixvalid, tmp_pix(2), tmp_pix(3)) ;
ligne2:line_buf port map (clk, reset, '1', pixvalid, tmp_pix(6), tmp_pix(7)) ;
ligne3:line_buf port map (clk, reset, '1', pixvalid, tmp_pix(10), tmp_pix(11)) ; 


CoordX <= unsigned(iX_Cont);
CoordY <= unsigned(iY_Cont);

process (clk, enable, pixvalid) begin 
	if (rising_edge(clk) and pixvalid = '1') then
		tmp <= pixin;

		tmp_pix(0) <= "0000" & pixin; 
		tmp_pix(1) <= tmp_pix(0) ; 
		tmp_pix(2) <= tmp_pix(1) ; 
		tmp_pix(4) <= tmp_pix(3) ;
		tmp_pix(5) <= tmp_pix(4) ;
		tmp_pix(6) <= tmp_pix(5) ;
		tmp_pix(8) <= tmp_pix(7) ;
		tmp_pix(9) <= tmp_pix(8) ;
		tmp_pix(10) <= tmp_pix(9) ;
		tmp_pix(12) <= tmp_pix(11) ;
		tmp_pix(13) <= tmp_pix(12) ;
		tmp_pix(14) <= tmp_pix(13) ;
		
		
		if (enable = '1') then
			if (CoordX >= OFFSETX and CoordY >= OFFSETY and CoordX < ((DOWNSAMPLE_FACTOR +1)*SIZE + OFFSETX) and CoordY < ((DOWNSAMPLE_FACTOR +1)*SIZE + OFFSETY)) then 
				if (CoordX < (DOWNSAMPLE_FACTOR*SIZE + OFFSETX) and CoordY < (DOWNSAMPLE_FACTOR*SIZE + OFFSETY)) then
					if (((CoordX - OFFSETX) mod DOWNSAMPLE_FACTOR) = 1 and ((CoordY - OFFSETY) mod DOWNSAMPLE_FACTOR) = 1) then
						arrayoffset <= to_integer((CoordX - OFFSETX -1) / 4 + SIZE*(CoordY - OFFSETY -1) / 4) ;
						
						-- mean filtre
						tmp2 <= (signed(tmp_pix(14)) + signed(tmp_pix(13)) + signed(tmp_pix(12)) + signed(tmp_pix(11)) + signed(tmp_pix(10)) + signed(tmp_pix(9)) + signed(tmp_pix(8)) + signed(tmp_pix(7)) + signed(tmp_pix(6)) + signed(tmp_pix(5)) + signed(tmp_pix(4)) + signed(tmp_pix(3)) + signed(tmp_pix(2)) + signed(tmp_pix(1)) + signed(tmp_pix(0)) + signed("0000" & unsigned(pixin))) / 9;
						tmp_samples(arrayoffset) <= std_logic_vector(tmp2)(11 DOWNTO 0);
						tmp <= tmp_samples(arrayoffset);
					else
						tmp <= "110000000000";
					end if;
				elsif (CoordX >= (DOWNSAMPLE_FACTOR*SIZE + OFFSETX) and CoordY >= (DOWNSAMPLE_FACTOR*SIZE + OFFSETY)) then
					arrayoffset <= to_integer((CoordX - OFFSETX - DOWNSAMPLE_FACTOR*SIZE) + SIZE*(CoordY - OFFSETY - DOWNSAMPLE_FACTOR*SIZE)) ;
					tmp <= tmp_samples(arrayoffset);
				end if;
			end if;
		end if;
	end if; 
end process ; 
pixout <= tmp; 
END Behavior;
