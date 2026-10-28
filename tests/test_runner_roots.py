"""Root selection and quota retry without filling or deleting shared temporary space."""

import contextlib
import errno
import io
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import run_godot_check as runner  # noqa: E402


class RunnerRoots(unittest.TestCase):
    def test_candidate_policy(self):
        self.assertEqual(runner.root_candidates("/tmp"), [Path("/tmp"), Path("/var/tmp")])
        self.assertEqual(runner.root_candidates("/var/tmp"), [Path("/var/tmp"), Path("/tmp")])
        self.assertEqual(runner.root_candidates("/not/allowed"), [Path("/var/tmp"), Path("/tmp")])

    def test_unavailable_roots_fail_before_import(self):
        with tempfile.TemporaryDirectory(dir="/var/tmp", prefix="wick-roots-missing-") as temp:
            missing = [Path(temp) / "missing-a", Path(temp) / "missing-b"]
            with mock.patch.object(runner, "root_candidates", return_value=missing), \
                 mock.patch.object(runner, "discover", return_value=[Path("test_fixture.gd")]), \
                 mock.patch.object(runner, "ensure_import") as imported, \
                 mock.patch.object(sys, "argv", ["runner"]), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(runner.main(), 1)
            imported.assert_not_called()

    def _retry(self, phase):
        with tempfile.TemporaryDirectory(dir="/var/tmp", prefix="wick-root-unit-") as temp:
            first = Path(temp) / "first"
            second = Path(temp) / "second"
            first.mkdir()
            second.mkdir()
            roots_seen = []

            def probe(root):
                roots_seen.append(root.parent)
                if phase == "probe" and root.parent == first:
                    raise OSError(errno.EDQUOT, "simulated quota")

            def run_one(file, godot, root):
                if root.parent == first and phase == "late":
                    raise OSError(errno.ENOSPC, "simulated full disk")
                if root.parent == first and phase == "reported":
                    return file.stem, False, 0.0, "Disk quota exceeded"
                if root.parent == first and phase == "nonspace":
                    raise FileNotFoundError(errno.ENOENT, "missing Godot binary")
                return file.stem, True, 0.0, "ok"

            output = io.StringIO()
            with mock.patch.object(runner, "root_candidates", return_value=[first, second]), \
                 mock.patch.object(runner, "discover", return_value=[Path("test_fixture.gd")]), \
                 mock.patch.object(runner, "probe_space", side_effect=probe), \
                 mock.patch.object(runner, "ensure_import", return_value=True) as imported, \
                 mock.patch.object(runner, "run_one", side_effect=run_one), \
                 mock.patch.object(sys, "argv", ["runner"]), \
                 contextlib.redirect_stdout(output):
                self.assertEqual(runner.main(), 0 if phase == "probe" else 1)
            self.assertEqual(roots_seen, [first, second] if phase == "probe" else [first])
            self.assertEqual(imported.call_count, 1)
            if phase == "probe":
                self.assertIn("trying next root", output.getvalue())
            else:
                self.assertNotIn("trying next root", output.getvalue())

    def test_quota_before_import(self):
        self._retry("probe")

    def test_marker_quota_falls_back_before_import(self):
        with tempfile.TemporaryDirectory(dir="/var/tmp", prefix="wick-marker-unit-") as temp:
            first, second = Path(temp) / "first", Path(temp) / "second"
            first.mkdir()
            second.mkdir()
            original = Path.write_text

            def write(path, *args, **kwargs):
                if path.name == ".wick-test-root" and path.parent.parent == first:
                    raise OSError(errno.EDQUOT, "simulated marker quota")
                return original(path, *args, **kwargs)

            with mock.patch.object(runner, "root_candidates", return_value=[first, second]), \
                 mock.patch.object(runner, "discover", return_value=[Path("test_fixture.gd")]), \
                 mock.patch.object(runner, "probe_space"), \
                 mock.patch.object(runner, "ensure_import", return_value=True) as imported, \
                 mock.patch.object(runner, "run_one", return_value=("test_fixture", True, 0.0, "ok")), \
                 mock.patch.object(Path, "write_text", autospec=True, side_effect=write), \
                 mock.patch.object(sys, "argv", ["runner"]), \
                 contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(runner.main(), 0)
            self.assertEqual(imported.call_count, 1)
            self.assertEqual(imported.call_args.args[2].parent, second)

    def test_disk_full_after_test_start(self):
        self._retry("late")

    def test_child_reports_quota_after_test_start(self):
        self._retry("reported")

    def test_missing_binary_is_not_misreported_as_root_failure(self):
        self._retry("nonspace")

    def test_mixed_quota_and_other_failure_has_no_retry(self):
        for quota_kind in ("reported", "exception", "ambiguous", "crash"):
            with self.subTest(quota_kind=quota_kind), tempfile.TemporaryDirectory(
                dir="/var/tmp", prefix="wick-mixed-unit-"
            ) as temp:
                first, second = Path(temp) / "first", Path(temp) / "second"
                first.mkdir()
                second.mkdir()
                files = [Path("test_quota.gd"), Path("test_other.gd")]
                roots_seen = []

                def probe(root):
                    roots_seen.append(root.parent)

                def run_one(file, godot, root):
                    if root.parent == first and file.stem == "test_quota":
                        if quota_kind == "exception":
                            raise OSError(errno.EDQUOT, "simulated quota")
                        if quota_kind == "ambiguous":
                            return file.stem, False, 0.0, "Disk quota exceeded\nFAILED: combat"
                        if quota_kind == "crash":
                            return file.stem, False, 0.0, "Disk quota exceeded\nexit=-9"
                        return file.stem, False, 0.0, "Disk quota exceeded"
                    if root.parent == first and file.stem == "test_other":
                        return file.stem, False, 0.0, "FAILED: independent assertion"
                    return file.stem, True, 0.0, "ok"

                output = io.StringIO()
                with mock.patch.object(runner, "root_candidates", return_value=[first, second]), \
                     mock.patch.object(runner, "discover", return_value=files), \
                     mock.patch.object(runner, "probe_space", side_effect=probe), \
                     mock.patch.object(runner, "ensure_import", return_value=True), \
                     mock.patch.object(runner, "run_one", side_effect=run_one), \
                     mock.patch.object(sys, "argv", ["runner", "-j", "2"]), \
                     contextlib.redirect_stdout(output):
                    self.assertEqual(runner.main(), 1)
                self.assertEqual(roots_seen, [first])
                self.assertNotIn("trying next root", output.getvalue())
                self.assertIn("test_other", output.getvalue().split("failed in")[-1])
                self.assertIn("test_quota", output.getvalue().split("failed in")[-1])

    def test_import_quota_with_other_diagnostic_has_no_retry(self):
        with tempfile.TemporaryDirectory(dir="/var/tmp", prefix="wick-import-mixed-") as temp:
            first, second = Path(temp) / "first", Path(temp) / "second"
            first.mkdir()
            second.mkdir()
            output = io.StringIO()
            with mock.patch.object(runner, "root_candidates", return_value=[first, second]), \
                 mock.patch.object(runner, "discover", return_value=[Path("test_fixture.gd")]), \
                 mock.patch.object(runner, "probe_space") as probe, \
                 mock.patch.object(runner, "ensure_import", side_effect=OSError(
                     errno.ENOSPC, "Disk quota exceeded; separate import error")) as imported, \
                 mock.patch.object(sys, "argv", ["runner"]), \
                 contextlib.redirect_stdout(output):
                self.assertEqual(runner.main(), 1)
            self.assertEqual(probe.call_count, 1)
            self.assertEqual(imported.call_count, 1)
            self.assertIn("separate import error", output.getvalue())
            self.assertNotIn("trying next root", output.getvalue())

    def test_import_quota_error_is_not_accepted(self):
        with tempfile.TemporaryDirectory(dir="/var/tmp", prefix="wick-import-unit-") as temp:
            for code in (0, -9):
                result = SimpleNamespace(
                    returncode=code, stdout="SCRIPT ERROR: separate problem", stderr="Disk quota exceeded"
                )
                output = io.StringIO()
                with mock.patch.object(runner, "isolated_env", return_value={"HOME": temp}), \
                     mock.patch.object(runner.subprocess, "run", return_value=result), \
                     contextlib.redirect_stdout(output):
                    with self.assertRaises(OSError) as error:
                        runner.ensure_import(["godot"], True, Path(temp))
                self.assertEqual(error.exception.errno, errno.ENOSPC)
                self.assertIn("separate problem", output.getvalue())

    def test_test_process_quota_with_success_or_crash_is_not_accepted(self):
        for code in (0, -9):
            with self.subTest(code=code), tempfile.TemporaryDirectory(
                dir="/var/tmp", prefix="wick-test-unit-"
            ) as temp:
                root = Path(temp)
                (root / ".wick-test-root").write_text("token", encoding="ascii")
                fixture = root / "test_fake.gd"
                fixture.write_text("extends TestCase\n", encoding="utf-8")
                result = SimpleNamespace(returncode=code, stdout="", stderr="Disk quota exceeded")
                with mock.patch.object(runner.subprocess, "run", return_value=result):
                    _, ok, _, output = runner.run_one(fixture, ["godot"], root)
                self.assertFalse(ok)
                self.assertIn("Disk quota exceeded", output)
                if code == -9:
                    self.assertIn("exit=-9", output)


if __name__ == "__main__":
    unittest.main()
