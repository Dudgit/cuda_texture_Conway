#include <stdio.h>
#include <random>
#include <algorithm>
#include <fstream>


#include "table.h"
#include "game_varriables.h"

auto initializer(std::vector<bool>& vec)
{
	std::random_device rd{};
	std::mt19937 mersenne_engine{ rd() };  // Generates random integers
	std::uniform_real_distribution<float> dist{ 0, 100 };
	auto gen = [&dist, &mersenne_engine]() { return dist(mersenne_engine) < 50 ? 0 : 1; };
	generate(vec.begin(), vec.end(), gen);
}

auto initializer(float* res)
{
	std::vector<float> vec(h * w);
	std::random_device rd{};
	std::mt19937 mersenne_engine{ rd() };  // Generates random integers
	std::uniform_real_distribution<float> dist{ 0, 100 };
	auto gen = [&dist, &mersenne_engine]() { return dist(mersenne_engine) < 50 ? 0.f : 1.f; };
	generate(vec.begin(), vec.end(), gen);
	for (int i = 0; i < h * w; ++i)
	{
		res[i] = vec[i];
	}
}

auto compute(std::vector<bool>& nt_v, table & ft)
{

	auto e_policy = [&](int pos) {return ft.get_alive(pos) > alive_n ? true : false; };
	for (int i = 0; i < h * w; ++i)
	{
		nt_v[i] = e_policy(i);
	}
}

auto step(table& first_table)
{
	std::vector<bool> new_table(w * h);
	compute(new_table, first_table);
	table next(w, h, new_table);
	first_table = next;
}

void write_out_result(float* res,std::ofstream& handler)
{
	for (int x = 0; x < h; ++x)
	{
		for (int y = 0; y < w; ++y)
		{
			handler << res[x * h + y] << ' ';
		}
		handler << std::endl;
	}
	handler << std::endl;
}
