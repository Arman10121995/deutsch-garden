"""Refuse commit messages that contain a leaked environment or a credential.

This exists because it happened. A commit message written with
`git commit -m "...backticks..."` had its backticks interpreted by the shell as
command substitution, one of them ran `env`, and roughly a hundred variables --
including a session token -- went into the commit body and were pushed to a
public repository. Force-pushing unlinks such a commit but does not delete it:
the object stays retrievable by SHA until GitHub garbage-collects it.

A commit message is not reviewed the way a diff is, so nothing would have
caught this. Now something does.

Usage:
    python tool/check_commit_messages.py               # HEAD only
    python tool/check_commit_messages.py <range>       # e.g. origin/main..HEAD
"""
import re
import subprocess
import sys

# Variable names that only ever appear together in a dumped environment, and
# names whose value is a credential wherever it appears.
MARKERS = [
    r'\bCLAUDE_CODE_MESSAGING_TOKEN\s*=',
    r'\bANTHROPIC_API_KEY\s*=',
    r'\bGITHUB_TOKEN\s*=',
    r'\bGH_TOKEN\s*=',
    r'\bAWS_SECRET_ACCESS_KEY\s*=',
    r'\bANDROID_KEYSTORE_PASSWORD\s*=',
    r'\bAPPLE_APP_SPECIFIC_PASSWORD\s*=',
    r'-----BEGIN [A-Z ]*PRIVATE KEY-----',
]

# An environment dump is recognisable by several of these appearing at once.
# Individually they are unremarkable; together they are `env` output.
ENV_SHAPE = [
    r'^NUMBER_OF_PROCESSORS=',
    r'^COMSPEC=',
    r'^ALLUSERSPROFILE=',
    r'^HOMEDRIVE=',
    r'^PATHEXT=',
    r'^PROCESSOR_ARCHITECTURE=',
    r'^SHLVL=',
    r'^XDG_.*=',
]
ENV_SHAPE_THRESHOLD = 3


def messages(rev_range):
    """(sha, subject, body) for each commit in the range."""
    # A text sentinel rather than a NUL: argv cannot carry an embedded null
    # on Windows, and git log --format is passed as an argument.
    sep = '@@@COMMIT-BOUNDARY-8f21@@@'
    out = subprocess.run(
        ['git', 'log', '--format=%H%n%s%n%b' + sep, rev_range],
        capture_output=True, text=True, encoding='utf-8', errors='replace')
    if out.returncode != 0:
        sys.stderr.write(out.stderr)
        raise SystemExit(2)
    for chunk in out.stdout.split(sep):
        chunk = chunk.strip('\n')
        if not chunk:
            continue
        lines = chunk.split('\n')
        yield lines[0], lines[1] if len(lines) > 1 else '', '\n'.join(lines[2:])


def problems(text):
    found = []
    for pattern in MARKERS:
        if re.search(pattern, text, re.M):
            # Never echo the value: this output goes to a build log.
            found.append('contains %s' % pattern.strip('\\b').split(r'\s')[0])
    shape = sum(1 for p in ENV_SHAPE if re.search(p, text, re.M))
    if shape >= ENV_SHAPE_THRESHOLD:
        found.append('looks like a dumped environment (%d marker lines)' % shape)
    return found


def main():
    rev_range = sys.argv[1] if len(sys.argv) > 1 else '-1'
    bad = 0
    for sha, subject, body in messages(rev_range):
        issues = problems(subject + '\n' + body)
        if issues:
            bad += 1
            print('%s %s' % (sha[:9], subject[:60]))
            for issue in issues:
                print('    %s' % issue)
    if bad:
        print()
        print('%d commit message(s) carry environment or credential text.' % bad)
        print('Rewrite them before pushing. Write the message to a file and use')
        print('`git commit -F <file>`: a message passed with -m goes through the')
        print('shell, and backticks in it are executed.')
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
