#!/usr/bin/env python
import json
import logging
import subprocess
import sys
import time

from utils.shared import ensure_cmd_exists, fzf, run_out

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
REQUIRED_CMDS = ["pritunl-client"]


def get_pritunl_profiles() -> list[dict]:
    output = run_out(["pritunl-client", "list", "-j"])
    output = json.loads(output)

    return output


def set_pritunl_profile(id: str, cmd: str):
    args = ["pritunl-client", cmd, id]
    if cmd == "start":
        args.append("-r")

    result = subprocess.run(
        args,
        check=True,
    )
    result.check_returncode()


def wait_for_transition(id: str, expected: bool):
    retries = 5
    for i in range(retries):
        profile = next(filter(lambda x: x["id"] == id, get_pritunl_profiles()))
        if not profile:
            raise ValueError("Profile with id %s is no longer present" % id)

        if profile["connected"] == expected:
            return

        logging.warning(
            "Retry [%s.] waiting for transition... Retrying in 1 second" % i
        )
        time.sleep(1)

    logging.error("Didn't observe the expected transition")
    sys.exit(1)


def main():
    logging.info("Ensuring that the following commands exist: %s" % REQUIRED_CMDS)
    [ensure_cmd_exists(cmd) for cmd in REQUIRED_CMDS]

    profiles = get_pritunl_profiles()

    if len(profiles) == 0:
        logging.error("There are no profiles configured.")
        sys.exit(1)

    profile = None
    if len(profiles) > 1:
        profile = profiles[0]

        def fmt(item) -> str:
            id = item["id"] if "id" in item else item[0]
            name = item["name"] if "name" in item else item[1]
            status = item["status"] if "status" in item else item[2]
            connected = item["connected"] if "connected" in item else item[3]
            return f"{id:<{len(profile['id'])}} | {name:<{len(profile['name'])}} | {status:<{len(profile['status'])}} | {connected:<11}"

        profile = fzf(
            "Pick the profile to togle: ",
            profiles,
            ["ID", "Name", "Status", "Is connected"],
            fmt,
        )
        id = profile.split("|")[0].strip()
        profile = next(filter(lambda x: x["id"] == id, profiles))
    else:
        profile = profiles[0]

    if not profile:
        logging.error("Didn't find any profile picked")
        sys.exit(1)

    logging.info("Picked profile %s with id: %s" % (profile["name"], profile["id"]))
    set_pritunl_profile(profile["id"], "stop" if profile["connected"] else "start")
    logging.info(
        "Watching for connection status change %s -> %s"
        % (profile["connected"], not profile["connected"])
    )
    wait_for_transition(profile["id"], not profile["connected"])
    logging.info(
        "Successfully %s to %s with id: %s"
        % (
            "disconnected" if profile["connected"] else "connected",
            profile["id"],
            profile["name"],
        )
    )


main()
