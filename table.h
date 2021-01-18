
#include <vector>
#include <iostream>

class table
{
public:
   table( int w,  int h,std::vector<bool> d) : width(w), height(h), data(d) {}
private:
    int width,height;
    std::vector<bool> data;

    int sum_sides(int position);
    int sum_up(int position);
    int sum_down(int position);

public:
    int get_alive(int position);
    void write_table_out();
};
