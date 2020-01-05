#include <iostream>

#include "plotter.h"
#include "feeder.h"

int main(int argc, char ** argv) {
  // call a function in another file
  helloMake();
  feed();

  std::cout << "narg: " << argc << " first arg: " <<argv[0] << std::endl;
  return(0);
}
