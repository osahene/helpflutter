import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:helpflutter/data/models/incoming_alert.dart';
import 'package:helpflutter/data/models/titbit.dart';
import 'package:helpflutter/data/repositories/incoming_alert_repository.dart';
import 'package:helpflutter/data/repositories/titbit_repository.dart';
import 'package:helpflutter/presentation/widgets/alert_map_preview.dart';
import 'package:url_launcher/url_launcher.dart';

/// The Titbit inbox — a categorized, card-based feed of weather tips,
/// hazard warnings, seasonal advisories, admin campaigns and system notices.
class TitbitsScreen extends StatefulWidget {
  const TitbitsScreen({super.key});

  @override
  State<TitbitsScreen> createState() => _TitbitsScreenState();
}

class _TitbitsScreenState extends State<TitbitsScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Titbit> _titbits = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasNext = false;
  int _page = 1;
  String? _error;

  /// null = "All"
  String? _selectedCategory;

  static const _filters = <_FilterOption>[
    _FilterOption(null, 'All'),
    _FilterOption('alert', 'Alerts'),
    _FilterOption('weather', 'Weather'),
    _FilterOption('hazard', 'Hazard'),
    _FilterOption('seasonal', 'Seasonal'),
    _FilterOption('general', 'General'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasNext || _loadingMore || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
    });
    try {
      final page = await context.read<TitbitRepository>().getTitbits(
        page: _page,
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _titbits = page.results;
        _hasNext = page.next != null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load updates. Pull down to retry.';
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final page = await context.read<TitbitRepository>().getTitbits(
        page: nextPage,
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _titbits = [..._titbits, ...page.results];
        _hasNext = page.next != null;
        _page = nextPage;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _selectCategory(String? category) {
    if (category == _selectedCategory) return;
    setState(() => _selectedCategory = category);
    _load();
  }

  Future<void> _openTitbit(Titbit titbit) async {
    if (titbit.isUnread) {
      // Optimistically mark read locally; reconcile with the server in the
      // background so tapping feels instant even on a slow connection.
      final index = _titbits.indexWhere((t) => t.id == titbit.id);
      if (index != -1) {
        setState(() {
          _titbits[index] = titbit.copyWith(readAt: DateTime.now());
        });
      }
      unawaited(
        context.read<TitbitRepository>().markRead(titbit.id).catchError((_) {
          return titbit;
        }),
      );
    }

    if (!mounted) return;
    final theme = Theme.of(context);
    final meta = _metaFor(titbit.category);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TitbitDetailSheet(titbit: titbit, meta: meta, theme: theme),
    );
  }

  /// Swipe-to-delete. Only this user's copy is hidden (the backend keeps the
  /// record), so nobody else's inbox is affected. Restored if the request
  /// fails, so a deletion never silently "comes back" on the next refresh.
  Future<void> _dismissTitbit(Titbit titbit, int index) async {
    setState(() => _titbits.removeAt(index));
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<TitbitRepository>().dismiss(titbit.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Notification deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _titbits.insert(index.clamp(0, _titbits.length), titbit));
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't delete it. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(theme),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter.category == _selectedCategory;
          return ChoiceChip(
            label: Text(filter.label),
            selected: selected,
            onSelected: (_) => _selectCategory(filter.category),
            backgroundColor: Colors.grey.shade100,
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: selected ? theme.colorScheme.primary : Colors.black87,
              fontWeight: selected ? FontWeight.bold : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _titbits.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(_error!, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_titbits.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 400,
              child: _EmptyState(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _titbits.length + (_hasNext ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _titbits.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }
          final titbit = _titbits[index];
          return Dismissible(
            key: ValueKey(titbit.id),
            direction: DismissDirection.endToStart,
            background: const _DeleteSwipeBackground(),
            onDismissed: (_) => _dismissTitbit(titbit, index),
            child: _TitbitCard(
              titbit: titbit,
              meta: _metaFor(titbit.category),
              onTap: () => _openTitbit(titbit),
            ),
          );
        },
      ),
    );
  }
}

class _FilterOption {
  final String? category;
  final String label;
  const _FilterOption(this.category, this.label);
}

/// Visual identity (color + icon + label) for each Titbit category.
class _CategoryMeta {
  final Color color;
  final IconData icon;
  final String label;
  const _CategoryMeta(this.color, this.icon, this.label);
}

_CategoryMeta _metaFor(String category) {
  switch (category) {
    case 'alert':
      return const _CategoryMeta(Color(0xFFCC2222), Icons.sos_rounded, 'Alert');
    case 'weather':
      return const _CategoryMeta(Color(0xFF0A72C4), Icons.cloud_outlined, 'Weather');
    case 'hazard':
      return const _CategoryMeta(Color(0xFFCC2222), Icons.warning_amber_rounded, 'Hazard');
    case 'seasonal':
      return const _CategoryMeta(Color(0xFFCB8A00), Icons.eco_outlined, 'Seasonal');
    case 'system':
      return const _CategoryMeta(Color(0xFF6B7280), Icons.settings_outlined, 'System');
    case 'general':
    default:
      return const _CategoryMeta(AppTheme.primaryColor, Icons.info_outline_rounded, 'General');
  }
}

class _TitbitCard extends StatelessWidget {
  final Titbit titbit;
  final _CategoryMeta meta;
  final VoidCallback onTap;

  const _TitbitCard({required this.titbit, required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = titbit.isUnread;

    // NOTE: a BoxDecoration can't combine a rounded borderRadius with a
    // non-uniform Border (e.g. left-only) — Flutter asserts on that at
    // paint time. So the color accent is a separate flush-left bar inside
    // a clipped Row, rather than a `Border(left: ...)`.
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: unread ? 2 : 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: meta.color),
              Expanded(child: _buildContent(unread)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool unread) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: meta.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        titbit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xFF0F1B3E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relativeTime(titbit.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  titbit.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                ),
                if (titbit.image != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      titbit.image!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(height: 120, color: Colors.grey.shade200);
                      },
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TitbitDetailSheet extends StatelessWidget {
  final Titbit titbit;
  final _CategoryMeta meta;
  final ThemeData theme;

  const _TitbitDetailSheet({required this.titbit, required this.meta, required this.theme});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(meta.icon, color: meta.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    meta.label,
                    style: TextStyle(
                      color: meta.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _relativeTime(titbit.createdAt),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                titbit.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F1B3E),
                ),
              ),
              if (titbit.image != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    titbit.image!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (titbit.relatedEmergencyId != null)
                _AlertDetails(
                  emergencyId: titbit.relatedEmergencyId!,
                  fallbackBody: titbit.body,
                )
              else
                Text(
                  titbit.body,
                  style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade800),
                ),
              if (titbit.source != null && titbit.source!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Source: ${titbit.source}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DeleteSwipeBackground extends StatelessWidget {
  const _DeleteSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// An alert notification, shown the way the SMS reads, plus a map box of
/// where it was raised. Loaded from the same endpoint the incoming-alert
/// screen uses, so it also works for notifications created before the
/// backend stored the full message.
class _AlertDetails extends StatefulWidget {
  final String emergencyId;
  final String fallbackBody;

  const _AlertDetails({required this.emergencyId, required this.fallbackBody});

  @override
  State<_AlertDetails> createState() => _AlertDetailsState();
}

class _AlertDetailsState extends State<_AlertDetails> {
  late final Future<IncomingAlert> _alert = context
      .read<IncomingAlertRepository>()
      .getIncomingAlert(widget.emergencyId);

  Future<void> _open(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade800);

    return FutureBuilder<IncomingAlert>(
      future: _alert,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final alert = snapshot.data;
        if (alert == null) {
          // Not loadable (offline, or no longer available) — still show
          // what the notification itself says.
          return Text(widget.fallbackBody, style: bodyStyle);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(alert.message, style: bodyStyle),
            const SizedBox(height: 16),
            if (alert.location != null)
              AlertMapPreview(
                location: alert.location!,
                title: alert.reporter.name.isEmpty ? 'Alert location' : alert.reporter.name,
                mapsLink: alert.mapsLink,
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_off_rounded, color: Colors.grey.shade500),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Location not available for this alert.')),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (alert.reporter.phone.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _open(Uri(scheme: 'tel', path: alert.reporter.phone)),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC2222),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (alert.reporter.phone.isNotEmpty && alert.verificationLink != null)
                  const SizedBox(width: 10),
                if (alert.verificationLink != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _open(Uri.parse(alert.verificationLink!)),
                      icon: const Icon(Icons.verified_outlined, size: 18),
                      label: const Text('Verify alert'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No updates yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Weather tips, hazard warnings and safety advisories will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().toUtc().difference(dt.toUtc());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
