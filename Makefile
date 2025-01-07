# Compiler and flags
CC = clang
AS = as
CFLAGS = -O3 -Wall -Wextra
LDFLAGS =

# Targets
TARGETS = hello pattern fib simd_add macros

# Default target
all: $(TARGETS)

# Rule for assembling .s files
%.o: %.s
	$(AS) -o $@ $<

# Rule for compiling .c files
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Rules for linking executables
hello: hello.o
	$(CC) $(LDFLAGS) -o $@ $^

pattern: pattern.o
	$(CC) $(LDFLAGS) -o $@ $^

fib: fib.o
	$(CC) $(LDFLAGS) -o $@ $^

simd_add: simd_add.o simd_add_floats.o
	$(CC) $(LDFLAGS) -o $@ $^

macros: macros.s
	$(CC) $(LDFLAGS) -o $@ $^

# Clean up
clean:
	rm -f $(TARGETS) *.o

# Phony targets
.PHONY: all clean
