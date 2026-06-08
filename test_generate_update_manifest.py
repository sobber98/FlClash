import unittest

import generate_update_manifest as manifest


class UpdateManifestAssetTest(unittest.TestCase):
    def test_classifies_current_normalized_update_assets(self):
        self.assertEqual(
            manifest.asset_key_for_file('v2box-android.apk'),
            'android',
        )
        self.assertEqual(
            manifest.asset_key_for_file('v2box-windows-amd64-setup.exe'),
            'windows-amd64',
        )
        self.assertEqual(
            manifest.asset_key_for_file('v2box-windows-arm64-setup.exe'),
            'windows-arm64',
        )

    def test_classifies_legacy_versioned_update_assets(self):
        self.assertEqual(
            manifest.asset_key_for_file('FlClash-0.8.92-android.apk'),
            'android',
        )
        self.assertEqual(
            manifest.asset_key_for_file('FlClash-0.8.92-windows-amd64-setup.exe'),
            'windows-amd64',
        )

    def test_requires_windows_arch_marker(self):
        self.assertIsNone(manifest.asset_key_for_file('v2box.exe'))
        self.assertTrue(manifest.is_update_package_candidate('v2box.exe'))

    def test_ignores_non_update_artifacts(self):
        self.assertIsNone(manifest.asset_key_for_file('v2box-windows-amd64.zip'))
        self.assertFalse(
            manifest.is_update_package_candidate('v2box-windows-amd64.zip'),
        )


if __name__ == '__main__':
    unittest.main()
