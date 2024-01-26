#ifndef _VP_ADDR_HPP_
#define _VP_ADDR_HPP_

#include "generator.hpp"
#include "memory.hpp"
#include "dma.hpp"
#include "filter.hpp"

#include <systemc>

const sc_dt::uint64 VP_ADDR_MEM = 0x10000000;
const sc_dt::uint64 VP_ADDR_MEM_H = VP_ADDR_MEM + DRAM_SIZE;
const sc_dt::uint64 VP_ADDR_GEN = 0x20000000;
const sc_dt::uint64 VP_ADDR_DMA = 0x30000000;
const sc_dt::uint64 VP_ADDR_DMA_CSR = VP_ADDR_DMA + DMA_CSR; // Control and status register
const sc_dt::uint64 VP_ADDR_DMA_SAR = VP_ADDR_DMA + DMA_SAR; // Write Source address register
const sc_dt::uint64 VP_ADDR_DMA_CNT = VP_ADDR_DMA + DMA_CNT; // Write Count register
const sc_dt::uint64 VP_ADDR_DMA_DAR = VP_ADDR_DMA + DMA_DAR; // Destination address register
const sc_dt::uint64 VP_ADDR_DMA_H = 0x40000005;
const sc_dt::uint64 VP_ADDR_FILTER = 0x50000000;
const sc_dt::uint64 VP_ADDR_FILTER_COEFF = VP_ADDR_FILTER + FILTER_COEFF;
const sc_dt::uint64 VP_ADDR_FILTER_CSR = VP_ADDR_FILTER + FILTER_CSR;
const sc_dt::uint64 VP_ADDR_FILTER_H = 0x600000FF;

#endif
