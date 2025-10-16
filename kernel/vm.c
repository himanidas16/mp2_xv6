#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"

#include "sleeplock.h"   
#include "file.h"        
/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S
int handle_write_fault(pagetable_t, uint64);//llm generated 


// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Initialize the kernel_pagetable, shared by all CPUs.
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));

  // flush stale entries from the TLB.
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    panic("mappages: size not aligned");

  if(size == 0)
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
      continue;   
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}

// Allocate PTEs and physical memory to grow a process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
      kfree(mem);
      goto err;
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.

/* ############## LLM Generated Code Begins ############## */
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    if(va0 >= MAXVA)
      return -1;
  
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }

    pte = walk(pagetable, va0, 0);
    
    // If page is read-only but should be writable (user page), handle write fault
    if((*pte & PTE_W) == 0) {
      if((*pte & PTE_U) != 0) {
        // User page that's read-only - try to upgrade it
        if(handle_write_fault(pagetable, va0) < 0) {
          return -1;  // Can't write to this page
        }
        // Refresh pte after potential upgrade
        pte = walk(pagetable, va0, 0);
      } else {
        // Kernel page or text page - truly read-only
        return -1;
      }
    }
      
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}



// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}
/* ############## LLM Generated Code Ends ################ */


// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}

// // allocate and map user memory if process is referencing a page
// // that was lazily allocated in sys_sbrk().
// // returns 0 if va is invalid or already mapped, or if
// // out of physical memory, and physical address if successful.
// uint64
// vmfault(pagetable_t pagetable, uint64 va, int read)
// {
//   uint64 mem;
//   struct proc *p = myproc();

//   if (va >= p->sz)
//     return 0;
//   va = PGROUNDDOWN(va);
//   if(ismapped(pagetable, va)) {
//     return 0;
//   }
//   mem = (uint64) kalloc();
//   if(mem == 0)
//     return 0;
//   memset((void *) mem, 0, PGSIZE);
//   if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
//     kfree((void *)mem);
//     return 0;
//   }
//   return mem;
// }

/* ############## LLM Generated Code Ends ################ */
int
ismapped(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);
  if (pte == 0) {
    return 0;
  }
  if (*pte & PTE_V){
    return 1;
  }
  return 0;
}



//changes 
// Add a page to the resident set
void add_resident_page(struct proc *p, uint64 va, int seq) {
  if(p->num_resident < MAX_RESIDENT_PAGES) {
    p->resident_pages[p->num_resident].va = va;
    p->resident_pages[p->num_resident].seq = seq;
    p->resident_pages[p->num_resident].is_dirty = 0;
    p->resident_pages[p->num_resident].last_used_seq = seq;  // ADD THIS LINE
    p->num_resident++;
  }
}

