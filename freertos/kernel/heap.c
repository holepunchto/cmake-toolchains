#include <stdlib.h>

#include <FreeRTOS.h>

// The kernel allocates from the heap of picolibc, whose locks are FreeRTOS
// mutexes. Unlike `heap_3.c`, this doesn't suspend the scheduler, which would
// keep a task that holds the lock of the heap from ever releasing it.
void *
pvPortMalloc(size_t size) {
  void *ptr = malloc(size);

#if configUSE_MALLOC_FAILED_HOOK
  if (ptr == NULL) {
    extern void vApplicationMallocFailedHook(void);

    vApplicationMallocFailedHook();
  }
#endif

  return ptr;
}

void
vPortFree(void *ptr) {
  free(ptr);
}
