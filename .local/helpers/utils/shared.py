import logging
import subprocess


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


def fzf(prompt: str, items: list[str], header, fmt) -> str:
    result = subprocess.run(
        ["fzf", f"--prompt={prompt}", "--height=20", "--border", "--header-lines=1"],
        input="\n".join([fmt(header)] + [fmt(item) for item in items]),
        text=True,
        capture_output=True,
    )

    return result.stdout.strip()
