//TEST:SIMPLE(filecheck=MSL): -target metal -entry reduce
//TEST:SIMPLE(filecheck=AIR): -target metallib -entry reduce

// Quad operations are available in tile shaders, and atomics on persistent tile
// memory lower to threadgroup (local) atomics.

[shader("tile")]
[numthreads(16, 16, 1)]
void reduce(
    Ptr<uint, Access.ReadWrite, AddressSpace.GroupShared> words : SV_MetalThreadgroup0,
    uint index : SV_GroupIndex)
{
    uint value = index;
    value = max(value, QuadReadAcrossX(value));
    value = max(value, QuadReadAcrossY(value));
    if (index == QuadReadLaneAt(index, 0))
        InterlockedMax(words[0], value);
}

// MSL: thread_index_in_quadgroup
// MSL: quad_shuffle
// AIR: @air.quad_shuffle
// AIR: @air.atomic.local.max.u.i32
