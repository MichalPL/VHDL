--##########################################################################################--
--############ TESTOWY FRAGMENT KODU DO PRZECHOWYWANIA KODU PROGRAMU #######################--
--##########################################################################################--


library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
-- pamiec bootowalna 
entity bootrom is
port (CLK : in std_logic;
      EN : in std_logic;
      ADDR : in std_logic_vector(4 downto 0);
      DATA : out std_logic_vector(15 downto 0));
end bootrom;

architecture syn of bootrom is
  constant ROMSIZE: integer := 64;
  type ROM_TYPE is array(0 to ROMSIZE/2-1) of std_logic_vector(15 downto 0);
  signal rdata : std_logic_vector(15 downto 0);
begin

 

    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (EN = '1') then
                DATA <= rdata;
            end if;
        end if;
    end process;
end syn;

                