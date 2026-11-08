#!/usr/bin/env python3
"""
OSINT Investigation Helper Script
"""
import sys
import subprocess

def search_username(username):
    print(f"[*] Running Sherlock for username: {username}")
    subprocess.run(["sherlock", username])

def search_domain(domain):
    print(f"[*] Running theHarvester for domain: {domain}")
    subprocess.run(["theHarvester", "-d", domain, "-b", "all"])

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 investigate.py <username_or_domain>")
        sys.exit(1)
    target = sys.argv[1]
    if "." in target:
        search_domain(target)
    else:
        search_username(target)

if __name__ == "__main__":
    main()
