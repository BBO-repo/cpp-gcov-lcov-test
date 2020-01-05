###################################
# executable and main directories #
###################################

EXEC := program
SDIR := source
IDIR := $(sort $(dir $(wildcard $(SDIR)/*/)))
IDIR := $(filter-out $(SDIR)/,$(IDIR)) # remove SDIR from list of include
ODIR := obj
BDIR := build

######################### additional libraries #########################
IDIR1 := external/catch
IDIRS := $(IDIR) $(IDIR1) # $(IDIR2) $(IDIR3) ...
LDIR1 := # add path to library
LDIRS := $(LDIR1) # $(LDIR2) $(LDIR3) ...

########################### compile and link flags ###########################
CXX      := g++
CXXFLAGS := -Wall -Wextra -std=c++17
CPPFLAGS := $(foreach inc, $(IDIRS),-I$(inc))
LIBS     := $(foreach lib, $(LDIRS),-L$(lib))
LDFLAGS  := $(LIBS) # add library link for example -lopencv_core 

# release vs debug (debug by default)
DEBUG ?= 1

ifeq ($(DEBUG), 1)
CXXFLAGS += -DDEBUG
else 
CXXFLAGS += -O3 -DNDEBUG
endif

################# dependencies #################
SRCS := $(wildcard $(SDIR)/*.cpp) $(wildcard $(SDIR)/*/*.cpp)
OBJS := $(patsubst $(SDIR)/%.cpp, $(ODIR)/%.o, $(SRCS))
DEPS := $(OBJS:%.o=%.d)

################# dependencies #################
TEST_EXEC := test_program
TDIR      := test
TEST_SRCS := $(wildcard $(TDIR)/*.cpp) $(wildcard $(SDIR)/*/*.cpp)
TEST_OBJS := $(patsubst $(TDIR)/%.cpp, $(ODIR)/%.o, $(TEST_SRCS))


###########################
# compilation and linking #
###########################
# list of non-file based targets:
.PHONY: depend clean all

# default target
all: $(BDIR)/$(EXEC)

print:
	echo "[INFO] TESTS:" $(TEST_SRCS)

test: $(BDIR)/$(TEST_EXEC)

# build executable - link
$(BDIR)/$(EXEC): $(OBJS) | $(BDIR)
	$(CXX) -o $(BDIR)/$(EXEC) $(OBJS) $(LDFLAGS)

$(BDIR)/$(TEST_EXEC): $(TEST_OBJS) | $(BDIR)
	$(CXX) -o $(BDIR)/$(TEST_EXEC) $(TEST_OBJS) --coverage $(LDFLAGS)

# include all .d files to track if an header has been modified without any implementation modification
-include $(DEPS)

# build objects - compile
$(ODIR)/%.o: $(SDIR)/%.cpp | $(ODIR)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) -MMD -c -o $@ $<

$(ODIR)/%.o: $(TDIR)/%.cpp | $(ODIR)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) --coverage -MMD -c -o $@ $<

###############################################
# build directories if do not already present #
###############################################
# build object directory if not already exist
$(ODIR):
	mkdir $(patsubst $(SDIR)/%,$(ODIR)/%, $(dir $(SRCS)) )

# build build directory if not already exist
$(BDIR):
	mkdir -p $@

############
# cleaning #
############
# only remove directory content
clean:
	rm $(patsubst $(SDIR)/%,$(ODIR)/%*.o, $(dir $(SRCS))) $(patsubst $(SDIR)/%,$(ODIR)/%*.d, $(dir $(SRCS))) $(BDIR)/$(EXEC)

# remove directories
dist-clean:
	rm -r $(ODIR)/ $(BDIR)/
