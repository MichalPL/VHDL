--modul RAM
--4096*8 plik bitowy
--jednoczesnse wsparcie wczytywania/zapisywania
--16 bitowa lub 8 bitowa magistrala danych
--16 bitowy adres magistrali
--Przy Reset, zaladuje "defaultowy" obraz RAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity blockram is
  port(
    Address: in std_logic_vector(7 downto 0); --adres pamieci
    WriteEnable: in std_logic_vector(1 downto 0); --opcja zapisywania 1 bajtu w danym momencie
    Enable: in std_logic;
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0)
  );
end blockram;

architecture Behavioral of blockram is
	--sygnaly ram
    type ram_type is array (255 downto 0) of std_logic_vector (7 downto 0);
    signal RAM0: ram_type;
    signal RAM1: ram_type;
    signal di0, di1: std_logic_vector(7 downto 0);
    signal do : std_logic_vector(15 downto 0);
begin
  di0 <= DataIn(7 downto 0) when WriteEnable(0)='1' else do(7 downto 0); --zapis danych wejsciowych do sygnalu di0
  di1 <= DataIn(15 downto 8) when WriteEnable(1)='1' else do(15 downto 8); -- zapis danych wejsciowych do sygnalu di1
  process (Clock)
  begin
    if rising_edge(Clock) then
      if Enable = '1' then
        if WriteEnable(0)='1' then
          RAM0(conv_integer(Address)) <= di0;
        else
          do(7 downto 0) <= RAM0(conv_integer(Address)) ;
        end if;
        if WriteEnable(1)='1' then
          RAM1(conv_integer(Address)) <= di1;
        else
          do(15 downto 8) <= RAM1(conv_integer(Address));
        end if;
      end if;
    end if;
  end process;
  DataOut <= do;
end Behavioral;
