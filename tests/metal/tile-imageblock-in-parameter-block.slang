//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry tileMain

// A Metal argument buffer cannot hold an imageblock, so a ParameterBlock cannot
// contain a MetalImageBlock, even nested in a struct.

struct Pixel
{
    float4 color : SV_Target0;
};

struct TileParams
{
    MetalImageBlock<Pixel> imageBlock;
    float scale;
};

ParameterBlock<TileParams> gTile;
//CHECK:                   ^^^^^ error E56115
//CHECK:                   ^^^^^ cannot be placed inside a ParameterBlock

[shader("tile")]
[numthreads(8, 8, 1)]
void tileMain(uint2 tid : SV_GroupThreadID)
{
    Pixel pixel = gTile.imageBlock.read(tid);
    pixel.color *= gTile.scale;
    gTile.imageBlock.write(pixel, tid);
}
