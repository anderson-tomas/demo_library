#
# 'make SHARED_LIB=0' build executable file with libregapi.a
# 'make SHARED_LIB=1' build executable file with libregapi.so
# 'make clean'  removes all .o, .a, .so and executable files
#

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -Iregapi/include
LIB_CFLAGS = -Wall -Wextra -Iregapi/include -fPIC
LDFLAGS = -L. -lregapi

# Source files and objects
SRC = main.c
LIB_SRC = regapi/src/regapi.c
OBJ = $(SRC:.c=.o) regapi.o

# Target executable
TARGET = hello

.PHONY: all clean

all: $(TARGET)

# Build the static library
libregapi.a: regapi.o
	ar rcs $@ $^

# Build the static library
libregapi.so: regapi.o
	$(CC) -s -shared -o $@ $^

ifeq ($(SHARED_LIB),1)
# Compile the library source file
regapi.o: $(LIB_SRC)
	$(CC) $(LIB_CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.so
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

else
# Compile the library source file
regapi.o: $(LIB_SRC)
	$(CC) $(CFLAGS) -c $<

# Build the main executable
$(TARGET): $(OBJ) libregapi.a
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

endif

# Compile source files
%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(TARGET) $(OBJ) libregapi.a libregapi.so reg.txt

