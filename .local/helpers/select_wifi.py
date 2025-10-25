#!/usr/bin/env python

import logging
import subprocess

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
        ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
    )

    return [line.split(":") for line in out.splitlines()]


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

    return combined


def main():
    logging.info("Running wifi selector...")

    [ensure_cmd_exists(cmd) for cmd in REQUIRED_CMDS]
    logging.info("Ensured required commands: %s" % REQUIRED_CMDS)
    logging.info("Scanning for available networks...")
    run_out(["nmcli", "device", "wifi", "rescan"])

    available = get_available()
    known = get_known()

    combined = combine(known, available)
    print(combined)


main()
