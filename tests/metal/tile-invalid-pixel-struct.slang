//DIAGNOSTIC_TEST:SIMPLE(diag=CHECK): -target metal -entry main
//DIAGNOSTIC_TEST:SIMPLE(diag=FIELD): -target metal -entry fieldMain

// The element type of a MetalImageBlock must be a struct of color attachments, whether
// the imageblock is an entry-point parameter or a field of a uniform struct.

[shader("tile")]
[numthreads(1, 1, 1)]
void main(MetalImageBlock<float4> image, uint2 tid : SV_GroupThreadID)
//CHECK:                          ^^^^^ error E56111
//CHECK:                          ^^^^^ must be a struct whose fields select color attachments
{
    image.write(image.read(tid), tid);
}

struct TileParams
{
    MetalImageBlock<float4> imageBlock;
//FIELD:                    ^^^^^^^^^^ error E56111
//FIELD:                    ^^^^^^^^^^ must be a struct whose fields select color attachments
    float scale;
};

uniform TileParams gTile;

[shader("tile")]
[numthreads(1, 1, 1)]
void fieldMain(uint2 tid : SV_GroupThreadID)
{
    gTile.imageBlock.write(gTile.imageBlock.read(tid) * gTile.scale, tid);
}