// Find and evict the oldest resident page using FIFO
// Returns the physical address of the freed page
char* evict_page_fifo(struct proc *p, pagetable_t pagetable) {
  if(p->num_resident == 0)
    return 0;
  
  // Find victim with lowest sequence number (oldest)
  int victim_idx = 0;
  int min_seq = p->resident_pages[0].seq;
  
  for(int i = 1; i < p->num_resident; i++) {
    if(p->resident_pages[i].seq < min_seq) {
      min_seq = p->resident_pages[i].seq;
      victim_idx = i;
    }
  }
  
  uint64 victim_va = p->resident_pages[victim_idx].va;
  int victim_seq = p->resident_pages[victim_idx].seq;
  int is_dirty = p->resident_pages[victim_idx].is_dirty;
  
  // Log victim selection
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=FIFO\n", p->pid, victim_va, victim_seq);
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
  
  // Get physical address before unmapping
  uint64 pa = walkaddr(pagetable, victim_va);
  
  if(is_dirty) {
    // DIRTY PAGE - Write to swap file
    
    // Find a free swap slot
    int slot = -1;
    for(int i = 0; i < 1024; i++) {
      if(p->swap_slots[i] == 0) {
        slot = i;
        break;
      }
    }
    
    if(slot == -1) {
      printf("[pid %d] SWAPFULL\n", p->pid);
      printf("[pid %d] KILL swap-exhausted\n", p->pid);
      setkilled(p);
      return 0;
    }
    
    if(p->swapfile) {
      p->swapfile->off = slot * PGSIZE;
      int written = filewrite(p->swapfile, pa, PGSIZE);
      if(written != PGSIZE) {
        printf("[pid %d] ERROR: swap write failed\n", p->pid);
        setkilled(p);
        return 0;
      }
      
      p->swap_slots[slot] = 1;
      p->num_swap_slots_used++;
      
      // NEW - ADD SWAPPED PAGE TO TRACKING LIST
      if(p->num_swapped < MAX_RESIDENT_PAGES) {
        p->swapped_pages[p->num_swapped].va = victim_va;
        p->swapped_pages[p->num_swapped].swap_slot = slot;
        p->num_swapped++;
      }
      
      printf("[pid %d] SWAPOUT va=0x%lx slot=%d\n", p->pid, victim_va, slot);
    } else {
      printf("[pid %d] ERROR: no swap file\n", p->pid);
      setkilled(p);
      return 0;
    }
  } else {
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim_va);
  }
  
  // Unmap the page
  uvmunmap(pagetable, victim_va, 1, 0);  // Don't free yet
  
  // Remove from resident set by shifting array
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    p->resident_pages[i] = p->resident_pages[i + 1];
  }
  p->num_resident--;
  
  return (char*)pa;
}
// LRU-based page replacement
char* evict_page_lru(struct proc *p, pagetable_t pagetable) {
  if(p->num_resident == 0)
    return 0;
  
  // Find victim with lowest last_used_seq (least recently used)
  int victim_idx = 0;
  int min_last_used = p->resident_pages[0].last_used_seq;
  
  for(int i = 1; i < p->num_resident; i++) {
    if(p->resident_pages[i].last_used_seq < min_last_used) {
      min_last_used = p->resident_pages[i].last_used_seq;
      victim_idx = i;
    }
  }
  
  uint64 victim_va = p->resident_pages[victim_idx].va;
  int victim_seq = p->resident_pages[victim_idx].seq;
  int is_dirty = p->resident_pages[victim_idx].is_dirty;
  
  // Log victim selection with algo=LRU
  printf("[pid %d] VICTIM va=0x%lx seq=%d algo=LRU\n", p->pid, victim_va, victim_seq);
  printf("[pid %d] EVICT va=0x%lx state=%s\n", p->pid, victim_va, is_dirty ? "dirty" : "clean");
  
  uint64 pa = walkaddr(pagetable, victim_va);
  
  if(is_dirty) {
    // DIRTY PAGE - Write to swap file
    int slot = -1;
    for(int i = 0; i < 1024; i++) {
      if(p->swap_slots[i] == 0) {
        slot = i;
        break;
      }
    }
    
    if(slot == -1) {
      printf("[pid %d] SWAPFULL\n", p->pid);
      printf("[pid %d] KILL swap-exhausted\n", p->pid);
      setkilled(p);
      return 0;
    }
    
    if(p->swapfile) {
      p->swapfile->off = slot * PGSIZE;
      int written = filewrite(p->swapfile, pa, PGSIZE);
      if(written != PGSIZE) {
        printf("[pid %d] ERROR: swap write failed\n", p->pid);
        setkilled(p);
        return 0;
      }
      
      p->swap_slots[slot] = 1;
      p->num_swap_slots_used++;
      
      if(p->num_swapped < MAX_RESIDENT_PAGES) {
        p->swapped_pages[p->num_swapped].va = victim_va;
        p->swapped_pages[p->num_swapped].swap_slot = slot;
        p->num_swapped++;
      }
      
      printf("[pid %d] SWAPOUT va=0x%lx slot=%d\n", p->pid, victim_va, slot);
    } else {
      printf("[pid %d] ERROR: no swap file\n", p->pid);
      setkilled(p);
      return 0;
    }
  } else {
    // CLEAN PAGE - Just discard
    printf("[pid %d] DISCARD va=0x%lx\n", p->pid, victim_va);
  }
  
  uvmunmap(pagetable, victim_va, 1, 0);
  
  for(int i = victim_idx; i < p->num_resident - 1; i++) {
    p->resident_pages[i] = p->resident_pages[i + 1];
  }
  p->num_resident--;
  
  return (char*)pa;
}
// Check if a virtual address has been swapped out
// Returns swap slot number if found, -1 if not swapped
int find_swapped_page(struct proc *p, uint64 va) {
  uint64 page_va = PGROUNDDOWN(va);
  for(int i = 0; i < p->num_swapped; i++) {
    if(p->swapped_pages[i].va == page_va) {
      return p->swapped_pages[i].swap_slot;
    }
  }
  return -1;
}

