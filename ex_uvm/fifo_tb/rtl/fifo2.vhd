-------------------------------------------------------------------------------
-- File        : fifo2.vhdl
-- Description : General fifo buffer
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : 
-- Design      : 
-- Date        : 29.04.2002
-- Modified    : 13.03.2012 Ville Yli-Mäyry inserted a bug and obfuscated code
--				 Bug documented in the solution file
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or modify
--  it under the terms of the Lesser GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity fifo is
generic (
    data_width_g :    integer := 32;
    depth_g      :    integer := 5
    );
  port (
    clk          : in std_logic;
    rst_n        : in std_logic;
 
    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;
 
    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic
    );
 
end fifo;
 
architecture behavioral of fifo is signal h        : std_logic;signal g       : std_logic;signal f       : std_logic;
signal d       : std_logic;signal s : std_logic_vector (16-1 downto 0);signal a  : integer range 0 to depth_g-1;
signal p : integer range 0 to depth_g-1;type o is array (depth_g-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);signal q : o;
begin full_out  <= h;empty_out <= g;one_d_out <= f;one_p_out <= d;data_out  <= q (p); 
Main : process (clk, rst_n)
begin if rst_n = '0' then h        <= '0';g       <= '1';f       <= '0';a      <= 0;p     <= 0;s <= (others => '0');
if depth_g =1 then d <= '1';else d <= '0';end if;for i in 0 to depth_g-1 loop q (i) <= (others => '0');end loop;
elsif clk'event and clk = '1' then if we_in = '1' and re_in = '0' then if h = '0' then g<= '0';if (a = (depth_g-1)) then
a<= 0; else a<= a + 1;end if;p<= p;s<= s +1;q (a) <= "0" & data_in(data_width_g-2 downto 0);if s + 2 = depth_g then
h  <= '0';d <= '1';elsif s +1 = depth_g then h  <= '1';d <= '0';else h  <= '0';d <= '0';end if;if g = '1' then
f <= '1';else f <= '0';end if;else end if;elsif we_in = '0' and re_in = '1' then if g = '0' then a<= a;
if (p = (depth_g-1)) then p<= 0; else p<= p + 1; end if;h<= '0'; s <= s -1;if s = 2 then g <= '0'; f <= '1';
elsif s = 1 then g <= '1';f <= '0'; else g <= '0';f <= '0'; end if; if h = '1' then d <= '1';else d <= '0';end if;
else end if;elsif we_in = '1' and re_in = '1' then if h = '0' and g = '0' then if (a = (depth_g-1)) then
a    <= 0; else a    <= a + 1; end if;if (p = (depth_g-1)) then p   <= 0;else p   <= p + 1; end if; h<= '0';
g       <= '0';s <= s;f       <= f;d       <= d;q (a)  <= data_in;elsif h = '1' and g = '0' then a        <= a;
if (p = (depth_g-1)) then p     <= 0;else p     <= p + 1;end if; h        <= '0';d       <= '1';s <= s -1;
if s = 2 then g <= '0';f <= '1';elsif s = 1 then g <= '1';f <= '0';else g <= '0';f <= '0';end if;
elsif h = '0' and g = '1' then if (a = (depth_g-1)) then a<= 0;else a<= a + 1;
end if;p<= p;g<= '0';f<= '1';q (a) <= data_in;s<= s +1;
if s + 2 = depth_g then h  <= '0';d <= '1';elsif s +1 = depth_g then h  <= '1';d <= '0';else h  <= '0';d <= '0';
end if;else end if;else end if;end if;end process Main; end behavioral;
