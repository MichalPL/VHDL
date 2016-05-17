library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.whitelion.all;
--blok pobierajacy dane
entity fetch is
  port(
    Enable: in std_logic;
    AddressIn: in std_logic_vector(15 downto 0);
    Clock: in std_logic; --zegar
    DataIn: in std_logic_vector(15 downto 0); -- port pobierajacy dane z pamieci
    IROut: out std_logic_vector(15 downto 0);
    AddressOut: out std_logic_vector(15 downto 0) -- port zapisujacy dane do pamieci
   );
end fetch;

architecture Behavioral of fetch is
  signal IR: std_logic_vector(15 downto 0);
begin
  process(Clock, AddressIn, DataIn, Enable)
  begin
      if(Enable='1') then
        IR <= DataIn; -- przypisanie danych wejsciowych do rejestru instrukcji
        AddressOut <= AddressIn;
      else
        IR <= x"FFFF"; --poprzez przypisanie do rejestru instrukcji FFFF unikamy bledow pobierania
        AddressOut <= "ZZZZZZZZZZZZZZZZ";
      end if;
  end process;
  IROut <= IR;
end Behavioral;
