#include "dma.hpp"
#include "vp_addr.hpp"

using namespace std;
using namespace sc_core;
using namespace sc_dt;
using namespace tlm;

dma::dma(sc_module_name name) : sc_module(name),
								dma_tsoc("dma_tsoc"),
								dma_isoc("dma_isoc")
{
	dma_tsoc.register_b_transport(this, &dma::b_transport);
}

void dma::dm()
{

	unsigned char buffer[1024] = {};
	tlm_generic_payload pl1;
	sc_time off = SC_ZERO_TIME;

	Data input;

	if (daddr == VP_ADDR_FILTER)
	{
		pl1.set_address(saddr);
		pl1.set_command(TLM_READ_COMMAND);
		pl1.set_data_length(cnt);
		pl1.set_data_ptr(buffer);
		pl1.set_response_status(TLM_INCOMPLETE_RESPONSE);
		dma_isoc->b_transport(pl1, off);

		cout << "**********DMA**********" << endl;
		for (int i = 0; i < 100; i++)
		{
			printf("%d: %d\t", i, buffer[i]);
		}
		cout << endl;

		for (int i = 0; i < cnt; i++)
		{
			if (i == (cnt - 1))
			{
				input.last = true;
			}
			input.byte = buffer[i];
			wr_port->write(input);
			input.last = false;
		}
		ctrl = 0x2;
	}
	else if (daddr == VP_ADDR_MEM)
	{

		for (int i = 0; i < cnt; i++)
		{
			rd_port->read(input, i);
			buffer[i] = input.byte;
		}
		cout << "*******INPUT_DATA in DMA*****" << endl;
		for (int i = 0; i < 16; i++)
		{
			printf("%d: %02d\t", i, buffer[i]);
		}
		cout << endl;
		pl1.set_address(saddr);
		pl1.set_command(TLM_WRITE_COMMAND);
		pl1.set_data_length(cnt);
		pl1.set_data_ptr(buffer);
		pl1.set_response_status(TLM_INCOMPLETE_RESPONSE);
		dma_isoc->b_transport(pl1, off);
		ctrl = 0x2;
	}
}

void dma::b_transport(pl_t &pl, sc_core::sc_time &offset)
{

	tlm_command cmd = pl.get_command();
	uint64 addr = pl.get_address();
	unsigned char *data = pl.get_data_ptr();
	unsigned int length = pl.get_data_length();

	switch (cmd)
	{
	case TLM_WRITE_COMMAND:
		switch (addr)
		{
		case DMA_CSR:
			ctrl = *((sc_uint<4> *)data);
			dm();
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		case DMA_SAR:
			saddr = *((sc_uint<32> *)data);
			cout << "Source address in DMA:" << saddr << endl;
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		case DMA_CNT:
			cnt = *((sc_uint<32> *)data);
			cout << "Count in DMA:" << cnt << endl;
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		case DMA_DAR:
			daddr = *((sc_uint<32> *)data);
			cout << "Destination address in DMA:" << daddr << endl;
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		default:
			pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
			break;
		}
		break;

	case TLM_READ_COMMAND:
		switch (addr)
		{
		case DMA_CSR:
			memcpy(data, &ctrl, sizeof(ctrl));
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		case DMA_SAR:
			memcpy(data, &saddr, sizeof(saddr));
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		case DMA_CNT:
			memcpy(data, &cnt, sizeof(cnt));
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		case DMA_DAR:
			memcpy(data, &saddr, sizeof(daddr));
			pl.set_response_status(TLM_OK_RESPONSE);
			break;
		default:
			pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
			break;
		}
		break;

	default:
		pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
		break;
		offset += sc_time(10, SC_NS);
	}
}
