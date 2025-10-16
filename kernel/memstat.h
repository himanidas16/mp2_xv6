// memstat.h - Memory statistics structures
/* ############## LLM Generated Code Begins ############## */
#include "types.h"
#define MAX_PAGES_INFO 128

// Page states
#define UNMAPPED 0
#define RESIDENT 1
#define SWAPPED  2

struct page_stat {
  uint va;       // Virtual address
  int state;     // UNMAPPED, RESIDENT, or SWAPPED
  int is_dirty;  // 1 if dirty, 0 if clean
  int seq;       // FIFO sequence number (-1 if not resident)
  int swap_slot; // Swap slot number (-1 if not swapped)
};

struct proc_mem_stat {
  int pid;
  int num_pages_total;
  int num_resident_pages;
  int num_swapped_pages;
  int next_fifo_seq;
  struct page_stat pages[MAX_PAGES_INFO];
};
/* ############## LLM Generated Code Ends ################ */