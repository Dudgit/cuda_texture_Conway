
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "step_funcs.h"
#include "cuda_texture_types.h"
#include "texture_fetch_functions.h"
#include "texture_types.h"




__global__ void texture_c(int* output, cudaTextureObject_t input)
{
	/*
	Inputnak próbálkoztam int1 típussal is valamint int array-el, ugyan az a végeredmény
	*/
	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;
	output[y * h + x] = tex2D<int>(input, x, y);
}

int main()
{
	// Creating the Vectors
	std::vector<bool> bools(w*h); 
	initializer(bools);

	std::vector<int> int_vector(w*h);
	std::vector<int> output(h*w);
	initializer(int_vector);


	//Habár itt integereket használok, ha átírom a Floatot nem mûködik
	cudaChannelFormatDesc channelDescInput = cudaCreateChannelDesc(32, 0, 0, 0, cudaChannelFormatKindFloat);
	cudaArray* aInput;

	cudaError_t err = cudaMallocArray(&aInput, &channelDescInput, w, h);
	if (err != cudaSuccess) { std::cout << "Error allocating Cuda memory: " << cudaGetErrorString(err) << '\n'; return -1; }
	
	
	err = cudaMemcpyToArray(aInput, 0, 0, int_vector.data(), w * h * sizeof(int), cudaMemcpyHostToDevice);
	if (err != cudaSuccess) { std::cout << "Error copying memory to device: " << cudaGetErrorString(err) << '\n'; return -1; }
	
	cudaResourceDesc resdescInput{};
	resdescInput.resType = cudaResourceTypeArray;
	resdescInput.res.array.array = aInput;

	cudaTextureDesc texD{};
	texD.addressMode[0] = cudaAddressModeBorder;
	texD.addressMode[1] = cudaAddressModeBorder;
	texD.filterMode = cudaFilterModeLinear;
	texD.readMode = cudaReadModeElementType;
	texD.normalizedCoords = 0;


	cudaTextureObject_t t_handler = 0;
	err = cudaCreateTextureObject(&t_handler, &resdescInput, &texD, nullptr);
	if (err != cudaSuccess) { std::cout << "Error creating texture object : " << cudaGetErrorString(err) << '\n'; return -1; }


	int* c_output;
	//int* c_output = new int[h*w];
	err = cudaMalloc((void**)&c_output, w * h * sizeof(int));
	if (err != cudaSuccess) { std::cout << "Error allocating CUDA memory: " << cudaGetErrorString(err) << '\n'; return -1; }
	


	dim3 dimGrid(w / block_size, h / block_size);
	dim3 dimBlock(block_size, block_size);

	texture_c <<< dimGrid,  dimBlock>>> (c_output, t_handler);

	//std::cout << "Succes rages on" << std::endl;
	err = cudaMemcpy(output.data(),c_output, w * h * sizeof(int), cudaMemcpyDeviceToHost);
	if (err != cudaSuccess) { std::cout << "Error copying memory to host: " << cudaGetErrorString(err) << "\n"; return -1; }
	for (auto e:output)
	{
		  std::cout << e << std::endl; 
	}

	/*
	table f_table(w,h,bs);
	f_table.write_table_out();
	std::cout << std::endl;
	step(f_table);
	f_table.write_table_out();
	*/
}	
