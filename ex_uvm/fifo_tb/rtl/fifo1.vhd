-------------------------------------------------------------------------------
-- File        : fifo1.vhdl
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
architecture behavioral of fifo is signal a        : std_logic;signal s       : std_logic;signal d       : std_logic;
signal f       : std_logic;signal g : std_logic_vector (16-1 downto 0);signal h  : integer range 0 to depth_g-1;
signal j : integer range 0 to depth_g-1;type k is array (depth_g-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);signal l : k;begin full_out  <= a;empty_out <= s;one_d_out <= d;one_p_out <= f;data_out  <= l (j); 
Main : process (clk, rst_n)begin if rst_n = '0' then a<= '0';s<= '1';d<= '0';h<= 0; j<= 0; g <= (others => '0');
if depth_g =1 then f <= '1'; else f <= '0';end if;for i in 0 to depth_g-1 loop l (i) <= (others => '0');
end loop;elsif clk'event and clk = '1' then if we_in = '1' and re_in = '0' then s<= '0';if (h = (depth_g-1)) then
h<= 0;else h<= h + 1;end if; j<= j;g<= g +1;l (h) <= data_in;if g + 2 = depth_g then a  <= '0';f <= '1';
elsif g +1 = depth_g then a  <= '1';f <= '0';else a  <= '0';f <= '0';end if;if s = '1' then d <= '1'; else d <= '0';
end if; elsif we_in = '0' and re_in = '1' then if s = '0' then h <= h;if (j = (depth_g-1)) then j<= 0; else j<= j + 1;
end if; a<= '0'; g <= g -1; if g = 2 then s <= '0';d <= '1'; elsif g = 1 then s <= '1'; d <= '0'; else s <= '0';
d <= '0'; end if;if a = '1' then f <= '1';else f <= '0';end if;else end if;elsif we_in = '1' and re_in = '1' then
if a = '0' and s = '0' then if (h = (depth_g-1)) then h<= 0; else h<= h + 1; end if; if (j = (depth_g-1)) then
j<= 0; else j<= j + 1;end if;a<= '0';s<= '0';g <= g;d<= d;f <= f;l (h)  <= data_in;elsif a = '1' and s = '0' then
h        <= h;if (j = (depth_g-1)) then j<= 0; else j<= j + 1; end if;a<= '0'; f<= '1';g <= g -1;if g = 2 then
s <= '0';d <= '1';elsif g = 1 then s <= '1';d <= '0';else s <= '0';d <= '0'; end if; elsif a = '0' and s = '1' then
if (h = (depth_g-1)) then h<= 0; else h <= h + 1; end if; j<= j; s<= '0'; d<= '1'; l (h) <= data_in; g<= g +1;
if g + 2 = depth_g then a  <= '0'; f <= '1';elsif g +1 = depth_g then a  <= '1';f <= '0'; else a  <= '0';f <= '0';
end if;else end if; else end if;end if;end process Main;end behavioral;
