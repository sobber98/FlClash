import 'dart:async';

import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/v2board.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ticketPollInterval = Duration(seconds: 30);

class V2BoardTicketReminderState {
  final bool isPolling;
  final DateTime? lastCheckedAt;
  final List<int> pendingReplyTicketIds;

  const V2BoardTicketReminderState({
    this.isPolling = false,
    this.lastCheckedAt,
    this.pendingReplyTicketIds = const [],
  });

  int get pendingReplyCount => pendingReplyTicketIds.length;

  bool hasPendingReply(int ticketId) =>
      pendingReplyTicketIds.contains(ticketId);

  V2BoardTicketReminderState copyWith({
    bool? isPolling,
    DateTime? lastCheckedAt,
    List<int>? pendingReplyTicketIds,
  }) {
    return V2BoardTicketReminderState(
      isPolling: isPolling ?? this.isPolling,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      pendingReplyTicketIds:
          pendingReplyTicketIds ?? this.pendingReplyTicketIds,
    );
  }
}

final v2boardTicketsProvider =
    AsyncNotifierProvider<V2BoardTicketsNotifier, List<V2BoardTicket>>(
      V2BoardTicketsNotifier.new,
    );

final v2boardTicketReminderProvider =
    NotifierProvider<V2BoardTicketReminderNotifier, V2BoardTicketReminderState>(
      V2BoardTicketReminderNotifier.new,
    );

final v2boardTicketPollingControllerProvider =
    Provider<V2BoardTicketPollingController>((ref) {
      final controller = V2BoardTicketPollingController(ref);
      final props = ref.read(v2boardSettingProvider);
      if (props != null && props.isLoggedIn) {
        controller.start();
        unawaited(controller.refreshNow(notifyOnNewReplies: false));
      }
      ref.listen<V2BoardProps?>(v2boardSettingProvider, (previous, next) {
        if (next != null && next.isLoggedIn) {
          controller.start();
          unawaited(controller.refreshNow(notifyOnNewReplies: false));
          return;
        }
        controller.stop(resetState: true);
      });
      ref.onDispose(controller.dispose);
      return controller;
    });

class V2BoardTicketsNotifier extends AsyncNotifier<List<V2BoardTicket>> {
  @override
  Future<List<V2BoardTicket>> build() async {
    return _fetch();
  }

