//DISABLE_TEST(compute):COMPARE_COMPUTE_EX:-cpu -compute 
//DISABLE_TEST(compute):COMPARE_COMPUTE_EX:-slang -compute
//TEST(compute):COMPARE_COMPUTE_EX:-slang -compute -dx12 -use-dxil -profile cs_6_0
//TEST(compute, vulkan):COMPARE_COMPUTE_EX:-vk -compute
//TEST(compute):COMPARE_COMPUTE_EX:-cuda -compute

//TEST_INPUT:ubuffer(data=[0 0 0 0], stride=4):out,name outputBuffer
RWStructuredBuffer<int> outputBuffer;

[numthreads(4, 1, 1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID)
{
    int idx = int(dispatchThreadID.x);
    
    int value = 0;
    
    value |= WaveActiveAllTrue(idx < 4 ) ? 1 : 0;
    value |= WaveActiveAnyTrue(idx == 2) ? 2 : 0;
    value |= WaveActiveAnyTrue(idx == -1) ? 4 : 0;
    value |= WaveActiveAllTrue(idx == 3) ? 8 : 0;
        
    int sum = WaveActiveSum(idx);
    value |= (sum << 4);
    
    // TODO(JS): 
    // This result is unexpected. I expect 1 * 2 * 1 * 2 = 4. But we get 0 on DX (so disable for now). On CUDA I get 4.
    // int product = WaveActiveProduct((idx & 1) + 1);
    /// value |= (product << 8);    
        
    // TODO(JS): NOTE! This only works with uint, *NOT* int on HLSL/DXC. 
    // We need to update the stdlib to reflect this.
    uint xor = WaveActiveBitXor(uint(idx + 1));
    value |= int(xor << 12);
    
    outputBuffer[idx] = value;
}