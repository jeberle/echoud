
H    := kit.h
PCH  := $(H).pch
CC   := cc
EXE  := echoud

all: $(PCH) $(EXE)

%.pch: %
	$(CC) -x objective-c-header -o $@ $<

%.o: %.m
	$(CC) -g -c -Wall -include $(H) -o $@ $<

$(EXE): echoud.o
	$(CC) -framework Cocoa -o $@ $^

clean:
	rm -f *.o $(PCH) $(EXE)

.PHONY: all clean

