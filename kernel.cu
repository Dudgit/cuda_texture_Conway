
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "step_funcs.h"
#include "cuda_texture_types.h"
#include "texture_fetch_functions.h"
#include "texture_types.h"

texture<float, 1, cudaReadModeElementType> texInput;


__global__ void texture_c(float* output, cudaTextureObject_t texobj)
{
	/*
	Inputnak próbálkoztam int1 típussal is valamint int array-el, ugyan az a végeredmény
	*/
	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x; // vízszintes sorok
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y; // függõleges sorok

	output[y * h + x] = tex2D<float>(texobj, x, y-1);
	
}

int main()
{
	// Creating the Vectors
	std::vector<bool> bools(w * h);
	initializer(bools);

	std::vector<float> int_vector(w * h);
	//std::vector<float> output(h * w);
	initializer(int_vector);

	float* hInput = (float*)malloc(sizeof(float) *	h*w);
	float* hOutput = (float*)malloc(sizeof(float) * h*w);
	for (int i = 0; i < h*w; i++)
	{
		hInput[i] = int_vector[i];
	}


	float* dInput = NULL, * dOutput = NULL;

	size_t offset = 0;



	cudaChannelFormatDesc channelDesc =
		cudaCreateChannelDesc(32, 0, 0, 0,
			cudaChannelFormatKindFloat);
	cudaArray* cuArray;
	cudaMallocArray(&cuArray, &channelDesc, w, h);

	auto err = cudaMemcpyToArray(cuArray, 0, 0, hInput, w * h * sizeof(float), cudaMemcpyHostToDevice);
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


	float* output;
	cudaMalloc(&output, w * h * sizeof(float));

	dim3 dimBlock(w / block_size, h / block_size);
	dim3 dimGrid(block_size, block_size);
	texture_c <<< dimGrid,dimBlock >> > (output, texObj);

	
	//std::cout << "Succes rages on" << std::endl;
	err = cudaMemcpy(hOutput, output, w * h * sizeof(float), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) { std::cout << "Error copying memory to host: " << cudaGetErrorString(err) << "\n"; return -1; }
	
	for (int x = 0; x < h; ++x)
	{
		for (int y = 0; y < w; ++y)
		{
			std::cout << int_vector[x * h + y]<<' ';
		}
		std::cout << std::endl;
	}
	
	for (int i = 0; i < h * w; ++i)
	{
		std::cout << hOutput[i] <<  std::endl;
	}
}