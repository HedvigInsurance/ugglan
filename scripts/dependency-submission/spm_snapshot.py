#!/usr/bin/env python3
"""Turn a Swift Package Manager Package.resolved into a GitHub dependency-graph
snapshot, for the Dependency Submission API.

GitHub parses Package.resolved only at the repo root. Xcode and Tuist projects keep
it inside the .xcworkspace, and Tuist regenerates it, so the graph never sees the
Swift dependencies. This prints the snapshot JSON; the caller posts it:

  python3 scripts/dependency-submission/spm_snapshot.py \\
      Ugglan.xcworkspace/xcshareddata/swiftpm/Package.resolved \\
      --sha "$GITHUB_SHA" --ref "$GITHUB_REF" --job "$GITHUB_JOB" --run-id "$GITHUB_RUN_ID" \\
    | gh api "repos/$GITHUB_REPOSITORY/dependency-graph/snapshots" --input -

The register that reads the result lives in HedvigInsurance/prod-env under
compliance/oss-register.

Package.resolved lists the full transitive closure, so every pin is submitted. The
file does not say which pins are direct, so no relationship is claimed.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
from pathlib import Path
from urllib.parse import urlparse


def package_url(location: str, state: dict) -> str | None:
    """pkg:swift/<host>/<owner>/<repo>@<version>, or None for a local package."""
    parsed = urlparse(location if "://" in location else f"ssh://{location.replace(':', '/', 1)}")
    if not parsed.hostname:
        return None
    path = re.sub(r"\.git$", "", parsed.path.strip("/"))
    version = state.get("version") or state.get("revision")
    if not path or not version:
        return None
    return f"pkg:swift/{parsed.hostname}/{path}@{version}"


def pins(resolved: dict) -> list[tuple[str, dict]]:
    """(location, state) for every pin, across Package.resolved versions 1 to 3."""
    entries = resolved.get("pins") or resolved.get("object", {}).get("pins", [])
    return [(pin.get("location") or pin.get("repositoryURL", ""), pin.get("state", {})) for pin in entries]


def snapshot(resolved: dict, resolved_path: str, sha: str, ref: str, job: str, run_id: str,
             now: dt.datetime | None = None) -> dict:
    purls = sorted({purl for purl in (package_url(location, state) for location, state in pins(resolved)) if purl})
    return {
        "version": 0,
        "sha": sha,
        "ref": ref,
        "job": {"correlator": job, "id": run_id},
        "detector": {"name": "hedvig-spm-snapshot", "version": "1.0.0",
                     "url": "https://github.com/HedvigInsurance/ugglan/tree/master/scripts/dependency-submission"},
        "scanned": (now or dt.datetime.now(dt.timezone.utc)).isoformat(timespec="seconds"),
        "manifests": {
            resolved_path: {
                "name": resolved_path,
                "file": {"source_location": resolved_path},
                "resolved": {purl: {"package_url": purl, "scope": "runtime"} for purl in purls},
            }
        },
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("resolved", type=Path, help="Package.resolved, path relative to the repo root")
    parser.add_argument("--sha", required=True)
    parser.add_argument("--ref", required=True)
    parser.add_argument("--job", required=True, help="correlator: workflow + job name")
    parser.add_argument("--run-id", required=True)
    args = parser.parse_args(argv)
    result = snapshot(json.loads(args.resolved.read_text()), str(args.resolved), args.sha, args.ref, args.job, args.run_id)
    json.dump(result, sys.stdout, indent=1)
    print(f"{len(result['manifests'][str(args.resolved)]['resolved'])} packages from {args.resolved}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
