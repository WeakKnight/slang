//TEST:SIMPLE(filecheck=METAL): -target metal -entry fragmentMain
//TEST:SIMPLE(filecheck=METALLIB): -target metallib -entry fragmentMain

// Fragment functions in a tile render pass can also access persistent tile memory.

[shader("fragment")]
float4 fragmentMain(
    Ptr<uint, Access.ReadWrite, AddressSpace.GroupShared> data : SV_MetalThreadgroup1)
    : SV_Target0
{
    return float4(asfloat(data[0]), 0, 0, 1);
}

// METAL: {{\[\[}}threadgroup(1){{\]\]}}
// METALLIB: @fragmentMain
