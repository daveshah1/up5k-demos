#!/usr/bin/env python3

import os, sys, re

prg_alloc = 64*1024
chr_alloc = 64*1024

prg_dat = bytearray()
chr_dat = bytearray()

with open(sys.argv[1], 'rb') as f:
    header = f.read(16)
    prg_size = header[4] * 16384
    chr_size = header[5] * 8192
    assert prg_size <= prg_alloc
    assert chr_size <= chr_alloc
    prg_dat = f.read(prg_size)
    chr_dat = f.read(chr_size)

prg_dat = bytearray(prg_dat)
chr_dat = bytearray(chr_dat)

for i in range(prg_size, prg_alloc):
    prg_dat.append(prg_dat[i % prg_size])

for i in range(chr_size, chr_alloc):
    chr_dat.append(chr_dat[i % chr_size])

with open(sys.argv[2], 'wb') as f:
    f.write(prg_dat)
    f.write(chr_dat)