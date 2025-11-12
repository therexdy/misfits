#include <stdio.h>
#include <time.h>

char weekdays[7][4] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

char* dtime2string(int gmt_sec_offset){
    static char tin_string[7];
    tin_string[6] = '\0';
    tin_string[3] = ':';
    if(gmt_sec_offset < 0){
        tin_string[0] = '-';
    }
    else {
        tin_string[0] = '+';
    }
    int hour = (int)(gmt_sec_offset/3600);
    for(int i=0; i<2; i++){
        tin_string[2] = hour%10 + '0';
        tin_string[1] = (hour/10)%10 + '0';
    }
    int mins = (gmt_sec_offset/60) - (hour*60);
    for(int i=0; i<2; i++){
        tin_string[5] = mins%10 + '0';
        tin_string[4] = (mins/10)%10 + '0';
    }
    return tin_string;
}

int main(){
    time_t now = time(nullptr);
    struct tm local = *localtime(&now);
    printf("Year: %d\nMonth: %d\nDate: %d\nDay: %s\nHours: %d\nMinutes: %d\nSeconds: %d\nTimeZone: %s\nGMT Offset(Hours): %s\n", 
           local.tm_year + 1900,
           local.tm_mon + 1,
           local.tm_mday,
           weekdays[local.tm_wday],
           local.tm_hour,
           local.tm_min,
           local.tm_sec,
           local.tm_zone,
           dtime2string(local.tm_gmtoff)
           );
    return 0;
}
