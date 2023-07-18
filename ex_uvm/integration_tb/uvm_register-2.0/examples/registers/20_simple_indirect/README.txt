
Using the UVM Indirect Register

When using the UVM indirect register, construct two registers
and "bind" them together.

The two registers are the "address" register and the "data" register.
Those two registers can be added to the address space as needed.

Writing to the address register causes a pointer to be set - the
current "address" that the data register uses.

The data register is actually an array of values - indexed by the pointer
from the address register. Each read() or write() on the data register will
automatically increment the address pointer.

