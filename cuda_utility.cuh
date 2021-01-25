#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "step_funcs.h"
#include "cuda_texture_types.h"
#include "texture_fetch_functions.h"
#include "texture_types.h"

dim3 dimBlock(w / block_size, h / block_size);
dim3 dimGrid(block_size, block_size);

__global__ void texture_c(float* output, cudaTextureObject_t texobj)
{

	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x; // vízszintes sorok
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y; // függõleges sorok

	float s = tex2D<float>(texobj, x - 1, y - 1) + tex2D<float>(texobj, x, y - 1) + tex2D<float>(texobj, x + 1, y - 1)
		+ tex2D<float>(texobj, x - 1, y) + tex2D<float>(texobj, x + 1, y)
		+ tex2D<float>(texobj, x - 1, y + 1) + tex2D<float>(texobj, x, y + 1) + tex2D<float>(texobj, x + 1, y + 1);
	
	int sum = (int)s;
	int isalive = (int) tex2D<float>(texobj, x, y );

	float res = 0;	
	if (sum == 3) res = 1;
	if (isalive && sum == 2) res = 1;
	
	output[y * h + x] = res;
}


cudaTextureObject_t get_texobject(float* hInput)
{
	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc(32, 0, 0, 0, cudaChannelFormatKindFloat);
	cudaArray* cuArray;
	auto err = cudaMallocArray(&cuArray, &channelDesc, w, h);
	if (err != cudaSuccess) { std::cout << "Error allocating memory : " << cudaGetErrorString(err) << "\n"; return -1; }

	 err = cudaMemcpyToArray(cuArray, 0, 0, hInput, w * h * sizeof(float), cudaMemcpyHostToDevice);
	if (err != cudaSuccess) { std::cout << "Error copying memory to device: " << cudaGetErrorString(err) << "\n"; return -1; }

	struct cudaResourceDesc resDesc;
	memset(&resDesc, 0, sizeof(resDesc));
	resDesc.resType = cudaResourceTypeArray;
	resDesc.res.array.array = cuArray;


	struct cudaTextureDesc texDesc;
	memset(&texDesc, 0, sizeof(texDesc));
	texDesc.addressMode[0] = cudaAddressModeWrap;
	texDesc.addressMode[1] = cudaAddressModeWrap;
	texDesc.filterMode = cudaFilterModePoint;
	texDesc.readMode = cudaReadModeElementType;
	texDesc.normalizedCoords = 0;

	cudaTextureObject_t texObj = 0;
	cudaCreateTextureObject(&texObj, &resDesc, &texDesc, NULL);


	err = cudaFreeArray(cuArray);
	if (err != cudaSuccess) { std::cout << "Error freeing array allocation: " << cudaGetErrorString(err) << "\n"; -1; }

	return texObj;

	

}

void run_kernel(float* output, cudaTextureObject_t& texObj,float* hOutput,int h,int w)
{
	texture_c <<< dimGrid, dimBlock >>> (output, texObj);

	auto err = cudaMemcpy(hOutput, output, w * h * sizeof(float), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) { std::cout << "Error copying memory to host: " << cudaGetErrorString(err) << "\n";}

}

