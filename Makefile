CXX = g++
CC = gcc
ISPC = ispc
CXXFLAGS = -O3 -Wall -march=native
CFLAGS = -O3 -Wall -march=native
ISPC_FLAGS = --opt=fast-math
# these flags can be used, without them defaults are used which works just as good on macOS with m1, didn't try other systems
# ISPC_FLAGS = --target=neon-i32x4 --arch=aarch64 --opt=fast-math

TARGET = newton_fractal
TARGET_C = newton_fractal_c

SOURCES = main.cpp
C_SOURCES = main.c
ISPC_SOURCES = fractal.ispc
ISPC_OBJS = fractal_ispc.o
ISPC_HEADERS = fractal_ispc.h

all: $(TARGET) $(TARGET_C)

$(TARGET): $(SOURCES) $(ISPC_OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^ -lm

$(TARGET_C): $(C_SOURCES)
	$(CC) $(CFLAGS) -o $@ $^ -lm

$(ISPC_OBJS): $(ISPC_SOURCES)
	$(ISPC) $(ISPC_FLAGS) $< -o $@ -h $(ISPC_HEADERS)

clean:
	rm -f $(TARGET) $(TARGET_C) $(ISPC_OBJS) $(ISPC_HEADERS) *.png

bench: $(TARGET) $(TARGET_C)
	@echo "Running ISPC benchmarks"
	@for power in 3 5 7 9; do \
		echo "ISPC, power $$power:"; \
		time ./$(TARGET) $$power; \
		echo ""; \
	done
	@echo "Running C benchmarks"
	@for power in 3 5 7 9; do \
		echo "C, power $$power:"; \
		time ./$(TARGET_C) $$power; \
		echo ""; \
	done

test: $(TARGET)
	./$(TARGET) 3
	./$(TARGET) 5
	./$(TARGET) 7
	./$(TARGET) 9

.PHONY: all clean bench test