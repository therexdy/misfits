#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int* arr; 
    size_t size;
    size_t capacity;
} vec;

#define push_back(vec, x) \
do {\
    if(vec.size >= vec.capacity){\
        if(vec.capacity == 0) vec.capacity = 32;\
        else vec.capacity *= 2;\
    }\
    vec.arr = realloc(vec.arr, vec.capacity*sizeof(int));\
    vec.arr[vec.size++] = x;\
} while (0)

int main(){
    vec a = {0};

    for(int i=0; i<10; i++) push_back(a, i);
    for(int i=0; i<10; i++) printf("%d\n", a.arr[i]);
    
}
