#include <iostream>
#include "feeder.h"

void feed(void) {
  std::cout << "Miam!\n" << std::endl;
  return;
}

unsigned int Factorial( unsigned int number ) {
    return number <= 1 ? number : Factorial(number-1)*number;
}