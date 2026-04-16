import 'dart:async';

import 'package:app_links/app_links.dart';

import 'print.dart';

typedef InstallConfigCallBack = void Function(String url);
typedef AppLinkCallBack = FutureOr<void> Function(Uri uri);

class LinkManager {
  static LinkManager? _instance;
  late AppLinks _appLinks;
  StreamSubscription? subscription;
  final _uriStreamController = StreamController<Uri>.broadcast();
  Uri? lastUri;

  LinkManager._internal() {
    _appLinks = AppLinks();
  }

  Stream<Uri> get uriStream => _uriStreamController.stream;

  Future<void> initAppLinksListen(AppLinkCallBack onUri) async {
    commonPrint.log('initAppLinksListen');
    destroy();
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _dispatchUri(initialUri, onUri);
    }
    subscription = _appLinks.uriLinkStream.listen(
      (uri) async {
        await _dispatchUri(uri, onUri);
      },
    );
  }

  Future<void> _dispatchUri(Uri uri, AppLinkCallBack onUri) async {
    commonPrint.log('onAppLink: $uri');
    lastUri = uri;
    if (!_uriStreamController.isClosed) {
      _uriStreamController.add(uri);
    }
    await onUri(uri);
  }

  void destroy() {
    if (subscription != null) {
      subscription?.cancel();
      subscription = null;
    }
  }

  factory LinkManager() {
    _instance ??= LinkManager._internal();
    return _instance!;
  }
}

final linkManager = LinkManager();
