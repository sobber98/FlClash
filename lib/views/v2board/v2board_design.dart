import 'package:v2box/common/common.dart';
import 'package:flutter/material.dart';

const v2BoardPageBackground = Color(0xFFF7F9FD);
const v2BoardSurface = Colors.white;
const v2BoardPrimary = Color(0xFF4F5BFF);
const v2BoardPrimaryDark = Color(0xFF2F3CF4);
const v2BoardInk = Color(0xFF111B35);
const v2BoardMuted = Color(0xFF697797);
const v2BoardLine = Color(0xFFE3E8F3);
const v2BoardSoft = Color(0xFFF1F4FF);
const v2BoardSuccess = Color(0xFF18B56B);
const v2BoardDanger = Color(0xFFE53935);

const v2BoardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6670FF), Color(0xFF3944F5)],
);

const v2BoardSuccessGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF24C978), Color(0xFF08984F)],
);

final v2BoardShadow = <BoxShadow>[
  const BoxShadow(
    color: Color(0x140D1B3D),
    blurRadius: 26,
    offset: Offset(0, 10),
  ),
];

class V2BoardLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const V2BoardLogo({super.key, this.size = 42, this.showText = true});

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: v2BoardGradient,
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x224F5BFF),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'V',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
    if (!showText) {
      return mark;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text(
          'V2Board',
          style: context.textTheme.titleLarge?.copyWith(
            color: v2BoardInk,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class V2BoardPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool compact;

  const V2BoardPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? context.textTheme.titleLarge
                            : context.textTheme.headlineSmall)
                        ?.copyWith(
                          color: v2BoardInk,
                          fontWeight: FontWeight.w800,
                        ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: v2BoardMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class V2BoardAuthHeroPanel extends StatelessWidget {
  final String appName;

  const V2BoardAuthHeroPanel({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 620),
      padding: const EdgeInsets.fromLTRB(42, 48, 36, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F6FF), Color(0xFFEAF0FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2BoardLogo(size: 48, showText: false),
          const SizedBox(height: 18),
          Text(
            '$appName Client',
            style: context.textTheme.headlineSmall?.copyWith(
              color: v2BoardInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '安全 · 稳定 · 高效',
              style: context.textTheme.labelMedium?.copyWith(
                color: v2BoardPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 46),
          Text(
            '安全连接全球网络\n极速稳定的访问体验',
            style: context.textTheme.displaySmall?.copyWith(
              color: v2BoardInk,
              fontWeight: FontWeight.w800,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '为个人与团队提供安全、稳定、易用的网络连接服务，多端同步，随时随地畅享全球资源。',
            style: context.textTheme.bodyLarge?.copyWith(
              color: v2BoardMuted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
          const _V2BoardHeroFeature(
            icon: Icons.verified_user_outlined,
            title: '安全连接',
            text: '多重加密协议，保障数据传输安全可靠',
          ),
          const SizedBox(height: 18),
          const _V2BoardHeroFeature(
            icon: Icons.flash_on_outlined,
            title: '极速节点',
            text: '全球优质节点加速，智能路由低延迟',
          ),
          const SizedBox(height: 18),
          const _V2BoardHeroFeature(
            icon: Icons.devices_outlined,
            title: '多端同步',
            text: '支持 PC / Mobile 多端使用，数据实时同步',
          ),
          const Spacer(),
          Text(
            '© 2024 V2Board. All rights reserved.',
            style: context.textTheme.bodySmall?.copyWith(color: v2BoardMuted),
          ),
        ],
      ),
    );
  }
}

class _V2BoardHeroFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _V2BoardHeroFeature({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        V2BoardIconBox(icon: icon, size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  color: v2BoardInk,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: context.textTheme.bodySmall?.copyWith(
                  color: v2BoardMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class V2BoardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Border? border;

  const V2BoardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = v2BoardSurface,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final content = Ink(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border ?? Border.all(color: v2BoardLine),
        boxShadow: v2BoardShadow,
      ),
      child: child,
    );
    if (onTap == null) {
      return Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: content,
      );
    }
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
    );
  }
}

class V2BoardIconBox extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color background;

  const V2BoardIconBox({
    super.key,
    required this.icon,
    this.size = 42,
    this.color = v2BoardPrimary,
    this.background = v2BoardSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

class V2BoardPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  const V2BoardPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : v2BoardGradient,
        color: onPressed == null ? const Color(0xFFB9C0D9) : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: onPressed == null
            ? null
            : const [
                BoxShadow(
                  color: Color(0x264F5BFF),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        child: child,
      ),
    );
  }
}

class V2BoardSegmented<T> extends StatelessWidget {
  final T value;
  final List<({T value, String label})> items;
  final ValueChanged<T> onChanged;

  const V2BoardSegmented({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: v2BoardLine),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(item.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: value == item.value ? v2BoardGradient : null,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: value == item.value ? Colors.white : v2BoardInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
