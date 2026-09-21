import copy
import os
import subprocess
import tempfile
import unittest

from lib.settings import install_hooks, remove_hooks


class SettingsTests(unittest.TestCase):
    def test_install_is_idempotent_and_preserves_unrelated_hooks(self):
        original = {
            "hooks": {
                "Stop": [{"hooks": [{"type": "command", "command": "other-stop"}]}],
                "Notification": [{"hooks": [{"type": "command", "command": "other-notification"}]}],
            }
        }
        once = install_hooks(copy.deepcopy(original), "/x/notify")
        twice = install_hooks(copy.deepcopy(once), "/x/notify")
        self.assertEqual(once, twice)
        self.assertIn("other-stop", str(twice))
        self.assertIn("other-notification", str(twice))

    def test_remove_keeps_unrelated_hooks(self):
        settings = install_hooks({"hooks": {"Stop": [{"hooks": [{"command": "other"}]}]}}, "/x/notify")
        removed = remove_hooks(settings)
        self.assertIn("other", str(removed))
        self.assertNotIn("aerospace-agent-notify", str(removed))

    def test_preserves_existing_empty_and_multiple_hook_groups(self):
        original = {"hooks": {"Stop": [{"hooks": []}, {"hooks": [{"command": "first"}, {"command": "second"}]}]}}
        result = remove_hooks(install_hooks(original, "/x/notify"))
        self.assertEqual(result["hooks"]["Stop"], original["hooks"]["Stop"])

    def test_invalid_json_does_not_write_output(self):
        with tempfile.TemporaryDirectory() as directory:
            source = os.path.join(directory, "settings.json")
            output = os.path.join(directory, "output.json")
            with open(source, "w") as file:
                file.write("not json")
            result = subprocess.run(["python3", "lib/settings.py", "remove", source, output], check=False)
            self.assertEqual(result.returncode, 2)
            self.assertFalse(os.path.exists(output))
            with open(source) as file:
                self.assertEqual(file.read(), "not json")


if __name__ == "__main__":
    unittest.main()
