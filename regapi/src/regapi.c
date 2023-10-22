#include "regapi.h"

int regget() {
    FILE *file = fopen(REG_FILE, "r"); // Open the file for writing
    char buffer[1024];

    if (file == NULL) {
        perror("Error opening the file");
        printf("Call %s to get the default reg value 666\n", __func__);
        return 1;
    }
    // Read the string from the file
    if (fgets(buffer, sizeof(buffer), file) != NULL) {
        printf("Call %s to get reg value %s\n", __func__, buffer);
    }
    // Close the file
    fclose(file);
    return atoi(buffer);
}

void regset(int val) {
    FILE *file = fopen(REG_FILE, "w"); // Open the file for writing

    if (file == NULL) {
        perror("Error opening the file");
        return;
    }
    printf("Call %s to set reg value %d\n", __func__, val);
    // Write the string to the file
    fprintf(file, "%d", val);
}
