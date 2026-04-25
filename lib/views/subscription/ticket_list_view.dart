import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ticketsBackground = Color(0xFFF5F6F8);
const _cardTextColor = Color(0xFF0F172A);

class TicketListView extends ConsumerStatefulWidget {
  const TicketListView({super.key});

  @override
  ConsumerState<TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends ConsumerState<TicketListView> {
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    await ref.read(v2boardTicketsProvider.notifier).refresh();
  }

  Future<void> _openComposer() async {
    // Refresh from server first to avoid stale-cache false negatives
    await _refresh();
    if (!mounted) return;
    final tickets = ref.read(v2boardTicketsProvider).asData?.value;
    final hasOpenTicket = tickets?.any((ticket) => !ticket.isClosed) ?? false;
    if (hasOpenTicket) {
      globalState.showNotifier('存在其它工单尚未处理，请先等待回复或关闭当前工单');
      return;
    }
    final draft = await globalState.showCommonDialog<_TicketDraft>(
      context: context,
      child: const _TicketComposerDialog(),
    );
    if (!mounted || draft == null) {
      return;
    }
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      globalState.showNotifier('V2Board 会话不可用，请重新登录');
      return;
    }
    setState(() {
      _creating = true;
    });
    try {
      final created = await api.createTicket(
        subject: draft.subject,
        level: draft.level,
        message: draft.message,
      );
      if (!created) {
        throw const V2BoardApiException('工单创建失败');
      }
      await _refresh();
      if (!mounted) {
        return;
      }
      globalState.showNotifier('工单已创建');
    } catch (error) {
      // Refresh so user sees any open ticket that blocked creation
      await _refresh();
      if (!mounted) {
        return;
      }
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: error.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creating = false;
        });
      }
    }
  }

  Future<void> _openTicket(V2BoardTicket ticket) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TicketDetailView(ticketId: ticket.id)),
    );
    if (!mounted) {
      return;
    }
    await _refresh();
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) {
      return '未知时间';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  String _levelText(int level) {
    return switch (level) {
      0 => '低优先级',
      1 => '中优先级',
      2 => '高优先级',
      _ => '未知优先级',
    };
  }

  String _statusText(int status) {
    return switch (status) {
      0 => '处理中',
      1 => '已关闭',
      _ => '未知状态',
    };
  }

  Color _statusColor(int status) {
    return switch (status) {
      0 => const Color(0xFF2563EB),
      1 => const Color(0xFF6B7280),
      _ => const Color(0xFF6B7280),
    };
  }

  Color _statusBackground(int status) {
    return switch (status) {
      0 => const Color(0xFFEFF6FF),
      1 => const Color(0xFFF3F4F6),
      _ => const Color(0xFFF3F4F6),
    };
  }

  Color _levelColor(int level) {
    return switch (level) {
      0 => const Color(0xFF047857),
      1 => const Color(0xFFB45309),
      2 => const Color(0xFFB91C1C),
      _ => const Color(0xFF4B5563),
    };
  }

  Color _levelBackground(int level) {
    return switch (level) {
      0 => const Color(0xFFECFDF5),
      1 => const Color(0xFFFFF7ED),
      2 => const Color(0xFFFEF2F2),
      _ => const Color(0xFFF3F4F6),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ticketsState = ref.watch(v2boardTicketsProvider);
    return Scaffold(
      backgroundColor: _ticketsBackground,
      appBar: AppBar(
        backgroundColor: _ticketsBackground,
        elevation: 0,
        centerTitle: false,
        title: const Text('我的工单'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: _creating ? null : _openComposer,
              icon: _creating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
              label: const Text('新建'),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ticketsState.when(
          data: (tickets) {
            final openCount = tickets
                .where((ticket) => !ticket.isClosed)
                .length;
            final closedCount = tickets
                .where((ticket) => ticket.isClosed)
                .length;
            if (tickets.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _TicketSummaryCard(
                    totalCount: 0,
                    openCount: 0,
                    closedCount: 0,
                  ),
                  const SizedBox(height: 16),
                  _TicketEmptyState(onCreate: _creating ? null : _openComposer),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: tickets.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TicketSummaryCard(
                      totalCount: tickets.length,
                      openCount: openCount,
                      closedCount: closedCount,
                    ),
                  );
                }
                final ticket = tickets[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TicketCard(
                    ticket: ticket,
                    statusText: _statusText(ticket.status),
                    statusColor: _statusColor(ticket.status),
                    statusBackground: _statusBackground(ticket.status),
                    levelText: _levelText(ticket.level),
                    levelColor: _levelColor(ticket.level),
                    levelBackground: _levelBackground(ticket.level),
                    timeText: _formatTime(ticket.updatedAt ?? ticket.createdAt),
                    onTap: () => _openTicket(ticket),
                  ),
                );
              },
            );
          },
          error: (error, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const _TicketSummaryCard(
                totalCount: 0,
                openCount: 0,
                closedCount: 0,
              ),
              const SizedBox(height: 16),
              _TicketErrorState(error: error),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class TicketDetailView extends ConsumerStatefulWidget {
  final int ticketId;

  const TicketDetailView({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends ConsumerState<TicketDetailView> {
  final TextEditingController _replyController = TextEditingController();
  V2BoardTicket? _ticket;
  Object? _error;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTicket();
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      setState(() {
        _loading = false;
        _error = 'V2Board 会话不可用，请重新登录';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ticket = await api.getTicketDetail(widget.ticketId);
      if (!mounted) {
        return;
      }
      setState(() {
        _ticket = ticket;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Future<void> _replyTicket() async {
    final message = _replyController.text.trim();
    if (message.isEmpty) {
      globalState.showNotifier('请输入回复内容');
      return;
    }
    final api = ref.read(v2boardApiClientProvider);
    final ticket = _ticket;
    if (api == null || ticket == null) {
      globalState.showNotifier('V2Board 会话不可用，请重新登录');
      return;
    }
    setState(() {
      _submitting = true;
    });
    try {
      final replied = await api.replyTicket(id: ticket.id, message: message);
      if (!replied) {
        throw const V2BoardApiException('工单回复失败');
      }
      _replyController.clear();
      await _loadTicket();
      await ref.read(v2boardTicketsProvider.notifier).refresh();
      if (!mounted) {
        return;
      }
      globalState.showNotifier('工单回复已发送');
    } catch (error) {
      if (!mounted) {
        return;
      }
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: error.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _closeTicket() async {
    final ticket = _ticket;
    if (ticket == null || ticket.isClosed) {
      return;
    }
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      globalState.showNotifier('V2Board 会话不可用，请重新登录');
      return;
    }
    final confirmed = await globalState.showMessage(
      context: context,
      title: '关闭工单',
      message: const TextSpan(text: '关闭后将无法继续回复，是否继续？'),
    );
    if (confirmed != true) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    try {
      final closed = await api.closeTicket(ticket.id);
      if (!closed) {
        throw const V2BoardApiException('工单关闭失败');
      }
      await _loadTicket();
      await ref.read(v2boardTicketsProvider.notifier).refresh();
      if (!mounted) {
        return;
      }
      globalState.showNotifier('工单已关闭');
    } catch (error) {
      if (!mounted) {
        return;
      }
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: error.toString()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _levelText(int level) {
    return switch (level) {
      0 => '低优先级',
      1 => '中优先级',
      2 => '高优先级',
      _ => '未知优先级',
    };
  }

  String _statusText(int status) {
    return switch (status) {
      0 => '处理中',
      1 => '已关闭',
      _ => '未知状态',
    };
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) {
      return '未知时间';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _ticket;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _ticketsBackground,
      appBar: AppBar(
        backgroundColor: _ticketsBackground,
        elevation: 0,
        centerTitle: false,
        title: Text(ticket == null ? '工单详情' : '工单 #${ticket.id}'),
        actions: [
          if (ticket != null && !ticket.isClosed)
            IconButton(
              onPressed: _submitting ? null : _closeTicket,
              tooltip: '关闭工单',
              icon: const Icon(Icons.lock_outline_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTicket,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [_TicketErrorState(error: _error!)],
                    )
                  : ticket == null
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: const [_TicketEmptyDetailState()],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _TicketDetailHeader(
                          ticket: ticket,
                          statusText: _statusText(ticket.status),
                          levelText: _levelText(ticket.level),
                          createTimeText: _formatTime(ticket.createdAt),
                          updateTimeText: _formatTime(
                            ticket.updatedAt ?? ticket.createdAt,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...ticket.messages.map(
                          (message) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TicketMessageBubble(
                              message: message,
                              timeText: _formatTime(
                                message.createdAt ?? message.updatedAt,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (ticket != null && !ticket.isClosed)
            SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: '输入回复内容',
                          filled: true,
                          fillColor: const Color(0xFFF5F6F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _submitting ? null : _replyTicket,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(84, 52),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('发送'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TicketSummaryCard extends StatelessWidget {
  final int totalCount;
  final int openCount;
  final int closedCount;

  const _TicketSummaryCard({
    required this.totalCount,
    required this.openCount,
    required this.closedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '工单中心',
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '统一查看历史工单、继续回复并跟进处理状态。',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _TicketMetric(label: '全部', value: '$totalCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TicketMetric(label: '处理中', value: '$openCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TicketMetric(label: '已关闭', value: '$closedCount'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TicketMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final V2BoardTicket ticket;
  final String statusText;
  final Color statusColor;
  final Color statusBackground;
  final String levelText;
  final Color levelColor;
  final Color levelBackground;
  final String timeText;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.statusText,
    required this.statusColor,
    required this.statusBackground,
    required this.levelText,
    required this.levelColor,
    required this.levelBackground,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject.isEmpty ? '未命名工单' : ticket.subject,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _cardTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (ticket.hasPendingStaffReply)
                    const _TicketChip(
                      text: '客服已回复',
                      color: Color(0xFFBE123C),
                      backgroundColor: Color(0xFFFFE4E6),
                    ),
                  _TicketChip(
                    text: statusText,
                    color: statusColor,
                    backgroundColor: statusBackground,
                  ),
                  _TicketChip(
                    text: levelText,
                    color: levelColor,
                    backgroundColor: levelBackground,
                  ),
                  _TicketChip(
                    text: 'ID #${ticket.id}',
                    color: const Color(0xFF374151),
                    backgroundColor: const Color(0xFFF3F4F6),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '最近更新: $timeText',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;

  const _TicketChip({
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TicketDetailHeader extends StatelessWidget {
  final V2BoardTicket ticket;
  final String statusText;
  final String levelText;
  final String createTimeText;
  final String updateTimeText;

  const _TicketDetailHeader({
    required this.ticket,
    required this.statusText,
    required this.levelText,
    required this.createTimeText,
    required this.updateTimeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticket.subject.isEmpty ? '未命名工单' : ticket.subject,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: _cardTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TicketChip(
                text: statusText,
                color: ticket.isClosed
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF2563EB),
                backgroundColor: ticket.isClosed
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFEFF6FF),
              ),
              _TicketChip(
                text: levelText,
                color: const Color(0xFFB45309),
                backgroundColor: const Color(0xFFFFF7ED),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TicketInfoRow(label: '创建时间', value: createTimeText),
          const SizedBox(height: 10),
          _TicketInfoRow(label: '最近更新', value: updateTimeText),
        ],
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _TicketInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _cardTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketMessageBubble extends StatelessWidget {
  final V2BoardTicketMessage message;
  final String timeText;

  const _TicketMessageBubble({required this.message, required this.timeText});

  @override
  Widget build(BuildContext context) {
    final align = message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor = message.isMe ? Colors.black : Colors.white;
    final foregroundColor = message.isMe
        ? Colors.white
        : const Color(0xFF111827);

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: message.isMe
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.isMe ? '我' : '客服',
                style: context.textTheme.labelLarge?.copyWith(
                  color: message.isMe
                      ? Colors.white70
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                message.message,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: foregroundColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                timeText,
                style: context.textTheme.bodySmall?.copyWith(
                  color: message.isMe
                      ? Colors.white60
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketEmptyState extends StatelessWidget {
  final VoidCallback? onCreate;

  const _TicketEmptyState({this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前没有任何工单记录。',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _cardTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '你可以直接在客户端新建工单，后续在这里查看客服回复并继续跟进。',
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('新建工单'),
          ),
        ],
      ),
    );
  }
}

class _TicketErrorState extends StatelessWidget {
  final Object error;

  const _TicketErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(error.toString(), style: context.textTheme.titleMedium?.copyWith(
        color: _cardTextColor,
      )),
    );
  }
}

class _TicketEmptyDetailState extends StatelessWidget {
  const _TicketEmptyDetailState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text('没有获取到工单详情。', style: context.textTheme.titleMedium?.copyWith(
        color: _cardTextColor,
      )),
    );
  }
}

class _TicketComposerDialog extends StatefulWidget {
  const _TicketComposerDialog();

  @override
  State<_TicketComposerDialog> createState() => _TicketComposerDialogState();
}

class _TicketComposerDialogState extends State<_TicketComposerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  int _level = 1;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: '新建工单',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) {
              return;
            }
            Navigator.of(context).pop(
              _TicketDraft(
                subject: _subjectController.text.trim(),
                level: _level,
                message: _messageController.text.trim(),
              ),
            );
          },
          child: Text(appLocalizations.confirm),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: '工单主题',
                hintText: '请输入工单主题',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入工单主题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _level,
              decoration: const InputDecoration(labelText: '工单等级'),
              items: const [
                DropdownMenuItem(value: 0, child: Text('低优先级')),
                DropdownMenuItem(value: 1, child: Text('中优先级')),
                DropdownMenuItem(value: 2, child: Text('高优先级')),
              ],
              onChanged: (value) {
                setState(() {
                  _level = value ?? 1;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '消息内容',
                hintText: '请描述你遇到的问题',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入工单消息';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDraft {
  final String subject;
  final int level;
  final String message;

  const _TicketDraft({
    required this.subject,
    required this.level,
    required this.message,
  });
}
