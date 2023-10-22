#include <stdio.h>
#include <stdlib.h> // Include for atoi
#include <string.h> // Include for strcmp
#include "regapi.h"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s [get | set <value>]\n", argv[0]);
        return 1;
    }

    if (strcmp(argv[1], "get") == 0) {
        printf("reg value: %d\n", regget());
    } else if (strcmp(argv[1], "set") == 0) {
        if (argc < 3) {
            printf("Usage: %s set <value>\n", argv[0]);
            return 1;
        }
        int value = atoi(argv[2]);
        printf("set reg value to %d\n", value);
        regset(value);
    } else {
        printf("Invalid command. Usage: %s [get | set <value>]\n", argv[0]);
        return 1;
    }

    return 0;
}
