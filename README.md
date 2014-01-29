## Alternative to echof: an echo server with consistent EOF notifications

### Summary

See [echof](https://github.com/jeberle/echof). This server uses UNIX domain sockets along w/ the
`NSNotificationCenter` with `NSFileHandle`
`readInBackgroundAndNotify`. It works as expected.

### Contents

    Makefile  - to build echoud program
    README.md - this file
    echoud.m  - echoud source. this is an echo server that use a domain socket
    kit.h     - precompiled header
    test.py   - test client

### To Build

    make

### To Run

    ./echoud

    ... in another console ...
    
    ./test.py 5

In my tests, it works w/ any number of echo lines, including 1!

