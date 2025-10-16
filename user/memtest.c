/* ############## LLM Generated Code Begins ############## */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/memstat.h"

int
main(int argc, char *argv[])
{
  struct proc_mem_stat stat;
  
  if(memstat(&stat) < 0) {
    printf("memstat failed\n");
    exit(1);
  }
  
  printf("Process %d memory statistics:\n", stat.pid);
  printf("  Total pages: %d\n", stat.num_pages_total);
  printf("  Resident pages: %d\n", stat.num_resident_pages);
  printf("  Swapped pages: %d\n", stat.num_swapped_pages);
  printf("  Next FIFO seq: %d\n", stat.next_fifo_seq);
  
  printf("\nFirst 10 pages:\n");
  for(int i = 0; i < 10 && i < stat.num_pages_total; i++) {
    printf("  va=0x%x state=%s", 
           stat.pages[i].va,
           stat.pages[i].state == UNMAPPED ? "UNMAPPED" :
           stat.pages[i].state == RESIDENT ? "RESIDENT" : "SWAPPED");
    
    if(stat.pages[i].state == RESIDENT) {
      printf(" seq=%d dirty=%d", stat.pages[i].seq, stat.pages[i].is_dirty);
    } else if(stat.pages[i].state == SWAPPED) {
      printf(" slot=%d", stat.pages[i].swap_slot);
    }
    printf("\n");
  }
  
  exit(0);
}

// ############## LLM Generated Code Ends ################ */