#ifndef _FILTER_HPP_
#define _FILTER_HPP_

#include <systemc>
#include "filter_ifs.hpp"
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <cstdio>
#include <string.h>
#include <stdexcept>

using namespace std;

const sc_dt::uint64 FILTER_DIN = 0;
const sc_dt::uint64 FILTER_CSR = 16;
const sc_dt::uint64 FILTER_COEFF = 18;

class filter : public sc_core::sc_channel, public filter_write_if, public filter_read_if
{
public:
    SC_HAS_PROCESS(filter);
    filter(sc_core::sc_module_name);
    tlm_utils::simple_target_socket<filter> filter_tsoc;

    void write(const Data &data);
    void read(Data &data, int i);

    void filter_function(const vector<unsigned char> &din, vector<unsigned char> &dout, vector<double> coef);
    // void filter_function(const unsigned char &din, unsigned char &dout, unsigned char coef);

protected:
    vector<unsigned char> din;
    vector<unsigned char> dout;
    vector<double> coef;

    sc_dt::sc_uint<16> cnt = 0;
    sc_dt::sc_uint<2> ctrl = 0;
    typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
    void b_transport(pl_t &, sc_core::sc_time &);
};

#endif