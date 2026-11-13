#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <FreeRTOS.h>
#include <semphr.h>
#include <task.h>

static _Thread_local int local = 1;

static SemaphoreHandle_t done;

static void
worker(void *data) {
  local = 2;

  for (int i = 0; i < 1000; i++) free(malloc(64 + i));

  printf("worker local=%d\n", local);

  xSemaphoreGive(done);

  vTaskDelete(NULL);
}

int
main(int argc, char *argv[]) {
  if (argc != 2) return 1;

  if (strcmp(argv[1], "exit") == 0) return 3;

  if (strcmp(argv[1], "tick") == 0) {
    TickType_t start = xTaskGetTickCount();

    vTaskDelay(pdMS_TO_TICKS(20));

    return xTaskGetTickCount() - start >= pdMS_TO_TICKS(20) ? 0 : 1;
  }

  if (strcmp(argv[1], "tasks") == 0) {
    done = xSemaphoreCreateBinary();

    if (xTaskCreate(worker, "worker", 4096, NULL, tskIDLE_PRIORITY + 1, NULL) != pdPASS) return 1;

    for (int i = 0; i < 1000; i++) free(malloc(64 + i));

    if (xSemaphoreTake(done, pdMS_TO_TICKS(1000)) != pdTRUE) return 1;

    printf("main local=%d\n", local);

    return local == 1 ? 0 : 1;
  }

  return 1;
}
