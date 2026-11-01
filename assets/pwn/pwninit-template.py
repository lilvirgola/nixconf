#!/usr/bin/env python3

from pwn import *

{bindings}

context.binary = {bin_name}
context.log_level = "debug"
context.terminal = ["kitty"]

gdbscript = """
"""

nc = ""
def conn(*a, **kw): # default: local    R: remote    D: debug
    if args.R:
        addr = nc.split(" ")[1]
        port = int(nc.split(" ")[2])
        r = remote(addr, port, **kw)
    else:
        r = process({proc_args}, **kw)
        if args.D:
            gdb.attach(r, gdbscript, **kw)
    return r

io = conn(level="debug")

# Add functions below here, if needed


def main():
    global io

    # good luck pwning :)

    io.interactive()


if __name__ == "__main__":
    main()

