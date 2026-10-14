//TEST:SIMPLE(filecheck=METAL): -target metal -entry tileMain
//TEST:SIMPLE(filecheck=METALLIB): -target metallib -entry tileMain

// A tile shader reads individual samples of a multisampled imageblock, here to
// compute a conservative minimum depth.

struct Pixel
{
    float4 lighting : SV_Target0;
    float depth : SV_Target1;
};

RWStructuredBuffer<float> result;

[shader("tile")]
[numthreads(16, 16, 1)]
void tileMain(MetalImageBlock<Pixel> image, uint2 local : SV_GroupThreadID)
{
    float depth = 1;
    for (uint sampleIndex = 0; sampleIndex < image.getSampleCount(); ++sampleIndex)
        depth = min(depth, image.readSample(local, sampleIndex).depth);
    result[local.y * 16 + local.x] = depth;
}

// METAL: float depth{{.*}} {{\[\[color\(1\)\]\]}}
// METAL: .get_num_samples()
// METAL: imageblock_data_rate::sample
// METALLIB: define void @tileMain
