#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * No error.
 */
#define ERR_OK 0

/**
 * Config path error.
 */
#define ERR_CONFIG_PATH 1

/**
 * Config parsing error.
 */
#define ERR_CONFIG 2

/**
 * IO error.
 */
#define ERR_IO 3

/**
 * Config file watcher error.
 */
#define ERR_WATCHER 4

/**
 * Async channel send error.
 */
#define ERR_ASYNC_CHANNEL_SEND 5

/**
 * Sync channel receive error.
 */
#define ERR_SYNC_CHANNEL_RECV 6

/**
 * Runtime manager error.
 */
#define ERR_RUNTIME_MANAGER 7

/**
 * No associated config file.
 */
#define ERR_NO_CONFIG_FILE 8

int32_t vpn_run(const char *config_path);

bool vpn_shutdown(void);
