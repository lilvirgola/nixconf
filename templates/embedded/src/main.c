/**
 * Embedded / Microcontroller Starter
 */
#include <stdio.h>

void setup() {
    printf("Microcontroller setup initialized.\n");
}

void loop() {
    // Main execution loop
}

int main(void) {
    setup();
    while (1) {
        loop();
        break; // Guard for native testing
    }
    return 0;
}
