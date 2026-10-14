//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry main
//DIAGNOSTIC_TEST:SIMPLE(diag=VALUE): -target metal -entry valueMain

// SV_MetalThreadgroup accepts a read-write GroupShared pointer to any type, but rejects a
// pointer to another address space or a non-pointer type.

[shader("tile")]
[numthreads(1, 1, 1)]
void main(uint* data : SV_MetalThreadgroup0)
//CHECK:        ^^^^ error E30701
{
    data[0] = 1;
}

[shader("tile")]
[numthreads(1, 1, 1)]
void valueMain(uint data : SV_MetalThreadgroup0)
//VALUE:            ^^^^ error E30701
{
}
