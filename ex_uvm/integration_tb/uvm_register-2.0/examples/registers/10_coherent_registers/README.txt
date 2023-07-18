Mark Strickland - Ciscon

Coherent registers 

Registers that have a master-slave relationship in which a read 
to the master causes the values in each slave to be saved in a 
snapshot register.  A read to the slave actually returns the 
corresponding values in the snapshot register.  The purpose is 
to allow s/w to to read a counter whose width is greater than 
the bus access width without the potential problem that the 
counter rolled over in the interval(s) between reading 
segments of the counter.


