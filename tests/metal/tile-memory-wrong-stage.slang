//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry main

// Persistent tile memory is only available to tile and fragment entry points.

[shader("compute")]
[numthreads(1, 1, 1)]
void main(
    Ptr<uint, Access.ReadWrite, AddressSpace.GroupShared> data : SV_MetalThreadgroup0)
//CHECK:                                                  ^^^^ error E30702
{
    data[0] = 1;
}
