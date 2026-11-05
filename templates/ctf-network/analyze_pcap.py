#!/usr/bin/env python3
"""CTF Network packet / PCAP analysis template."""
import sys
from scapy.all import rdpcap, IP, TCP, UDP

def analyze(pcap_file):
    print(f"[*] Reading {pcap_file}...")
    packets = rdpcap(pcap_file)
    print(f"[+] Loaded {len(packets)} packets.")

def main():
    if len(sys.argv) > 1:
        analyze(sys.argv[1])
    else:
        print("Usage: python3 analyze_pcap.py <file.pcap>")

if __name__ == "__main__":
    main()

