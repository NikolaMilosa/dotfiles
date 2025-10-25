#!/usr/bin/env python

import getpass
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


def get_wifi_device() -> str:
    out = run_out(["nmcli", "-t", "-f", "DEVICE,TYPE", "device"]).strip().splitlines()

    for line in out:
        parts = line.split(":")

        name, device_type = parts[0], parts[1]
        if device_type == "wifi":
            return name

    raise ValueError("Didn't find device id for wifi")


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
    known, ssid, band, signal = (
        parts[0].strip(),
        parts[1].strip(),
        parts[2].strip(),
        parts[3].strip(),
    )
    logging.info("Picked network: %s (%s) - signal strength %s" % (ssid, band, signal))

    if known == "Known":
        logging.info("Connecting to a known network...")
        run_out(["nmcli", "connection", "up", ssid])
        return

    logging.info("Connecting to an unknown network...")
    logging.info("Picking the connection type:")
    logging.info("\t1. Username + password ")
    logging.info("\t2. Email + password (corporate/EAP)")
    logging.info("\t3. Just password (standard)")

    conn_type = input("Choose [1-3]: ")
    choice = int(conn_type)

    if choice == 1:
        username = input("Username: ")
    if choice == 2:
        email = input("Email: ")

    password = getpass.getpass(prompt="Password: ")

    device = get_wifi_device()
    logging.info("Connecting to device: %s" % device)

    if choice == 3:
        # connect to device
        result = subprocess.run(
            [
                "sudo",
                "nmcli",
                "device",
                "wifi",
                "connect",
                ssid,
                "password",
                password,
                "ifname",
                device,
                "--ask",
            ],
            check=True,
        )
        result.check_returncode()
        print("Hello")
    else:
        if username is not None:
            identity = username
        elif email is not None:
            identity = email
        else:
            raise ValueError("Neither username nur email have been set")

        # connect to the device
        result = subprocess.run(
            [
                "sudo",
                "nmcli",
                "connection",
                "add",
                "type",
                "wifi",
                "ifname",
                device,
                "con-name",
                ssid,
                "ssid",
                ssid,
                "wifi-sec.key-mgmt",
                "wpa-eap",
                "802-1x.identity",
                identity,
                "802-1x.password",
                password,
            ],
            check=True,
        )
        result.check_returncode()

    # modify permissions
    result = subprocess.run(
        ["sudo", "nmcli", "connection", "modify", ssid, "connection.permissions", ""],
        check=True,
    )
    result.check_returncode()

    logging.info("Successfully connected to the network: %s", ssid)


main()
