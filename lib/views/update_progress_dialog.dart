import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:v2box/common/common.dart';
import 'package:v2box/models/models.dart';
import 'package:v2box/widgets/dialog.dart';
import 'package:flutter/material.dart';

enum _UpdateProgressStatus { downloading, verifying, installing, failed }

typedef UpdatePackageDownloader =
    Future<File> Function({
      required UpdateAsset asset,
      required void Function(int received, int total) onProgress,
      CancelToken? cancelToken,
    });
typedef UpdatePackageVerifier =
    Future<bool> Function(File file, String expectedSha256);
typedef UpdatePackageInstaller = Future<void> Function(File file);

class UpdateProgressDialog extends StatefulWidget {
  final String version;
  final UpdateAsset asset;
  final bool forceUpdate;
  final UpdatePackageDownloader downloadPackage;
  final UpdatePackageVerifier verifyPackage;
  final UpdatePackageInstaller installPackage;

  const UpdateProgressDialog({
    super.key,
    required this.version,
    required this.asset,
    required this.forceUpdate,
    this.downloadPackage = AppUpdater.downloadPackage,
    this.verifyPackage = AppUpdater.verifyPackage,
    this.installPackage = AppUpdater.installPackage,
  });

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  static const _progressUpdateInterval = Duration(milliseconds: 120);

  CancelToken? _cancelToken;
  _UpdateProgressStatus _status = _UpdateProgressStatus.downloading;
  int _received = 0;
  int _total = 0;
  int _speed = 0;
  DateTime? _startedAt;
  DateTime? _lastProgressAt;
  int _lastProgressBytes = 0;
  final _packageCache = AppUpdatePackageCache();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startUpdate();
    });
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _startUpdate() async {
    _cancelToken?.cancel();
    final reusablePackage = _packageCache.reusableFile;
    final shouldReusePackage = reusablePackage != null;
    final token = shouldReusePackage ? null : CancelToken();
    setState(() {
      _cancelToken = token;
      _status = shouldReusePackage
          ? _UpdateProgressStatus.installing
          : _UpdateProgressStatus.downloading;
      if (!shouldReusePackage) {
        _received = 0;
        _total = 0;
        _speed = 0;
        _startedAt = DateTime.now();
        _lastProgressAt = null;
        _lastProgressBytes = 0;
      }
      _error = null;
    });
    try {
      File file;
      if (shouldReusePackage) {
        file = reusablePackage;
      } else {
        file = await widget.downloadPackage(
          asset: widget.asset,
          cancelToken: token,
          onProgress: _handleProgress,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _status = _UpdateProgressStatus.verifying;
        });
        final verified = await widget.verifyPackage(file, widget.asset.sha256);
        if (!verified) {
          await file.safeDelete();
          _packageCache.clear();
          if (!mounted) {
            return;
          }
          setState(() {
            _status = _UpdateProgressStatus.failed;
            _error = appLocalizations.verifyFailed;
          });
          return;
        }
        _packageCache.rememberVerified(file);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _UpdateProgressStatus.installing;
      });
      await widget.installPackage(file);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (mounted) {
          Navigator.of(context).pop(false);
        }
        return;
      }
      _packageCache.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _UpdateProgressStatus.failed;
        _error = appLocalizations.downloadFailed;
      });
    } on AppUpdateException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _UpdateProgressStatus.failed;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _UpdateProgressStatus.failed;
        _error = e.toString();
      });
    }
  }

  void _handleProgress(int received, int total) {
    if (!mounted) {
      return;
    }
    final now = DateTime.now();
    final lastProgressAt = _lastProgressAt;
    final lastProgress = _total > 0 ? (_received * 100 ~/ _total) : -1;
    final nextProgress = total > 0 ? (received * 100 ~/ total) : lastProgress;
    final shouldUpdate =
        lastProgressAt == null ||
        now.difference(lastProgressAt) >= _progressUpdateInterval ||
        received == total ||
        nextProgress != lastProgress;
    if (!shouldUpdate) {
      return;
    }
    final elapsed = lastProgressAt == null
        ? now.difference(_startedAt ?? now).inMilliseconds.clamp(1, 1 << 31)
        : now.difference(lastProgressAt).inMilliseconds.clamp(1, 1 << 31);
    final speedBytes = lastProgressAt == null
        ? received
        : received - _lastProgressBytes;
    setState(() {
      _received = received;
      _total = total;
      _speed = ((speedBytes * 1000) / elapsed).round();
      _lastProgressAt = now;
      _lastProgressBytes = received;
    });
  }

  void _handleCancel() {
    _cancelToken?.cancel();
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(value >= 100 || index == 0 ? 0 : 1)} ${units[index]}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? _received / _total : null;
    final versionLabel = widget.version.startsWith('v')
        ? widget.version
        : 'v${widget.version}';
    final statusText = switch (_status) {
      _UpdateProgressStatus.downloading => appLocalizations.downloadingUpdate,
      _UpdateProgressStatus.verifying => appLocalizations.verifyingFile,
      _UpdateProgressStatus.installing => appLocalizations.installReady,
      _UpdateProgressStatus.failed => _error ?? appLocalizations.downloadFailed,
    };
    return CommonDialog(
      title: '${appLocalizations.discoverNewVersion} $versionLabel',
      overrideScroll: true,
      actions: [
        if (_status == _UpdateProgressStatus.failed) ...[
          if (!widget.forceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(appLocalizations.cancel),
            ),
          TextButton(
            onPressed: _startUpdate,
            child: Text(appLocalizations.retry),
          ),
        ] else if (!widget.forceUpdate &&
            _status == _UpdateProgressStatus.downloading) ...[
          TextButton(
            onPressed: _handleCancel,
            child: Text(appLocalizations.cancel),
          ),
        ],
      ],
      child: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusText, style: context.textTheme.bodyLarge),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            if (_status == _UpdateProgressStatus.downloading) ...[
              Text(
                '${progress == null ? 0 : (progress * 100).toStringAsFixed(0)}%',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatBytes(_received)} / ${_formatBytes(_total)}',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${appLocalizations.download}: ${_formatBytes(_speed)}/s',
                style: context.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
