LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity TargetGen is 
	port ( 	clk 		: IN STD_LOGIC;
				reset 	: IN STD_LOGIC;
				enable 	: IN STD_LOGIC;
				pixvalid : IN STD_LOGIC;
				switches : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
				pixin 	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
				iX_Cont  : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
				iY_Cont  : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
				oRed 	   : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
				oGreen 	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
				oBlue 	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)

			);
end TargetGen ; 

ARCHITECTURE Behavior OF TargetGen IS
	signal sobelX : signed(31 DOWNTO 0) ;
	signal sobelY : signed(31 DOWNTO 0) ;
	
	signal CoordX : unsigned(10 DOWNTO 0);
	signal CoordY : unsigned(10 DOWNTO 0);
	constant SIZE : unsigned := to_unsigned(28, 8);
	constant OFFSET : unsigned := to_unsigned(5, 8);
	constant THICKNESS : unsigned := to_unsigned(2, 8);
	
begin


CoordX <= unsigned(iX_Cont);
CoordY <= unsigned(iY_Cont);


process (clk, enable, pixvalid) begin 
	if (rising_edge(clk)) then
		if (enable = '1' and pixvalid = '1' and switches(6) = '1') then
			if (
					-- Vertical borders  
			      (((CoordX > OFFSET and CoordX < (OFFSET + THICKNESS)) or (CoordX < (4*SIZE + OFFSET) and CoordX > (4*SIZE + (OFFSET - THICKNESS)))) and CoordY < (4*SIZE + OFFSET) and CoordY > OFFSET)
			  or  -- Horizontal borders
					(((CoordY > OFFSET and CoordY < (OFFSET + THICKNESS)) or (CoordY < (4*SIZE + OFFSET) and CoordY > (4*SIZE + (OFFSET - THICKNESS)))) and CoordX < (4*SIZE + OFFSET) and CoordX > OFFSET)
			) then
				oRed <= "111111111111";
				oGreen <= "000000000000";
				oBlue <= "000000000000";
			else 
				oRed <= pixin;
				oGreen <= pixin;
				oBlue <= pixin;
			end if;
		else
			oRed <= pixin;
			oGreen <= pixin;
			oBlue <= pixin;
		end if ; 
	end if;
end process ; 
END Behavior;