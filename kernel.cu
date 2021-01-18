
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "step_funcs.h"
#include "cuda_texture_types.h"
#include "texture_fetch_functions.h"
#include "texture_types.h"

texture<float, 1, cudaReadModeElementType> texInput;


__global__ void texture_c(float* output)
{
	/*
	Inputnak próbálkoztam int1 típussal is valamint int array-el, ugyan az a végeredmény
	*/
	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;
	//output[y * h + x] = tex2D<float>(input, x, y);
	output[y * h + x] = tex1Dfetch<float>(texInput, y * h + x);
	
	
	
}

int main()
{
	// Creating the Vectors
	std::vector<bool> bools(w * h);
	initializer(bools);

	std::vector<float> int_vector(w * h);
	std::vector<float> output(h * w);
	initializer(int_vector);

	float* hInput = (float*)malloc(sizeof(float) *	h*w);
	float* hOutput = (float*)malloc(sizeof(float) * h*w);
	for (int i = 0; i < h*w; i++)
	{
		hInput[i] = int_vector[i];
	}


	float* dInput = NULL, * dOutput = NULL;

	size_t offset = 0;

	texInput.addressMode[0] = cudaAddressModeBorder;
	texInput.addressMode[1] = cudaAddressModeBorder;
	texInput.filterMode = cudaFilterModePoint;
	texInput.normalized = false;


	cudaError_t err = (cudaMalloc((void**)&dInput, sizeof(float) *h*w));
	if (err != cudaSuccess) { std::cout << "Error allocating Cuda memory: " << cudaGetErrorString(err) << '\n'; return -1; }

	err = (cudaMalloc((void**)&dOutput, sizeof(float) * h * w));
	if (err != cudaSuccess) { std::cout << "Error allocating Cuda memory: " << cudaGetErrorString(err) << '\n'; return -1; }

	cudaMemcpy(dInput, hInput, sizeof(float) * h*w, cudaMemcpyHostToDevice);

	cudaBindTexture(&offset, texInput, dInput, sizeof(float) * h*w);



	dim3 dimGrid(w / block_size, h / block_size);
	dim3 dimBlock(block_size, block_size);

	texture_c <<< dimGrid, dimBlock >>> (dOutput);

	//std::cout << "Succes rages on" << std::endl;
	err = cudaMemcpy(hOutput, dOutput, w * h * sizeof(float), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) { std::cout << "Error copying memory to host: " << cudaGetErrorString(err) << "\n"; return -1; }
	for (int i = 0; i < h * w; ++i)
	{
		std::cout << hOutput[i] << " " << int_vector[i] << std::endl;
	}
}