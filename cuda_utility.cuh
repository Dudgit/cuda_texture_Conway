#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "step_funcs.h"
#include "cuda_texture_types.h"
#include "texture_fetch_functions.h"
#include "texture_types.h"

dim3 dimBlock(w / block_size, h / block_size);
dim3 dimGrid(block_size, block_size);

__global__ void texture_c(int* output, cudaTextureObject_t texobj)
{
	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;
	
	int sum = tex2D<int>(texobj, x - 1, y - 1) + tex2D<int>(texobj, x, y - 1) + tex2D<int>(texobj, x + 1, y - 1)
		+ tex2D<int>(texobj, x - 1, y) + tex2D<int>(texobj, x + 1, y)
		+ tex2D<int>(texobj, x - 1, y + 1) + tex2D<int>(texobj, x, y + 1) + tex2D<int>(texobj, x + 1, y + 1);

	int isalive = tex2D<int>(texobj, x, y);

	int res = 0;
	if (sum == 3 || isalive && sum == 2) res = 1;
	//if () res = 1;

	output[y * h + x] = res;
}




void run_kernel(int* output, cudaTextureObject_t& texObj, int* hOutput, int h, int w)
{
	texture_c <<< dimGrid, dimBlock >>> (output, texObj);

	auto err = cudaMemcpy(hOutput, output, w * h * sizeof(int), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) { std::cout << "Error copying memory to host: " << cudaGetErrorString(err) << "\n"; }

}

void step(int* h_array,int* device_output,cudaTextureObject_t texObj,cudaArray* cuArray)
{
	
	run_kernel(device_output, texObj, h_array, h, w);

	// The texture memory is binded with the cuda array
	auto err = cudaMemcpyToArray(cuArray, 0, 0, h_array, w * h * sizeof(int), cudaMemcpyHostToDevice);
	if (err != cudaSuccess) { std::cout << "Error copying memory to device: " << cudaGetErrorString(err) << "\n"; }

}


int error_check(cudaError_t const& err, std::string const& err_s)
{
	if (err != cudaSuccess)
	{
		std::cout << "Error in " << err_s << " :" << cudaGetErrorString(err) << std::endl;
	}
	return -1;
}