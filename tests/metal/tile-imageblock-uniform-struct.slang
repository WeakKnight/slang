//TEST:SIMPLE(filecheck=GLOBAL): -target metal -entry globalMain
//TEST:SIMPLE(filecheck=METALLIB): -target metallib -entry globalMain
//TEST:SIMPLE(filecheck=PARAM): -target metal -entry paramMain
//TEST:SIMPLE(filecheck=PARAM_METALLIB): -target metallib -entry paramMain
//TEST:SIMPLE(filecheck=WHOLE): -target metal
//TEST:SIMPLE(filecheck=WHOLE_METALLIB): -target metallib

// A MetalImageBlock is a shader parameter like a texture, so it can be a field of a
// uniform struct, either a global or an entry-point parameter. The imageblock is split
// out of the struct into its own tile function parameter, its pixel struct still selects
// color attachments from its SV_Target semantics even when a fragment shader returns the
// same struct, and non-tile entry points in the module do not receive the imageblock.

struct Pixel
{
    float4 color : SV_Target0;
    float depth : SV_Target1;
};

struct TileParams
{
    MetalImageBlock<Pixel> imageBlock;
    float scale;
};

uniform TileParams gTile;

[shader("fragment")]
Pixel fragmentMain(float4 position : SV_Position)
{
    Pixel pixel;
    pixel.color = float4(gTile.scale, 0.0, 0.0, 1.0);
    pixel.depth = position.z;
    return pixel;
}

void applyScale(inout Pixel pixel, uint2 tid)
{
    pixel = gTile.imageBlock.read(tid);
    pixel.color.rgb *= gTile.scale * pixel.depth;
    gTile.imageBlock.write(pixel, tid);
}

[shader("tile")]
[numthreads(8, 8, 1)]
void globalMain(uint2 tid : SV_GroupThreadID)
{
    Pixel pixel;
    applyScale(pixel, tid);
}

[shader("tile")]
[numthreads(8, 8, 1)]
void paramMain(uniform TileParams tile, uint2 tid : SV_GroupThreadID)
{
    Pixel pixel = tile.imageBlock.read(tid);
    pixel.color.rgb *= tile.scale;
    tile.imageBlock.write(pixel, tid);
}

// GLOBAL: {{\[\[color\(0\)\]\]}}
// GLOBAL: {{\[\[color\(1\)\]\]}}
// GLOBAL: {{\[\[}}kernel{{\]\]}} void globalMain(
// GLOBAL-SAME: imageblock<Pixel{{.*}}, imageblock_layout_implicit> {{.*}}gTile_imageBlock
// METALLIB: define void @globalMain

// PARAM: {{\[\[color\(0\)\]\]}}
// PARAM: {{\[\[color\(1\)\]\]}}
// PARAM: {{\[\[}}kernel{{\]\]}} void paramMain(
// PARAM-SAME: imageblock<Pixel{{.*}}, imageblock_layout_implicit> {{.*}}tile_imageBlock
// PARAM_METALLIB: define void @paramMain

// WHOLE: {{\[\[color\(0\)\]\]}}
// WHOLE: {{\[\[color\(1\)\]\]}}
// WHOLE: {{\[\[}}fragment{{\]\]}} Pixel{{.*}} fragmentMain(float4 {{.*}}, GlobalParams{{.*}} globalParams{{[^)]*}})
// WHOLE: {{\[\[}}kernel{{\]\]}} void globalMain(
// WHOLE-SAME: imageblock<Pixel{{.*}}, imageblock_layout_implicit> {{.*}}gTile_imageBlock
// WHOLE: {{\[\[}}kernel{{\]\]}} void paramMain(
// WHOLE-SAME: imageblock<Pixel{{.*}}, imageblock_layout_implicit> {{.*}}tile_imageBlock
// WHOLE_METALLIB-DAG: define {{.*}} @fragmentMain
// WHOLE_METALLIB-DAG: define void @globalMain
// WHOLE_METALLIB-DAG: define void @paramMain