// Remove a page from the swapped list
void remove_swapped_page(struct proc *p, uint64 va) {
  uint64 page_va = PGROUNDDOWN(va);
  for(int i = 0; i < p->num_swapped; i++) {
    if(p->swapped_pages[i].va == page_va) {
      // Shift remaining entries
      for(int j = i; j < p->num_swapped - 1; j++) {
        p->swapped_pages[j] = p->swapped_pages[j + 1];
      }
      p->num_swapped--;
      return;
    }
  }
}
// Handle write to read-only page (mark dirty and upgrade permissions)
int handle_write_fault(pagetable_t pagetable, uint64 va) {
  struct proc *p = myproc();
  uint64 page_va = PGROUNDDOWN(va);
  
  pte_t *pte = walk(pagetable, page_va, 0);
  if(pte == 0 || (*pte & PTE_V) == 0) {
    return -1;
  }
  
  if((*pte & PTE_W) == 0 && (*pte & PTE_U) != 0) {
    // Mark it dirty in our resident set
    for(int i = 0; i < p->num_resident; i++) {
      if(p->resident_pages[i].va == page_va) {
        p->resident_pages[i].is_dirty = 1;
        p->resident_pages[i].last_used_seq = p->next_fifo_seq;  // ADD THIS LINE
        p->next_fifo_seq++;  // ADD THIS LINE
        break;
      }
    }
    
    *pte |= PTE_W;
    return 0;
  }
  
  return -1;
}


uint64
vmfault(pagetable_t pagetable, uint64 va, int is_write)
{
  struct proc *p = myproc();
  char *mem;
  uint64 page_va = PGROUNDDOWN(va);
  
  // printf("[DEBUG] vmfault: va=0x%lx, p->sz=0x%lx, stack_range=[0x%lx,0x%lx)\n", 
  //        va, p->sz, p->sz - USERSTACK*PGSIZE, p->sz);
  
  // NEW - CHECK IF PAGE WAS SWAPPED OUT (ADD THIS FIRST)
  int swap_slot = find_swapped_page(p, va);
  if(swap_slot >= 0) {
    // Page is in swap - reload it
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=swap\n", 
            p->pid, page_va, is_write ? "write" : "read");
    
    // Allocate memory for the page
    if((mem = kalloc()) == 0) {
  printf("[pid %d] MEMFULL\n", p->pid);
#if USE_LRU
  mem = evict_page_lru(p, pagetable);
#else
  mem = evict_page_fifo(p, pagetable);
#endif
  if(mem == 0) {
    return -1;
  }
}
    
    // Read page from swap file
    if(p->swapfile) {
      p->swapfile->off = swap_slot * PGSIZE;
      int bytes_read = fileread(p->swapfile, (uint64)mem, PGSIZE);
      if(bytes_read != PGSIZE) {
        printf("[pid %d] ERROR: swap read failed\n", p->pid);
        kfree(mem);
        return -1;
      }
    } else {
      printf("[pid %d] ERROR: no swap file\n", p->pid);
      kfree(mem);
      return -1;
    }
    
    // Free the swap slot
    p->swap_slots[swap_slot] = 0;
    p->num_swap_slots_used--;
    
    // Remove from swapped list
    remove_swapped_page(p, page_va);
    
    printf("[pid %d] SWAPIN va=0x%lx slot=%d\n", p->pid, page_va, swap_slot);
    
    // Map the page
    // Map the page as READ-ONLY initially (will upgrade on first write)
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    add_resident_page(p, page_va, p->next_fifo_seq);
    p->next_fifo_seq++;
    
    if(p->next_fifo_seq >= 1000000) {
      for(int i = 0; i < p->num_resident; i++) {
        p->resident_pages[i].seq = i;
      }
      p->next_fifo_seq = p->num_resident;
    }
    
    return (uint64)mem;
  }
  
  // Check if address is valid - CHECK STACK FIRST
  if(va >= p->sz - USERSTACK*PGSIZE && va < p->sz) {
    // Stack - allocate zero-filled page  
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=stack\n", 
            p->pid, page_va, is_write ? "write" : "read");
    
   if((mem = kalloc()) == 0) {
  printf("[pid %d] MEMFULL\n", p->pid);
#if USE_LRU
  mem = evict_page_lru(p, pagetable);
#else
  mem = evict_page_fifo(p, pagetable);
#endif
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);
    
    // Map the page
   // Map the page as READ-ONLY initially (will upgrade on first write)
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    add_resident_page(p, page_va, p->next_fifo_seq);
    p->next_fifo_seq++;
    
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
  for(int i = 0; i < p->num_resident; i++) {
    p->resident_pages[i].seq = i;
  }
  p->next_fifo_seq = p->num_resident;
}

    return (uint64)mem;
  }
  else if(va >= p->text_start && va < p->text_end) {
    // Text segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
            p->pid, page_va, is_write ? "write" : "read");
    
  if((mem = kalloc()) == 0) {
  printf("[pid %d] MEMFULL\n", p->pid);
#if USE_LRU
  mem = evict_page_lru(p, pagetable);
#else
  mem = evict_page_fifo(p, pagetable);
#endif
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);  // Zero-fill first
    
    // Load actual program content from executable file
    if(p->exec_inode && p->text_file_size > 0) {
      uint64 page_offset_in_segment = page_va - p->text_start;
      uint64 file_offset = p->text_file_offset + page_offset_in_segment;
      uint64 bytes_to_read = PGSIZE;
      
      // Don't read beyond the segment
      if(page_offset_in_segment + PGSIZE > p->text_file_size) {
        bytes_to_read = p->text_file_size - page_offset_in_segment;
      }
      
      // Read from executable file into the page
      ilock(p->exec_inode);
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
      iunlock(p->exec_inode);
    }
    
    // Map the page
    if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_X | PTE_U) < 0) {
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    add_resident_page(p, page_va, p->next_fifo_seq);
    p->next_fifo_seq++;
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
  for(int i = 0; i < p->num_resident; i++) {
    p->resident_pages[i].seq = i;
  }
  p->next_fifo_seq = p->num_resident;
}
    return (uint64)mem;
  }
  else if(va >= p->data_start && va < p->data_end) {
    // Data segment - allocate and load from executable
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=exec\n", 
            p->pid, page_va, is_write ? "write" : "read");
    
  if((mem = kalloc()) == 0) {
  printf("[pid %d] MEMFULL\n", p->pid);
#if USE_LRU
  mem = evict_page_lru(p, pagetable);
#else
  mem = evict_page_fifo(p, pagetable);
#endif
  if(mem == 0) {
    return -1;
  }
} memset(mem, 0, PGSIZE);  // Zero-fill first
    
    // Load actual program content from executable file
    if(p->exec_inode && p->data_file_size > 0) {
      uint64 page_offset_in_segment = page_va - p->data_start;
      uint64 file_offset = p->data_file_offset + page_offset_in_segment;
      uint64 bytes_to_read = PGSIZE;
      
      // Don't read beyond the segment
      if(page_offset_in_segment + PGSIZE > p->data_file_size) {
        bytes_to_read = p->data_file_size - page_offset_in_segment;
      }
      
      // Read from executable file into the page
      ilock(p->exec_inode);
      readi(p->exec_inode, 0, (uint64)mem, file_offset, bytes_to_read);
      iunlock(p->exec_inode);
    }
    
    // Map the page
   // Map the page as READ-ONLY initially (will upgrade on first write)
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] LOADEXEC va=0x%lx\n", p->pid, page_va);
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    add_resident_page(p, page_va, p->next_fifo_seq);
    p->next_fifo_seq++;
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
  for(int i = 0; i < p->num_resident; i++) {
    p->resident_pages[i].seq = i;
  }
  p->next_fifo_seq = p->num_resident;
}
    return (uint64)mem;
  }
  else if(va >= p->heap_start && va < p->sz - USERSTACK*PGSIZE) {
    // Heap - allocate zero-filled page
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=heap\n", 
            p->pid, page_va, is_write ? "write" : "read");
    
