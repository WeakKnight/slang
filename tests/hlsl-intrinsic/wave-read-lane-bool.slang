//TEST_CATEGORY(wave, compute)
//TEST:COMPARE_COMPUTE_EX(filecheck-buffer=CHECK):-wgpu -compute -shaderobj -output-using-type
//TEST:COMPARE_COMPUTE_EX(filecheck-buffer=CHECK):-vk -compute -shaderobj -output-using-type

// WaveReadLaneAt, WaveReadLaneFirst, WaveBroadcastLaneAt and WaveShuffle on bool and bool vectors.
// WGSL's subgroupShuffle, subgroupBroadcastFirst and subgroupBroadcast take no bool, so the WGSL
// lowering reads the values as 0/1.

//TEST_INPUT:ubuffer(data=[0 0 0 0], stride=4):out,name outputBuffer
RWStructuredBuffer<int> outputBuffer;

[numthreads(4, 1, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    int idx = int(dispatchThreadID.x);

    int value = 0;

    value |= WaveReadLaneAt(idx == 2, 2)                            ? 1 : 0;    // true
    value |= WaveReadLaneAt(idx == 2, 3)                            ? 2 : 0;    // false
    bool2 at = WaveReadLaneAt(bool2(idx == 1, idx != 1), 1);                    // (true, false)
    value |= (at.x ? 4 : 0) | (at.y ? 8 : 0);
    value |= WaveReadLaneFirst(idx == 0)                            ? 16 : 0;   // true
    bool2 first = WaveReadLaneFirst(bool2(idx != 0, true));                     // (false, true)
    value |= (first.x ? 32 : 0) | (first.y ? 64 : 0);
    value |= WaveBroadcastLaneAt(idx == 3, 3)                       ? 128 : 0;  // true
    bool2 broadcast = WaveBroadcastLaneAt(bool2(idx == 3, idx == 0), 3);        // (true, false)
    value |= (broadcast.x ? 256 : 0) | (broadcast.y ? 512 : 0);
    value |= WaveShuffle(idx == 1, 1)                               ? 1024 : 0; // true
    bool2 shuffled = WaveShuffle(bool2(idx == 0, idx == 1), 1);                 // (false, true)
    value |= (shuffled.x ? 2048 : 0) | (shuffled.y ? 4096 : 0);

    outputBuffer[idx] = value;
}

// 1 | 4 | 16 | 64 | 128 | 256 | 1024 | 4096 on every lane.
// CHECK: 5589
// CHECK-NEXT: 5589
// CHECK-NEXT: 5589
// CHECK-NEXT: 5589
