//DISABLE_TEST(compute):COMPARE_COMPUTE_EX:-cpu -compute 
//DISABLE_TEST(compute):COMPARE_COMPUTE_EX:-slang -compute
//TEST(compute):COMPARE_COMPUTE_EX:-slang -compute -dx12 -use-dxil -profile cs_6_0
//TEST(compute, vulkan):COMPARE_COMPUTE_EX:-vk -compute
//TEST(compute):COMPARE_COMPUTE_EX:-cuda -compute -render-features cuda_sm_7_0

//TEST_INPUT:ubuffer(data=[0 0 0 0], stride=4):out,name outputBuffer
RWStructuredBuffer<int> outputBuffer;

[numthreads(4, 1, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    int idx = int(dispatchThreadID.x);
    
    int value = 0;
    
    // Scalar
    
    value |= WaveActiveAllEqual(idx * 0 + 1)  ? 1 : 0;     // true
    value |= WaveActiveAllEqual(idx & 2)      ? 2 : 0;     // false
   
    // Vector
   
    int2 v0 = int2(idx & 0xf0, (idx & 0xf00) + 1);      // (0, 1)
    int2 v1 = int2(idx & 2, (idx & 2) + 1);
    
    value |= WaveActiveAllEqual(v0)           ? 0x10 : 0;     // true
    value |= WaveActiveAllEqual(v1)           ? 0x20 : 0;     // false
    
    outputBuffer[idx] = value;
}