  Future<List<V2BoardTicket>> refresh({bool silently = false}) async {
    if (!silently) {
      state = const AsyncLoading();
    }
    try {
      final tickets = await _fetch();
      state = AsyncData(tickets);
      return tickets;
    } catch (error, stackTrace) {
      if (!silently || state is! AsyncData<List<V2BoardTicket>>) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  void clear() {
    state = const AsyncData([]);
  }

  void setTickets(List<V2BoardTicket> tickets) {
    state = AsyncData(List<V2BoardTicket>.unmodifiable(tickets));
  }

  Future<List<V2BoardTicket>> _fetch() async {
    final api = ref.read(v2boardApiClientProvider);
    final props = ref.read(v2boardSettingProvider);
    if (props == null || !props.isLoggedIn || api == null) {
      return const [];
    }
    return api.fetchTickets();
  }
}

class V2BoardTicketReminderNotifier
    extends Notifier<V2BoardTicketReminderState> {
  @override
  V2BoardTicketReminderState build() {
    return const V2BoardTicketReminderState();
  }

  void setSnapshot({
    required bool isPolling,
    required DateTime lastCheckedAt,
    required List<int> pendingReplyTicketIds,
  }) {
    state = V2BoardTicketReminderState(
      isPolling: isPolling,
      lastCheckedAt: lastCheckedAt,
      pendingReplyTicketIds: List<int>.unmodifiable(pendingReplyTicketIds),
    );
  }

  void setPolling(bool isPolling) {
    state = state.copyWith(isPolling: isPolling);
  }

  void clear() {
    state = const V2BoardTicketReminderState();
  }
}

class V2BoardTicketPollingController {
  final Ref ref;

  Timer? _timer;
  bool _hydrated = false;
  bool _refreshing = false;
  final Map<int, String> _knownTicketFingerprints = <int, String>{};
  final Map<int, String> _knownReplyFingerprints = <int, String>{};

  V2BoardTicketPollingController(this.ref);

  bool get _isPolling => _timer?.isActive ?? false;

  bool get _isAppInteractive {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  void start() {
    if (_isPolling) {
      ref.read(v2boardTicketReminderProvider.notifier).setPolling(true);
      return;
    }
    _timer = Timer.periodic(_ticketPollInterval, (_) {
      unawaited(refreshNow());
    });
    ref.read(v2boardTicketReminderProvider.notifier).setPolling(true);
  }

  void stop({bool resetState = false}) {
    _timer?.cancel();
    _timer = null;
    if (resetState) {
      _hydrated = false;
      _knownTicketFingerprints.clear();
      _knownReplyFingerprints.clear();
      ref.read(v2boardTicketReminderProvider.notifier).clear();
      return;
    }
    ref.read(v2boardTicketReminderProvider.notifier).setPolling(false);
  }

  Future<void> refreshNow({bool notifyOnNewReplies = true}) async {
    if (_refreshing) {
      return;
    }
    final props = ref.read(v2boardSettingProvider);
    final api = ref.read(v2boardApiClientProvider);
    if (props == null || !props.isLoggedIn || api == null) {
      stop(resetState: true);
      return;
    }
    if (!_isAppInteractive) {
      return;
    }
    _refreshing = true;
    try {
      final tickets = await ref
          .read(v2boardTicketsProvider.notifier)
          .refresh(silently: true);
      final resolvedTickets = List<V2BoardTicket>.from(
        tickets,
        growable: false,
      );
      final pendingReplyTicketIds = <int>[];
      final newReplyTickets = <V2BoardTicket>[];

      for (var index = 0; index < resolvedTickets.length; index++) {
        var ticket = resolvedTickets[index];
        final previousTicketFingerprint = _knownTicketFingerprints[ticket.id];
        final shouldLoadDetail =
            !ticket.isClosed &&
            (ticket.messages.isEmpty ||
                ticket.statusFingerprint != previousTicketFingerprint);
        if (shouldLoadDetail) {
          try {
            ticket = await api.getTicketDetail(ticket.id);
            resolvedTickets[index] = ticket;
          } catch (_) {}
        }
        _knownTicketFingerprints[ticket.id] = ticket.statusFingerprint;
        if (ticket.hasPendingStaffReply) {
          pendingReplyTicketIds.add(ticket.id);
          final replyFingerprint = ticket.latestReplyFingerprint;
          final previousReplyFingerprint = _knownReplyFingerprints[ticket.id];
          if (_hydrated &&
              notifyOnNewReplies &&
              replyFingerprint.isNotEmpty &&
              previousReplyFingerprint != replyFingerprint) {
            newReplyTickets.add(ticket);
          }
          _knownReplyFingerprints[ticket.id] = replyFingerprint;
          continue;
        }
        _knownReplyFingerprints.remove(ticket.id);
      }

      final activeTicketIds = resolvedTickets
          .map((ticket) => ticket.id)
          .toSet();
      _knownTicketFingerprints.removeWhere(
        (ticketId, _) => !activeTicketIds.contains(ticketId),
      );
      _knownReplyFingerprints.removeWhere(
        (ticketId, _) => !activeTicketIds.contains(ticketId),
      );

      ref.read(v2boardTicketsProvider.notifier).setTickets(resolvedTickets);
      ref
          .read(v2boardTicketReminderProvider.notifier)
          .setSnapshot(
            isPolling: _isPolling,
            lastCheckedAt: DateTime.now(),
            pendingReplyTicketIds: pendingReplyTicketIds,
          );

      if (_hydrated && newReplyTickets.isNotEmpty) {
        final firstSubject = newReplyTickets.first.subject.trim();
        final label = firstSubject.isEmpty
            ? '工单 #${newReplyTickets.first.id}'
            : firstSubject;
        final message = newReplyTickets.length == 1
            ? '$label 收到客服新回复'
            : '$label 等 ${newReplyTickets.length} 条工单收到客服新回复';
        globalState.showNotifier(message);
      }
      _hydrated = true;
    } catch (_) {
      ref.read(v2boardTicketReminderProvider.notifier).setPolling(_isPolling);
    } finally {
      _refreshing = false;
    }
  }

  void dispose() {
    stop();
  }
}

final v2boardOpenTicketCountProvider = Provider<int>((ref) {
  final ticketsState = ref.watch(v2boardTicketsProvider);
  final tickets = ticketsState is AsyncData<List<V2BoardTicket>>
      ? ticketsState.value
      : const <V2BoardTicket>[];
  return tickets.where((ticket) => !ticket.isClosed).length;
});
