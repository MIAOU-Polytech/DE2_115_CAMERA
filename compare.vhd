LIBRARY ieee; 
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

ENTITY compare IS 
    PORT ( 
		ai: IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		bi: IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
		ao: OUT STD_LOGIC_VECTOR (15 DOWNTO 0); 
		bo: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)  
    ); 
END ENTITY compare;

ARCHITECTURE compare_arch OF compare IS 
BEGIN 
    PROCESS (ai, bi) 
    BEGIN
		 -- num0_in is smaller than num1_in, so switch them 
		 IF (unsigned(ai) < unsigned(bi)) THEN 
			  ao <= bi; 
			  bo <= ai; 
		 -- num0_in and num1_in are in order 
		 ELSE 
			  ao <= ai; 
			  bo <= bi; 
		 END IF;
     END PROCESS; 
END ARCHITECTURE compare_arch;