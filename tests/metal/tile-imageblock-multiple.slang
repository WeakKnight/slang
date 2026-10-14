//TEST:SIMPLE(filecheck=METAL): -target metal -entry tileMain
//TEST:SIMPLE(filecheck=METALLIB): -target metallib -entry tileMain

// Attachment indices come from semantics, not field order. Both helper functions
// and the entry point must use the original specialized pixel struct.

struct Pixel<T>
{
    T second : SV_Target1;
    T first : SV_Target0;
};

Pixel<float4> transform(Pixel<float4> pixel)
{
    pixel.first.rgb = 1.0 - pixel.first.rgb;
    pixel.second.rgb *= 0.5;
    return pixel;
}

[shader("tile")]
[numthreads(8, 8, 1)]
void tileMain(MetalImageBlock<Pixel<float4>> image, uint index : SV_GroupIndex)
{
    uint2 position = uint2(index % 8, index / 8);
    image.write(transform(image.read(position)), position);
}

// METAL: {{\[\[color\(1\)\]\]}}
// METAL: {{\[\[color\(0\)\]\]}}
// METAL: thread_position_in_threadgroup
// METAL: imageblock<
// METAL: .write(
// METALLIB: define void @tileMain
