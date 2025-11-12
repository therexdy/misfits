#include <stdio.h>
#include <unistd.h>
#include <time.h>
#define _POSIX_C_SOURCE 200809L

int main(){
    struct timespec duration = {1, 0};
    printf("->Start\n\n");

    // sleep() function POSIX alli depricate agide
    sleep(5); // idu unistd lib alli bandirodu
    printf("\tsleep() done\n");
    
    // nanosleep is the recommended option
    nanosleep(&duration, nullptr); // idu time.h lib alli bandirodu
    printf("\tnanosleep() done\n\n");
    printf("->Stop\n");
    return 0;
}
