#!/usr/bin/env python

import logging
import subprocess
import sys

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
REQUIRED_CMDS = ["nmcli", "fzf"]


def ensure_cmd_exists(cmd: str):
    result = subprocess.run(
        ["which", cmd],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    output = result.stdout.decode()
    if "not found" in output or result.returncode != 0:
        raise ValueError("Command %s doesn't exist: %s" % (cmd, result.stderr))


def run(cmd) -> tuple[str, str]:
    logging.info("Running %s" % cmd)
    result = subprocess.run(
        cmd,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    result.check_returncode()
    stdout, stderr = result.stdout.decode(), result.stderr.decode()

    return (stdout, stderr)


def run_out(cmd) -> str:
    (out, _) = run(cmd)
    return out


def get_available() -> list[list[str]]:
    out = run_out(
        ["nmcli", "-t", "-f", "SSID,FREQ,SIGNAL,SECURITY", "device", "wifi", "list"]
    )

    lines = []
    for line in out.splitlines():
        parts = line.split(":")
        if len(parts) < 4:
            continue
        ssid, freq, signal, security = parts[:4]
        try:
            freq = freq.strip().split(" ")[0]
            freq_mhz = int(freq)
        except ValueError:
            freq_mhz = 0

        # Determine band
        band = "5G" if freq_mhz >= 4900 else "2.4G"

        lines.append([ssid, band, signal, security])
    return lines


def get_known() -> list[list[str]]:
    out = run_out(["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"])

    return [line.split(":") for line in out.splitlines()]


def combine(known, available) -> list[str]:
    combined = []

    for av in available:
        ssid = av[0]
        if not ssid:
            logging.warning("Skipping combining entry %s" % av)
            continue

        curr = []
        if not any([network[0] == ssid for network in known]):
            curr.append("Unknown")
        else:
            curr.append("Known")

        curr.extend(av)
        combined.append(curr)

    return combined


def fzf(prompt: str, items: list[str]) -> str:
    result = subprocess.run(
        ["fzf", f"--prompt={prompt}", "--height=20", "--border"],
        input="\n".join(items),
        text=True,
        capture_output=True,
    )

    return result.stdout.strip()


def main():
    logging.info("Running wifi selector...")

    [ensure_cmd_exists(cmd) for cmd in REQUIRED_CMDS]
    logging.info("Ensured required commands: %s" % REQUIRED_CMDS)
    logging.info("Scanning for available networks...")
    run_out(["nmcli", "device", "wifi", "rescan"])

    available = get_available()
    known = get_known()

    combined = combine(known, available)
    if len(combined) == 0:
        logging.warning("Didn't find any networks...")
        sys.exit(1)

    longest_name = max([len(line[1]) for line in combined])
    picked = fzf(
        "Select wifi network: ",
        [
            f"{line[0]:<8} | {line[1]:<{longest_name}} | {line[2]:<4} | {line[3]:>3}% | {line[4]}"
            for line in combined
        ],
    )
    parts = picked.split("|")
    ssid, band, signal = parts[1].strip(), parts[2].strip(), parts[3].strip()
    logging.info("Picked network: %s (%s) - signal strength %s" % (ssid, band, signal))


main()
