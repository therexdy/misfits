#include <chrono>
#include <iostream>
#include <string>
#include <thread>

void marquee(int size, std::string text){
    int spaces = size - text.length();
    int j=0;
    while(true){
        for(int i=0; i<j; i++){
            std::cout << " ";
        }
        std::cout << text;
        for(int i=0; i<spaces-j; i++){
            std::cout << " ";
        }
        j = (j+1)%spaces;
        std::cout << std::endl;
        std::this_thread::sleep_for(std::chrono::milliseconds(25));
    }
}

int main(/*int argc, char** argv*/){
//    std::vector<std::string> args(argc);
//    for(int i=0; i<argc; i++){args[i]=argv[i];};
//    marquee(std::atoi(args[1].c_str()), args[2]);
    marquee(88, "=>");
    return 0;
}
