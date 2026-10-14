//DIAGNOSTIC_TEST:SIMPLE(diag=MAIN, non-exhaustive): -target spirv -entry main
//DIAGNOSTIC_TEST:SIMPLE(diag=EMPTY): -target spirv -entry emptyMain
//DIAGNOSTIC_TEST:SIMPLE(diag=EMPTY): -target hlsl -entry emptyMain

// The tile stage requires Metal, independently of any imageblock operations. The
// diagnostic for `main` also notes the declaration of `write` in the core module, which
// this test does not annotate.

struct Pixel
{
    float4 color : SV_Target0;
};

[shader("tile")]
[numthreads(1, 1, 1)]
void main(MetalImageBlock<Pixel> image, uint2 tid : SV_GroupThreadID)
/*MAIN:
     ^^^^ error E36107
     ^^^^ not available in 'tile' stage for 'spirv' compilation target
*/
{
    image.write(image.read(tid), tid);
/*MAIN:
          ^^^^^ see using of 'write'
*/
}

[shader("tile")]
[numthreads(1, 1, 1)]
void emptyMain()
/*EMPTY:
     ^^^^^^^^^ error E36107
     ^^^^^^^^^ not available in 'tile' stage
     ^^^^^^^^^ see using of 'emptyMain'
     ^^^^^^^^^ see definition of 'emptyMain'
*/
{
}
