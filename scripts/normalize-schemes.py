#!/usr/bin/env python3
"""Rewrites Tuist-generated .xcscheme files into the form Xcode saves them in.

Xcode re-serializes a scheme whenever it's selected, so any difference from Tuist's output shows up as a stray
diff in the committed schemes. This undoes the two known differences:

1. In a TestAction, Xcode writes <Testables> after <CommandLineArguments> / <EnvironmentVariables>; Tuist writes
   it before them.
2. For UI test bundles Xcode leaves out parallelizable = "NO" (it's the default there); Tuist writes it.

Run from the repo root after `tuist generate` (scripts/generate.sh does both).
"""

import glob
import re

SCHEME_GLOBS = [
    "Projects/*/*.xcodeproj/xcshareddata/xcschemes/*.xcscheme",
    "Dependencies/*/*.xcodeproj/xcshareddata/xcschemes/*.xcscheme",
    "*.xcworkspace/xcshareddata/xcschemes/*.xcscheme",
]

TEST_ACTION = re.compile(r"(<TestAction\b.*?</TestAction>)", re.S)
TESTABLES = re.compile(r"\n( *)<Testables>.*?\n\1</Testables>", re.S)
ARGS_OR_ENV = re.compile(r"\n( *)<(CommandLineArguments|EnvironmentVariables)>.*?\n\1</\2>", re.S)
TESTABLE_REFERENCE = re.compile(r"<TestableReference\b.*?</TestableReference>", re.S)
UI_TEST_PARALLELIZABLE_NO = re.compile(r'(skipped = "(?:YES|NO)")\n *parallelizable = "NO">')


def ui_test_target_ids():
    """IDs of all UI test targets, read from the generated project.xcproj (JSON-like) files."""
    ids = set()
    for path in glob.glob("Projects/*/*.xcodeproj/project.xcproj") + glob.glob(
        "Dependencies/*/*.xcodeproj/project.xcproj"
    ):
        with open(path) as f:
            content = f.read()
        for match in re.finditer(r'"product-type":\s*"bundle\.ui-testing"', content):
            target_ids = re.findall(r'"id":\s*"([^"]+)"', content[: match.start()])
            if target_ids:
                ids.add(target_ids[-1])
    return ids


def move_testables_last(test_action):
    testables = TESTABLES.search(test_action)
    if not testables:
        return test_action
    trailing = [m for m in ARGS_OR_ENV.finditer(test_action) if m.start() > testables.start()]
    if not trailing:
        return test_action
    without = test_action[: testables.start()] + test_action[testables.end() :]
    insert_at = trailing[-1].end() - (testables.end() - testables.start())
    return without[:insert_at] + testables.group(0) + without[insert_at:]


def drop_ui_test_parallelizable(content, ui_ids):
    def fix(match):
        reference = match.group(0)
        blueprint = re.search(r'BlueprintIdentifier = "([^"]+)"', reference)
        if blueprint and blueprint.group(1) in ui_ids:
            return UI_TEST_PARALLELIZABLE_NO.sub(r"\1>", reference, count=1)
        return reference

    return TESTABLE_REFERENCE.sub(fix, content)


def main():
    ui_ids = ui_test_target_ids()
    for pattern in SCHEME_GLOBS:
        for path in glob.glob(pattern):
            with open(path) as f:
                original = f.read()
            content = TEST_ACTION.sub(lambda m: move_testables_last(m.group(1)), original)
            content = drop_ui_test_parallelizable(content, ui_ids)
            if content != original:
                with open(path, "w") as f:
                    f.write(content)


if __name__ == "__main__":
    main()
