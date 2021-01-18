#include "cuda_utility.cuh"




int main(int argc,char* argv[])
{

	int number_of_steps = 3;// (int)argv[1];
	float* host_array = new float(h * w);
	initializer(host_array);
	std::ofstream  handler("data/Conway.txt");
	write_out_result(host_array,handler);
	for (int i = 0; i < number_of_steps; ++i)
	{
		step(host_array);
		write_out_result(host_array, handler);
	}
}