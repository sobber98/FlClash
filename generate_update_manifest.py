from __future__ import annotations

import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote


ASSET_SUFFIX_TO_KEY = {
    '-android.apk': 'android',
    '-windows-amd64-setup.exe': 'windows-amd64',
    '-windows-arm64-setup.exe': 'windows-arm64',
}


def compute_sha256(file_path: Path) -> str:
    digest = hashlib.sha256()
    with file_path.open('rb') as file_handle:
        for chunk in iter(lambda: file_handle.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def write_sha256_file(dist_dir: Path, file_path: Path) -> str:
    digest = compute_sha256(file_path)
    relative_path = file_path.relative_to(dist_dir).as_posix()
    checksum_path = Path(f'{file_path}.sha256')
    checksum_path.write_text(f'{digest}  ./{relative_path}\n', encoding='utf-8')
    return digest


def parse_release_notes(release_notes_path: Path) -> list[str]:
    if not release_notes_path.exists():
        return []
    notes: list[str] = []
    for line in release_notes_path.read_text(encoding='utf-8').splitlines():
        stripped = line.strip()
        if stripped.startswith('- '):
            notes.append(stripped[2:].strip())
    return notes


def iso_utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')


def normalize_version(tag: str) -> str:
    return tag[1:] if tag.startswith('v') else tag


def build_asset_url(base_url: str, file_name: str) -> str:
    return f"{base_url.rstrip('/')}/{quote(file_name)}"


def resolve_asset_base_url() -> str:
    asset_base_url = os.getenv('UPDATE_ASSET_BASE_URL', '').strip()
    if asset_base_url:
        return asset_base_url

    s3_endpoint = os.getenv('S3_ENDPOINT', '').strip()
    s3_bucket = os.getenv('S3_BUCKET', '').strip()
    if s3_endpoint and s3_bucket:
        return f"{s3_endpoint.rstrip('/')}/{quote(s3_bucket)}"

    return ''


def main() -> int:
    dist_dir = Path(os.getenv('DIST_DIR', 'dist'))
    release_notes_path = Path(os.getenv('RELEASE_NOTES_FILE', 'release.md'))
    manifest_name = os.getenv('UPDATE_MANIFEST_NAME', 'latest.json')
    tag = os.getenv('TAG') or os.getenv('GITHUB_REF_NAME') or ''
    asset_base_url = resolve_asset_base_url()
    release_date = os.getenv('UPDATE_RELEASE_DATE', '').strip() or iso_utc_now()
    force_update = os.getenv('UPDATE_FORCE', '').strip().lower() in {
        '1',
        'true',
        'yes',
        'on',
    }

    if not tag:
        print('TAG or GITHUB_REF_NAME is required', file=sys.stderr)
        return 1
    if not asset_base_url:
        print(
            'UPDATE_ASSET_BASE_URL or S3_ENDPOINT + S3_BUCKET is required to generate latest.json',
            file=sys.stderr,
        )
        return 1
    if not dist_dir.exists():
        print(f'Dist directory not found: {dist_dir}', file=sys.stderr)
        return 1

    files = sorted(
        path
        for path in dist_dir.rglob('*')
        if path.is_file() and path.name != manifest_name and not path.name.endswith('.sha256')
    )

    if not files:
        print(f'No distributable files found under {dist_dir}', file=sys.stderr)
        return 1

    file_hashes: dict[Path, str] = {}
    for file_path in files:
        file_hashes[file_path] = write_sha256_file(dist_dir, file_path)

    assets: dict[str, dict[str, object]] = {}
    for file_path, digest in file_hashes.items():
        file_name = file_path.name
        lower_name = file_name.lower()
        for suffix, asset_key in ASSET_SUFFIX_TO_KEY.items():
            if lower_name.endswith(suffix):
                assets[asset_key] = {
                    'url': build_asset_url(asset_base_url, file_name),
                    'sha256': digest,
                    'size': file_path.stat().st_size,
                }
                break

    if not assets:
        print(
            'No Android/Windows update packages were found in dist',
            file=sys.stderr,
        )
        return 1

    changelog_entries = parse_release_notes(release_notes_path)
    changelog = (
        {'en': changelog_entries, 'zh_CN': changelog_entries}
        if changelog_entries
        else {}
    )

    manifest = {
        'version': normalize_version(tag),
        'releaseDate': release_date,
        'forceUpdate': force_update,
        'changelog': changelog,
        'assets': assets,
    }

    manifest_path = dist_dir / manifest_name
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )
    write_sha256_file(dist_dir, manifest_path)
    print(f'Generated {manifest_path}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())