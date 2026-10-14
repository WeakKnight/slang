//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry computeMain

// A MetalImageBlock parameter is rejected on a non-tile stage even when it is unused,
// because Metal would otherwise receive an imageblock on a non-tile function.

struct Pixel
{
    float4 color : SV_Target0;
};

[shader("compute")]
[numthreads(1, 1, 1)]
void computeMain(MetalImageBlock<Pixel> image)
//CHECK:                                ^^^^^ error E56114
//CHECK:                                ^^^^^ cannot belong to an entry point of another stage
{
}
