import datetime as dt
import json
import unittest

import spm_snapshot as spm


class PackageUrlTest(unittest.TestCase):
    def test_https_location_with_version(self):
        self.assertEqual(spm.package_url("https://github.com/apollographql/apollo-ios", {"version": "2.1.1"}),
                         "pkg:swift/github.com/apollographql/apollo-ios@2.1.1")

    def test_git_suffix_is_dropped_and_revision_is_used_without_a_version(self):
        self.assertEqual(spm.package_url("https://github.com/SVGKit/SVGKit.git", {"revision": "0242192", "branch": "main"}),
                         "pkg:swift/github.com/SVGKit/SVGKit@0242192")

    def test_ssh_location(self):
        self.assertEqual(spm.package_url("git@github.com:HedvigInsurance/umbrella.git", {"version": "0.0.1"}),
                         "pkg:swift/github.com/HedvigInsurance/umbrella@0.0.1")

    def test_local_package_has_no_purl(self):
        self.assertIsNone(spm.package_url("../LocalModules/Logger", {}))


class SnapshotTest(unittest.TestCase):
    def test_version_3_resolved(self):
        resolved = {"version": 3, "pins": [
            {"identity": "snapkit", "kind": "remoteSourceControl", "location": "https://github.com/SnapKit/SnapKit",
             "state": {"revision": "abc", "version": "5.7.1"}},
            {"identity": "apollo-ios", "kind": "remoteSourceControl", "location": "https://github.com/apollographql/apollo-ios",
             "state": {"revision": "def", "version": "2.1.1"}},
        ]}
        result = spm.snapshot(resolved, "App.xcworkspace/xcshareddata/swiftpm/Package.resolved", "sha1", "refs/heads/master",
                              "spm-dependency-submission/submit", "42", now=dt.datetime(2026, 9, 28, tzinfo=dt.timezone.utc))
        manifest = result["manifests"]["App.xcworkspace/xcshareddata/swiftpm/Package.resolved"]
        self.assertEqual(list(manifest["resolved"]), ["pkg:swift/github.com/SnapKit/SnapKit@5.7.1",
                                                      "pkg:swift/github.com/apollographql/apollo-ios@2.1.1"])
        self.assertEqual(manifest["resolved"]["pkg:swift/github.com/SnapKit/SnapKit@5.7.1"],
                         {"package_url": "pkg:swift/github.com/SnapKit/SnapKit@5.7.1", "scope": "runtime"})
        self.assertEqual((result["sha"], result["ref"], result["job"], result["scanned"]),
                         ("sha1", "refs/heads/master", {"correlator": "spm-dependency-submission/submit", "id": "42"},
                          "2026-09-28T00:00:00+00:00"))
        self.assertEqual(result["version"], 0)

    def test_version_1_resolved(self):
        resolved = {"version": 1, "object": {"pins": [
            {"package": "Kingfisher", "repositoryURL": "https://github.com/onevcat/Kingfisher.git",
             "state": {"branch": None, "revision": "r", "version": "8.9.0"}},
        ]}}
        result = spm.snapshot(resolved, "Package.resolved", "s", "r", "j", "1")
        self.assertEqual(list(result["manifests"]["Package.resolved"]["resolved"]), ["pkg:swift/github.com/onevcat/Kingfisher@8.9.0"])

    def test_snapshot_is_valid_json_for_the_api(self):
        json.dumps(spm.snapshot({"pins": []}, "Package.resolved", "s", "r", "j", "1"))


if __name__ == "__main__":
    unittest.main()
