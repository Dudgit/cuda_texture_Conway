#include "cuda_utility.cuh"




int main()
{

	int number_of_steps =1000;// (int)argv[1];
	std::vector<float> h1(h * w);
	/*	{
		0,0,0,0,0,0,
		0,0,1,0,0,0,
		1,0,1,0,0,0,
		0,1,1,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0

	};*/
	

	std::random_device rd{};
	std::mt19937 mersenne_engine{ rd() };  // Generates random integers
	std::uniform_real_distribution<float> dist{ 0, 100 };
	auto gen = [&dist, &mersenne_engine]() { return dist(mersenne_engine) < 50 ? 0.f : 1.f; };
	generate(h1.begin(), h1.end(), gen);

	float* host_array = h1.data();
	std::ofstream  handler("data/cw1.csv");

	auto texObj = get_texobject(host_array);
	
	float* device_output;
	cudaMalloc(&device_output, w * h * sizeof(float));



	write_out_result(host_array,handler);
	for (int i = 0; i < number_of_steps; ++i)
	{
		run_kernel(device_output, texObj, host_array, h, w);
		write_out_result(host_array, handler);
	}



	auto err = cudaDestroyTextureObject(texObj);
	if (err != cudaSuccess) { std::cout << "Error destroying texture object: " << cudaGetErrorString(err) << "\n"; return -1; }

	free(host_array);
	free(device_output);
}