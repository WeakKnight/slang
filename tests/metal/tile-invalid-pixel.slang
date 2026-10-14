//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry main

// Every field of a MetalImageBlock element struct selects its color attachment
// with an SV_Target semantic.

struct Pixel
{
    float4 color;
//CHECK:   ^^^^^ error E56112
//CHECK:   ^^^^^ must use an 'SV_Target' semantic
};

[shader("tile")]
[numthreads(1, 1, 1)]
void main(MetalImageBlock<Pixel> image, uint2 tid : SV_GroupThreadID)
{
    Pixel pixel = image.read(tid);
    image.write(pixel, tid);
}
