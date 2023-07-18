Example Constraints

This is a simple example of using constraints in
register fields, registers and register files.

Register fields can be given constraints to define their legal
values. Fields can be constrained with respect to other fields
in the register. Fields can be constrained with respect to other
registers or register fields in other register files or register maps.

Constraining legal values ensures that the registers and fields
take on only legitimate values.

Constraining fields and registers between each other captures
interesting design specific relationships between registers.
(For example, the value of REGA.field1 must be the same as REGB.field5).

