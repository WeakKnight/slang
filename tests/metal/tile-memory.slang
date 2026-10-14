//TEST:SIMPLE(filecheck=METAL): -target metal -entry tileMain
//TEST:SIMPLE(filecheck=METALLIB): -target metallib -entry tileMain

// SV_MetalThreadgroup exposes persistent tile memory as a threadgroup pointer, and
// loads, stores and atomics through it keep the threadgroup address space.

[shader("tile")]
[numthreads(16, 16, 1)]
void tileMain(
    Ptr<uint, Access.ReadWrite, AddressSpace.GroupShared> data : SV_MetalThreadgroup0,
    uint index : SV_GroupIndex,
    uint3 tile : SV_GroupID)
{
    if (index == 0)
        data[0] = tile.x;
    GroupMemoryBarrierWithGroupSync();
    InterlockedAdd(data[0], 1);
}

// METAL: uint threadgroup* {{.*}} {{\[\[}}threadgroup(0){{\]\]}}
// METALLIB: @tileMain
