//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry main

// MetalImageBlock fields must have a scalar or vector color attachment type.

struct Nested
{
    float4 color;
};

struct Pixel
{
    Nested color : SV_Target0;
//CHECK:   ^^^^^ error E56113
//CHECK:   ^^^^^ must be a scalar or vector of 'float', 'half', 'int', 'uint'
};

[shader("tile")]
[numthreads(1, 1, 1)]
void main(MetalImageBlock<Pixel> image, uint2 tid : SV_GroupThreadID)
{
    Pixel pixel = image.read(tid);
    image.write(pixel, tid);
}
