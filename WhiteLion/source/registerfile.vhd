--##########################################################################################--
--########### GŁÓWNI AUTORZY KODU DO IMPEMENTACJI: JAKUB OBACZ, MICHAL POPEK ###############--
--############## AUTORZY TESTÓW: MATEUSZ WOLAK, WIKTOR BAJEWSKI, JAKUB OBACZ ###############--
--##########################################################################################--
-- modul rejestrow
-- w module znajduje sie 8 bitowe rejestry
-- w module tym jest 8 rejestrow

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use work.whitelion.all;

entity registerfile is

port(
  WriteEnable: in regwritetype;
  DataIn: in regdatatype; --dane wejsciowe
  Clock: in std_logic; --zegar
  DataOut: out regdatatype --dane wyjsciowe
);
end registerfile;

architecture Behavioral of registerfile is
  type registerstype is array(0 to 7) of std_logic_vector(7 downto 0);
  signal registers: registerstype;

begin
  regs: for I in 0 to 7 generate
    process(WriteEnable(I), DataIn(I), Clock)
    begin
      if rising_edge(Clock) then
        if(WriteEnable(I) = '1') then
          registers(I) <= DataIn(I); --przypisanie danych do rejestrow
        end if;
      end if;
    end process;
    DataOut(I) <= registers(I) when WriteEnable(I)='0' else DataIn(I); -- przypisanie wartosci z rejestrow do danych wyjsciowych
  end generate regs;
end Behavioral;
