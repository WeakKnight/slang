//TEST:SIMPLE(filecheck=TILE): -target metal -entry tileMain
//TEST:SIMPLE(filecheck=TILE_METALLIB): -target metallib -entry tileMain
//TEST:SIMPLE(filecheck=FRAGMENT): -target metal -entry fragmentMain
//TEST:SIMPLE(filecheck=FRAGMENT_METALLIB): -target metallib -entry fragmentMain

// The pointee type of an SV_MetalThreadgroup pointer describes the layout of the tile
// memory, so a tile function and a fragment function can share a struct through it.

struct TileLights
{
    uint count;
    float2 depthBounds;
    uint indices[64];
};

[shader("tile")]
[numthreads(16, 16, 1)]
void tileMain(
    Ptr<TileLights, Access.ReadWrite, AddressSpace.GroupShared> lights : SV_MetalThreadgroup0,
    uint index : SV_GroupIndex)
{
    if (index == 0)
    {
        lights->count = 0;
        lights->depthBounds = float2(1, 0);
    }
    GroupMemoryBarrierWithGroupSync();
    uint slot;
    InterlockedAdd(lights->count, 1, slot);
    lights->indices[slot % 64] = index;
}

[shader("fragment")]
float4 fragmentMain(
    Ptr<TileLights, Access.ReadWrite, AddressSpace.GroupShared> lights : SV_MetalThreadgroup0)
    : SV_Target0
{
    return float4(float(lights->count), lights->depthBounds, float(lights->indices[0]));
}

// TILE: {{\[\[}}kernel{{\]\]}} void tileMain(
// TILE-SAME: TileLights{{.*}} threadgroup* {{.*}} {{\[\[}}threadgroup(0){{\]\]}}
// TILE_METALLIB: define void @tileMain
// FRAGMENT: {{\[\[}}fragment{{\]\]}} {{.*}} fragmentMain(
// FRAGMENT-SAME: TileLights{{.*}} threadgroup* {{.*}} {{\[\[}}threadgroup(0){{\]\]}}
// FRAGMENT_METALLIB: @fragmentMain
