//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK, non-exhaustive): -target metal -entry main

// MetalImageBlock operations require the tile stage. The diagnostic also notes the
// declaration of `read` in the core module, which this test does not annotate.

struct Pixel
{
    float4 color : SV_Target0;
};

[shader("compute")]
[numthreads(1, 1, 1)]
void main(MetalImageBlock<Pixel> image, uint2 tid : SV_GroupThreadID)
/*CHECK:
     ^^^^ error E36107
     ^^^^ not available in 'compute' stage for 'metal' compilation target
*/
{
    Pixel pixel = image.read(tid);
/*CHECK:
                        ^^^^ see using of 'read'
*/
    image.write(pixel, tid);
}
