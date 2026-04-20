import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/v2board.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final v2boardTicketsProvider =
    AsyncNotifierProvider<V2BoardTicketsNotifier, List<V2BoardTicket>>(
      V2BoardTicketsNotifier.new,
    );

class V2BoardTicketsNotifier extends AsyncNotifier<List<V2BoardTicket>> {
  @override
  Future<List<V2BoardTicket>> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  void clear() {
    state = const AsyncData([]);
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

final v2boardOpenTicketCountProvider = Provider<int>((ref) {
  final ticketsState = ref.watch(v2boardTicketsProvider);
  final tickets = ticketsState is AsyncData<List<V2BoardTicket>>
      ? ticketsState.value
      : const <V2BoardTicket>[];
  return tickets.where((ticket) => !ticket.isClosed).length;
});
