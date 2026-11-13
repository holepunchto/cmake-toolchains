#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#define configUSE_PREEMPTION                    1
#define configUSE_PORT_OPTIMISED_TASK_SELECTION 0
#define configUSE_TICKLESS_IDLE                 0
#define configTICK_RATE_HZ                      1000
#define configMAX_PRIORITIES                    8
#define configMINIMAL_STACK_SIZE                256
#define configMAX_TASK_NAME_LEN                 16
#define configTICK_TYPE_WIDTH_IN_BITS           TICK_TYPE_WIDTH_32_BITS
#define configIDLE_SHOULD_YIELD                 1
#define configUSE_IDLE_HOOK                     0
#define configUSE_TICK_HOOK                     0

#define configSUPPORT_DYNAMIC_ALLOCATION 1
#define configSUPPORT_STATIC_ALLOCATION  1
#define configKERNEL_PROVIDED_STATIC_MEMORY 1

#define configUSE_MUTEXES             1
#define configUSE_RECURSIVE_MUTEXES   1
#define configUSE_COUNTING_SEMAPHORES 1
#define configUSE_TASK_NOTIFICATIONS  1

#define configUSE_TIMERS             1
#define configTIMER_TASK_PRIORITY    (configMAX_PRIORITIES - 1)
#define configTIMER_QUEUE_LENGTH     8
#define configTIMER_TASK_STACK_DEPTH (2 * configMINIMAL_STACK_SIZE)

#define configNUM_THREAD_LOCAL_STORAGE_POINTERS 4

// Gives every task a `_Thread_local` block of its own.
#define configUSE_PICOLIBC_TLS 1

#define configCHECK_FOR_STACK_OVERFLOW 2
#define configUSE_MALLOC_FAILED_HOOK   1

#define INCLUDE_uxTaskPriorityGet        1
#define INCLUDE_vTaskDelay               1
#define INCLUDE_vTaskDelete              1
#define INCLUDE_vTaskSuspend             1
#define INCLUDE_xTaskGetSchedulerState   1
#define INCLUDE_xTaskGetCurrentTaskHandle 1

#ifndef __ASSEMBLER__
void
freertos_qemu_assert(const char *file, int line);
#endif

#define configASSERT(x) \
  if (!(x)) freertos_qemu_assert(__FILE__, __LINE__)

#if defined(__riscv)

// The CLINT of the `virt` machine, whose timer runs at 10 MHz.
#define configCPU_CLOCK_HZ          10000000
#define configMTIME_BASE_ADDRESS    0x0200bff8
#define configMTIMECMP_BASE_ADDRESS 0x02004000
#define configISR_STACK_SIZE_WORDS  1024

#elif defined(__arm__)

// The `mps2-an505` machine runs its Cortex-M33 at 20 MHz, in the secure state
// only.
#define configCPU_CLOCK_HZ             20000000
#define configENABLE_TRUSTZONE         0
#define configRUN_FREERTOS_SECURE_ONLY 1
#define configENABLE_MPU               0
#define configENABLE_FPU               1
#define configENABLE_MVE               0

#define configPRIO_BITS                      3
#define configKERNEL_INTERRUPT_PRIORITY      255
#define configMAX_SYSCALL_INTERRUPT_PRIORITY (5 << (8 - configPRIO_BITS))

// The vector table of picolibc names the handlers of the port differently.
#define SVC_Handler     arm_svc_isr
#define PendSV_Handler  arm_pendsv_isr
#define SysTick_Handler arm_systick_isr

#endif

#endif // FREERTOS_CONFIG_H
