//TEST:SIMPLE(filecheck=METAL): -target metal -entry tileMain -stage tile
//TEST:SIMPLE(filecheck=METALLIB): -target metallib -entry tileMain -stage tile
//TEST:REFLECTION(filecheck=REFLECT): -target metal -entry tileMain -stage tile

// A tile shader reads and writes the implicit imageblock of the render pass.

struct TilePixel
{
    float4 color : SV_Target0;
};

[shader("tile")]
[numthreads(8, 8, 1)]
void tileMain(MetalImageBlock<TilePixel> image, uint2 tid : SV_GroupThreadID)
{
    for (uint y = tid.y; y < image.getHeight(); y += 8)
    {
        for (uint x = tid.x; x < image.getWidth(); x += 8)
        {
            uint2 position = uint2(x, y);
            TilePixel pixel = image.read(position);
            pixel.color.rgb = 1.0 - pixel.color.rgb;
            image.write(pixel, position);
        }
    }
}

// METAL: {{\[\[color\(0\)\]\]}}
// METAL: imageblock<TilePixel{{.*}}, imageblock_layout_implicit>
// METAL: .get_height()
// METAL: .get_width()
// METAL: .read(ushort2(
// METAL: .write(
// METALLIB: define void @tileMain
// REFLECT: "stage": "tile"
// REFLECT: "threadGroupSize": [
// REFLECT: 8,
// REFLECT: 8,
// REFLECT: 1
