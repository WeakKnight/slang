//TEST:SIMPLE(filecheck=CHECK): -target metal -entry vertexMain
//TEST:SIMPLE(filecheck=AIR): -target metallib -entry vertexMain
//TEST:SIMPLE(filecheck=WRITE): -target metal -entry computeMain
//TEST:SIMPLE(filecheck=COMPUTE): -target metallib -entry computeMain

// A read-only StructuredBuffer is a `const device*` in Metal, and the element and
// field addresses derived from it stay read-only, so the AIR marks it `air.read`.

struct Vertex
{
    float4 position;
};
StructuredBuffer<Vertex> vertices;
RWStructuredBuffer<float4> output;

[shader("vertex")]
float4 vertexMain(uint id : SV_VertexID) : SV_Position
{
    return vertices[id].position;
}

[shader("compute")]
[numthreads(1, 1, 1)]
void computeMain(uint3 id : SV_DispatchThreadID)
{
    output[id.x] = vertices[id.x].position;
}

// CHECK: const device* vertices
// AIR: @vertexMain
// AIR: !"air.read", !"air.address_space", i32 1
// WRITE: device* output
// COMPUTE: @computeMain
