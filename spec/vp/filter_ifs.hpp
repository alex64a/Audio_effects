#ifndef _FILTER_IFS_HPP_
#define _FILTER_IFS_HPP_
#include <vector>
using namespace std;

#include <systemc>

typedef struct
{
	unsigned char byte;
	bool last;
} Data;

class filter_write_if : virtual public sc_core::sc_interface
{
public:
	virtual void write(const Data &data) = 0;
};

class filter_read_if : virtual public sc_core::sc_interface
{
public:
	virtual void read(Data &data, int i) = 0;
};

#endif
