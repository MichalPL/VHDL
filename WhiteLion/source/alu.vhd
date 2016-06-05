--##########################################################################################--
--########### GLOWNI AUTORZY KODU DO IMPEMENTACJI: JAKUB OBACZ, MICHAL POPEK ###############--
--############## AUTORZY TESTOW: MATEUSZ WOLAK, WIKTOR BAJEWSKI, JAKUB OBACZ ###############--
--##########################################################################################--

-- blok ALU realizujacy operacje arytmetyczne oraz bitowe

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.whitelion.all;

entity alu is

  port(
    Op: in std_logic_vector(4 downto 0);
    DataIn1, DataIn2: in std_logic_vector(7 downto 0);
    DataOut: out std_logic_vector(7 downto 0);
    FR: out std_logic_vector(2 downto 0)
   );
end alu;

architecture Behavioral of alu is
shared variable A: integer; --zmienna A
shared variable B: integer; --zmienna B
begin
  process(DataIn1, DataIn2, Op)
  begin

  case Op is
--operacje reallizowane w ALU
      when "00000" => --dodawanie
        DataOut <= std_logic_vector(signed(DataIn1) + signed(DataIn2));
      when "00001" => --dodawanie
		   A := to_integer(signed(DataIn1));
			B := to_integer(signed(DataIn2));
		  DataOut <= std_logic_vector(to_signed(A+B, DataOut'length));
      when "00010" => --odejmowanie
        DataOut <= std_logic_vector(signed(DataIn1) - signed(DataIn2));
      when "00011" => --odejmowanie
        A := to_integer(signed(DataIn1));
			B := to_integer(signed(DataIn2));
		  DataOut <= std_logic_vector(to_signed(A-B, DataOut'length));
      when "00100" => --mnozenie
			A := to_integer(signed(DataIn1));
			B := to_integer(signed(DataIn2));
			DataOut <= std_logic_vector(to_signed(A*B, DataOut'length));
		when "00101" => -- mnozenie
			A := to_integer(signed(DataIn1));
			B := to_integer(signed(DataIn2));
			DataOut <= std_logic_vector(to_signed(A*B, DataOut'length));
      when "01000" =>  -- inkrementacja
        DataOut <= std_logic_vector(signed(DataIn1) + 1);
      when "01001" =>  -- dekrementacja
        DataOut <= std_logic_vector(signed(DataIn1) - 1);
      when "01010" => -- porownanie
			if to_integer(signed(DataIn1)) > to_integer(signed(DataIn2)) then
				DataOut <= "10000000";
				FR <= "100";
			elsif to_integer(signed(DataIn1)) = to_integer(signed(DataIn2)) then
				DataOut <= "00001000";
				FR <= "010";
			else
				DataOut <= "00000001";
				FR <= "001";
			end if;
      when "01011" => --porownanie
			if to_integer(signed(DataIn1)) > to_integer(signed(DataIn2)) then
				DataOut <= "10000000";
				FR <= "100";
			elsif to_integer(signed(DataIn1)) = to_integer(signed(DataIn2)) then
				DataOut <= "00001000";
				FR <= "010";
			else
				DataOut <= "00000001";
				FR <= "001";
			end if;
      when "01100" => --OR
        DataOut <= DataIn1 or DataIn2;

      when "01101" => --OR
        DataOut <= DataIn1 or DataIn2;

      when "01110" => --AND
        DataOut <= DataIn1 and DataIn2;
	
      when "01111" => --AND
        DataOut <= DataIn1 and DataIn2;

      when "10000" => --NOT
        DataOut <= not DataIn1;
	
      when "10001" => --NOT
        DataOut <= not DataIn1;
		
      when "10101" => --XOR
        DataOut <= DataIn1 xor DataIn2;

		when "10110" => --XOR
        DataOut <= DataIn1 xor DataIn2;

		-- resetowanie tr do uruchamiania procesora
		when "11111" =>
        FR <= "000";
		  
      when others =>
        DataOut <= "00000000";
		  FR <= "111";
		  
    end case;
  end process;
end Behavioral;
