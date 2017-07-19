LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY RGB2GS IS
PORT ( iRed, iGreen, iBlue :	IN		unsigned(11 DOWNTO 0);
		oGreyscale:				OUT	unsigned(11 DOWNTO 0));
END RGB2GS;

ARCHITECTURE RGB2GS_arch OF RGB2GS IS
BEGIN
	oGreyscale <= iRed / 3 + iGreen / 3 + iBlue / 3;
END RGB2GS_arch;
