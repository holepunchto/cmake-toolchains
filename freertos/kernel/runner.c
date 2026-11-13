#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/lock.h>

#include <FreeRTOS.h>
#include <semphr.h>
#include <task.h>

#ifndef FREERTOS_QEMU_MAIN_STACK_SIZE
#define FREERTOS_QEMU_MAIN_STACK_SIZE (64 * 1024)
#endif

// Executables are linked with `--wrap=main`, so the startup code calls
// `__wrap_main()` and `__real_main()` is the `main()` of the executable, which
// then runs as a task.
int
__real_main(int argc, char *argv[]);

static int freertos_qemu__argc;
static char **freertos_qemu__argv;

static void
freertos_qemu__main(void *data) {
  exit(__real_main(freertos_qemu__argc, freertos_qemu__argv));
}

int
__wrap_main(int argc, char *argv[]) {
#if defined(__riscv)
  extern void freertos_risc_v_trap_handler(void);

  __asm__ volatile("csrw mtvec, %0" ::"r"(freertos_risc_v_trap_handler));
#endif

  freertos_qemu__argc = argc;
  freertos_qemu__argv = argv;

  BaseType_t res = xTaskCreate(
    freertos_qemu__main,
    "main",
    FREERTOS_QEMU_MAIN_STACK_SIZE / sizeof(StackType_t),
    NULL,
    tskIDLE_PRIORITY + 1,
    NULL
  );

  if (res != pdPASS) abort();

  vTaskStartScheduler();

  abort();
}

void
freertos_qemu_assert(const char *file, int line) {
  fprintf(stderr, "%s:%d: FreeRTOS assertion failed\n", file, line);

  abort();
}

void
vApplicationStackOverflowHook(TaskHandle_t task, char *name) {
  fprintf(stderr, "Stack overflow in task '%s'\n", name);

  abort();
}

void
vApplicationMallocFailedHook(void) {
  fprintf(stderr, "Out of memory\n");

  abort();
}

// Retargets the locks of picolibc to FreeRTOS mutexes, created on first use as
// picolibc defines some of its locks statically. Until the scheduler starts,
// there is only one thread of execution and nothing to lock.
struct __lock {
  SemaphoreHandle_t handle;
  StaticSemaphore_t storage;
};

struct __lock __lock___libc_recursive_mutex;

static SemaphoreHandle_t
freertos_qemu__mutex(struct __lock *lock) {
  if (lock->handle == NULL) {
    taskENTER_CRITICAL();

    if (lock->handle == NULL) {
      lock->handle = xSemaphoreCreateRecursiveMutexStatic(&lock->storage);
    }

    taskEXIT_CRITICAL();
  }

  return lock->handle;
}

static inline bool
freertos_qemu__threaded(void) {
  return xTaskGetSchedulerState() != taskSCHEDULER_NOT_STARTED;
}

void
__retarget_lock_init(_LOCK_T *lock) {
  *lock = calloc(1, sizeof(struct __lock));
}

void
__retarget_lock_init_recursive(_LOCK_T *lock) {
  __retarget_lock_init(lock);
}

void
__retarget_lock_close(_LOCK_T lock) {
  if (lock == NULL) return;

  if (lock->handle) vSemaphoreDelete(lock->handle);

  free(lock);
}

void
__retarget_lock_close_recursive(_LOCK_T lock) {
  __retarget_lock_close(lock);
}

void
__retarget_lock_acquire(_LOCK_T lock) {
  if (lock == NULL || !freertos_qemu__threaded()) return;

  xSemaphoreTakeRecursive(freertos_qemu__mutex(lock), portMAX_DELAY);
}

void
__retarget_lock_acquire_recursive(_LOCK_T lock) {
  __retarget_lock_acquire(lock);
}

void
__retarget_lock_release(_LOCK_T lock) {
  if (lock == NULL || !freertos_qemu__threaded()) return;

  xSemaphoreGiveRecursive(freertos_qemu__mutex(lock));
}

void
__retarget_lock_release_recursive(_LOCK_T lock) {
  __retarget_lock_release(lock);
}
