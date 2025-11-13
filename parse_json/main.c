#include <stdio.h>
#include <stdlib.h>

typedef struct{
    char* key;
    char* value;
}pair;

char* read_file(const char* path){
    FILE* f = fopen(path, "rb");
    if(!f){
        return nullptr;
    }

    if(fseek(f, 0, SEEK_END)){
        fclose(f);
        return nullptr;
    }
    long size = ftell(f);
    if(size < 0){
        fclose(f);
        return nullptr;
    }
    rewind(f);

    char* buf = malloc(size + 1);
    if(!buf){
        fclose(f);
        return nullptr;
    }

    fread(buf, 1, size, f);
    buf[size] = '\0';
    fclose(f);
    return buf;

}

void parse_json(char* json){
    if(!json){
        return;
    }
    int lines=0, i=0;
    while(json[i]!='\0'){
        if(json[i++]=='\n'){
            lines++;
        }
    }
}

int main(int argc, char** argv){
    char path[16]="./test.json";
    char* json = read_file(path);
    parse_json(json);
    free(json);
    return 0;
}
