#! /usr/bin/env python2.7

from __future__ import print_function
import sys

def main(argv):
    if len(argv) == 2:
        n = int(argv[1])
    else:
        n = 3
    import socket
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect('ud')
    for i in range(n):
        sock.sendall('hello\n')
        m = sock.recv(6)
        print(m.rstrip())
    sock.close()

if __name__ == '__main__':
    main(sys.argv)

