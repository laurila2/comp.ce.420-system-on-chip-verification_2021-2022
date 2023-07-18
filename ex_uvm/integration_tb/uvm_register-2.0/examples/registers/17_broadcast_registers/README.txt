George Gorman - LSI

Broadcast registers 

Registers that are wrappers around a list of other registers.
The list of other registers are the "target" registers.
When the broadcast register is written, the list of targets
is iterated through, with a write happening to each one in turn.

The "value" of the broadcast register itself is never used -
it is NOT a real register. It is just a wrapper around other 
registers.


