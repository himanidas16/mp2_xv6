#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "memstat.h"


uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}
/* ############## LLM Generated Code Begins ############## */
uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}
/* ############## LLM Generated Code ends ############## */
uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

/* ############## LLM Generated Code Begins ############## */
uint64
sys_memstat(void)
{
  uint64 addr;
  struct proc *p = myproc();
  struct proc_mem_stat stat;
  
  // Get user address where to store results
  argaddr(0, &addr);
  
  // Fill in basic info
  stat.pid = p->pid;
  stat.num_resident_pages = p->num_resident;
  stat.num_swapped_pages = p->num_swapped;
  stat.next_fifo_seq = p->next_fifo_seq;
  
  // Calculate total pages (from 0 to p->sz)
  stat.num_pages_total = PGROUNDUP(p->sz) / PGSIZE;
  
  // Limit to MAX_PAGES_INFO
  int num_to_report = stat.num_pages_total;
  if(num_to_report > MAX_PAGES_INFO)
    num_to_report = MAX_PAGES_INFO;
  
  // Fill in page information
  for(int i = 0; i < num_to_report; i++) {
    uint64 va = i * PGSIZE;
    stat.pages[i].va = va;
    stat.pages[i].state = UNMAPPED;
    stat.pages[i].is_dirty = 0;
    stat.pages[i].seq = -1;
    stat.pages[i].swap_slot = -1;
    
    // Check if page is resident
    int found_resident = 0;
    for(int j = 0; j < p->num_resident; j++) {
      if(p->resident_pages[j].va == va) {
        stat.pages[i].state = RESIDENT;
        stat.pages[i].is_dirty = p->resident_pages[j].is_dirty;
        stat.pages[i].seq = p->resident_pages[j].seq;
        found_resident = 1;
        break;
      }
    }
    
    // If not resident, check if swapped
    if(!found_resident) {
      for(int j = 0; j < p->num_swapped; j++) {
        if(p->swapped_pages[j].va == va) {
          stat.pages[i].state = SWAPPED;
          stat.pages[i].swap_slot = p->swapped_pages[j].swap_slot;
          break;
        }
      }
    }
  }
  
  // Copy result to user space
  if(copyout(p->pagetable, addr, (char*)&stat, sizeof(stat)) < 0)
    return -1;
  
  return 0;
}

/* ############## LLM Generated Code ends ############## */