
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Asincrono_JK is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           SEGMENTOS : out  STD_LOGIC_VECTOR (7 downto 0);
           DISPLAYS : out  STD_LOGIC_VECTOR (7 downto 0));
end Asincrono_JK;

architecture Behavioral of Asincrono_JK is
--Señales de reloj para el contador
	signal CONT : STD_LOGIC_VECTOR (25 downto 0);
	signal CLKO : STD_LOGIC;
--Señales de reloj para el multiplexor
	signal CONT1 : INTEGER range 0 to 100000;
	signal SELEC : STD_LOGIC_VECTOR (1 downto 0) := "00";
--Señales para flipflops JK
	signal J,K : STD_LOGIC := '1';
	signal Q,NQ : STD_LOGIC_VECTOR (3 downto 0);
--Señales para Multiplexación
	signal MOSTRADOR : STD_LOGIC_VECTOR(1 downto 0) := "00";
	signal Num1,Num2 : STD_LOGIC_VECTOR(7 downto 0);
	
	
begin

--Reloj para Contador
Clock_Contador : process (CLK)
	begin
		if(rising_edge(CLK)) then 
			CONT <= CONT + '1';
		end if;
	end process;
	
	CLKO <= CONT(25);

--Reloj para Multiplexacion de Displays
Clock_Multiplexor : process (CLK)
	begin
		if(rising_edge(CLK))	then
			if CONT1 < 100000 then
				CONT1 <= CONT1 + 1;
			else
				CONT1 <= 0;
				SELEC <= SELEC + 1;
			end if;
		end if;
	end process;

--Contador asincrono
FlipFlop1 : process(CLKO,RST)
	variable qn : STD_LOGIC;
	begin
	if(RST = '1') then
		qn := '0';
		elsif(rising_edge(CLKO)) then
			if (J='1' and K ='1') then
				qn := not qn;
			else
				null;
			end if;
		else
			null;
	end if;
	Q(0) <= qn;
	NQ(0) <= not qn;
	end process;
	
FlipFlop2: process (NQ(0),RST)
	variable qn : STD_LOGIC;
	begin
	if(RST = '1') then
		qn := '0';
		elsif(rising_edge(NQ(0))) then
			if (J='1' and K ='1') then
				qn := not qn;
			else
				null;
			end if;
		else
			null;
		end if;
	Q(1) <= qn;
	NQ(1) <= not qn;
	end process;
	
FlipFlop3 : process(NQ(1),RST)
	variable qn : STD_LOGIC;
	begin
	if(RST = '1') then
		qn := '0';
		elsif(rising_edge(NQ(1))) then
			if (J='1' and K ='1') then
				qn := not qn;
			else
				null;
			end if;
		else
			null;
		end if;
	Q(2) <= qn;
	NQ(2) <= not qn;
	end process;
	
FlipFlop4 : process (NQ(2),RST)
	variable qn : STD_LOGIC;
	begin
	if(RST = '1') then
		qn := '0';
		elsif(rising_edge(NQ(2))) then
			if (J='1' and K ='1') then
				qn := not qn;
			else
				null;
			end if;
		else
			null;
		end if;
	Q(3) <= qn;
	NQ(3) <= not qn;
	end process;

--Decodificador 4 a 8 para Displays

Decoder : process (Q,NQ)
	begin
		case Q is
				when "0000" => Num1 <= x"03";--0
				when "0001" => Num1 <= x"9F";--1
            when "0010" => Num1 <= x"25";
            when "0011" => Num1 <= x"0D";
            when "0100" => Num1 <= x"99";
            when "0101" => Num1 <= x"49";
            when "0110" => Num1 <= x"C1";
            when "0111" => Num1 <= x"1F";
				when "1000" => Num1 <= x"01";
				when "1001" => Num1 <= x"19";
				when "1010" => Num1 <= x"11";
				when "1011" => Num1 <= x"C1";
				when "1100" => Num1 <= x"63";
				when "1101" => Num1 <= x"85";
				when "1110" => Num1 <= x"61";
				when "1111" => Num1 <= x"71";--F
				when others => Num1 <= x"FF";
         end case;
			
		case NQ is 
				when "0000" => Num2 <= x"03";
            when "0001" => Num2 <= x"9F";
            when "0010" => Num2 <= x"25";
            when "0011" => Num2 <= x"0D";
            when "0100" => Num2 <= x"99";
            when "0101" => Num2 <= x"49";
            when "0110" => Num2 <= x"C1";
            when "0111" => Num2 <= x"1F";
				when "1000" => Num2 <= x"01";
				when "1001" => Num2 <= x"19";
				when "1010" => Num2 <= x"11";
				when "1011" => Num2 <= x"C1";
				when "1100" => Num2 <= x"63";
				when "1101" => Num2 <= x"85";
				when "1110" => Num2 <= x"61";
				when "1111" => Num2 <= x"71";
            when others => Num2 <= x"FF";
         end case;
		end process;

	
--Multiplexación displays
	
Selector_Display : process (SELEC,MOSTRADOR,NUM1,NUM2)
	begin
		case SELEC is
			when "00" => MOSTRADOR <= "10";
			when "01" => MOSTRADOR <= "01";
			when others => MOSTRADOR <= "11";
		end case;
		
		case MOSTRADOR is
			when "10" => SEGMENTOS <= Num1;
			when "01" => SEGMENTOS <= Num2;
			when others	 => SEGMENTOS <= x"FF";
		end case;
	end process;
	
--Displays a Encender
--		0111
--		0111
	DISPLAYS(7 downto 4) <= MOSTRADOR(1) & "111";
	DISPLAYS(3 downto 0) <= MOSTRADOR(0) & "111";
	
end Behavioral;