if((mem = kalloc()) == 0) {
  printf("[pid %d] MEMFULL\n", p->pid);
#if USE_LRU
  mem = evict_page_lru(p, pagetable);
#else
  mem = evict_page_fifo(p, pagetable);
#endif
  if(mem == 0) {
    return -1;
  }
}
    memset(mem, 0, PGSIZE);
    
    // Map the page
   // Map the page as READ-ONLY initially (will upgrade on first write)
if(mappages(pagetable, page_va, PGSIZE, (uint64)mem, PTE_R | PTE_U) < 0) {
      kfree(mem);
      return -1;
    }
    
    printf("[pid %d] ALLOC va=0x%lx\n", p->pid, page_va);
    printf("[pid %d] RESIDENT va=0x%lx seq=%d\n", p->pid, page_va, p->next_fifo_seq);
    add_resident_page(p, page_va, p->next_fifo_seq);
    p->next_fifo_seq++;
    // Add wraparound handling here
if(p->next_fifo_seq >= 1000000) {
  for(int i = 0; i < p->num_resident; i++) {
    p->resident_pages[i].seq = i;
  }
  p->next_fifo_seq = p->num_resident;
}
    return (uint64)mem;
  }
  else {
    // Invalid access - kill process
    printf("[pid %d] PAGEFAULT va=0x%lx access=%s cause=invalid\n", 
            p->pid, page_va, is_write ? "write" : "read");
    printf("[pid %d] KILL invalid-access va=0x%lx access=%s\n", 
            p->pid, page_va, is_write ? "write" : "read");
    return -1;
  }
}



/* ############## LLM Generated Code Ends ################ */