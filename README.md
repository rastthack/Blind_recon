
# blind_recon.sh

Sequential recon automation script for a target host/domain.

The script runs multiple common recon tools one after another and saves output
to timestamped files in a results directory.

## Script File

- blind_recon.sh

## Recon Requirements

The script works even if some tools are missing. Missing tools are skipped.

Common tools used:
- whois
- dig
- nslookup
- host
- ping
- traceroute
- curl
- nmap
- whatweb

## Run

From the project folder:

./blind_recon.sh <target> [--output <dir>] [--full-ports]

Examples:

./blind_recon.sh example.com
./blind_recon.sh 192.168.1.10 --output results_local
./blind_recon.sh example.com --full-ports

## Options

- --output, -o
  - Custom output directory name.
  - Default format: blind_recon_<target>_<timestamp>

- --full-ports
  - Adds full TCP port scan with nmap (-p-).
  - This can take a long time.

- --help, -h
  - Shows help text.

## Output

- One text file per tool/step.
- Files are prefixed with numbers to preserve run order.
- If a command fails, the script continues and logs the error in that step's file.

### Example Run (Real Output)

Command:

./blind_recon.sh google.com -o a.txt

Output:

 Target: google.com
 Output directory: a.txt
 Running: WHOIS
 Saved: a.txt/01_whois.txt
 Running: DNS ANY
 Saved: a.txt/02_dig_any.txt
 Running: DNS NS
 Saved: a.txt/03_dig_ns.txt
 Running: DNS MX
 Saved: a.txt/04_dig_mx.txt
 Running: NSLOOKUP
 Saved: a.txt/05_nslookup.txt
 Running: HOST
 Saved: a.txt/06_host.txt
 Running: PING (4 packets)
 Saved: a.txt/07_ping.txt
 Running: Traceroute
 Saved: a.txt/08_traceroute.txt
 Running: HTTP headers
 Saved: a.txt/09_http_headers.txt
 Running: HTTPS headers
 Saved: a.txt/10_https_headers.txt
 Skipping nmap scans (nmap not installed)
 Skipping WhatWeb (whatweb not installed)
 Blind recon complete. Results saved in: a.txt

This example shows a successful run where optional tools were missing and safely skipped.

## Make Executable

If needed:

chmod +x blind_recon.sh

## Safety Note

Only scan systems you own or have explicit permission to test.
