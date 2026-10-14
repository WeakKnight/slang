//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target spirv -entry main

// Persistent tile memory is a Metal feature, even on a fragment entry point.

[shader("fragment")]
float4 main(
/*CHECK:
       ^^^^ error E36107
       ^^^^ not available in 'fragment' stage for 'spirv' compilation target
       ^^^^ see using of 'main'
       ^^^^ see definition of 'main'
*/
    Ptr<uint, Access.ReadWrite, AddressSpace.GroupShared> data : SV_MetalThreadgroup0)
    : SV_Target0
{
    return float4(data[0], 0, 0, 1);
}
