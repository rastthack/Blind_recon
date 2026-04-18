
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

[2026-04-18 12:18:24] Target: google.com
[2026-04-18 12:18:24] Output directory: a.txt
[2026-04-18 12:18:24] Running: WHOIS
[2026-04-18 12:18:26] Saved: a.txt/01_whois.txt
[2026-04-18 12:18:26] Running: DNS ANY
[2026-04-18 12:18:26] Saved: a.txt/02_dig_any.txt
[2026-04-18 12:18:26] Running: DNS NS
[2026-04-18 12:18:27] Saved: a.txt/03_dig_ns.txt
[2026-04-18 12:18:27] Running: DNS MX
[2026-04-18 12:18:27] Saved: a.txt/04_dig_mx.txt
[2026-04-18 12:18:27] Running: NSLOOKUP
[2026-04-18 12:18:27] Saved: a.txt/05_nslookup.txt
[2026-04-18 12:18:27] Running: HOST
[2026-04-18 12:18:27] Saved: a.txt/06_host.txt
[2026-04-18 12:18:27] Running: PING (4 packets)
[2026-04-18 12:18:30] Saved: a.txt/07_ping.txt
[2026-04-18 12:18:30] Running: Traceroute
[2026-04-18 12:19:03] Saved: a.txt/08_traceroute.txt
[2026-04-18 12:19:03] Running: HTTP headers
[2026-04-18 12:19:03] Saved: a.txt/09_http_headers.txt
[2026-04-18 12:19:03] Running: HTTPS headers
[2026-04-18 12:19:04] Saved: a.txt/10_https_headers.txt
[2026-04-18 12:19:04] Skipping nmap scans (nmap not installed)
[2026-04-18 12:19:04] Skipping WhatWeb (whatweb not installed)
[2026-04-18 12:19:04] Blind recon complete. Results saved in: a.txt

This example shows a successful run where optional tools were missing and safely skipped.

## Make Executable

If needed:

chmod +x blind_recon.sh

## Safety Note

Only scan systems you own or have explicit permission to test.
