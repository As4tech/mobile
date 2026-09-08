import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// One column definition for the wide (table) rendering of [RecordList].
class RecordColumn<T> {
  const RecordColumn(this.header, this.text);

  final String header;
  final String Function(T) text;
}

/// Responsive record list used by every Registration tab.
///
/// On wide screens it renders a horizontally-scrollable `DataTable` with the
/// app-wide themed row heights; on narrow screens it renders a vertically
/// stacked list of cards with uniform spacing so scrolling is smooth and row
/// gaps stay consistent.
class RecordList<T> extends StatelessWidget {
  const RecordList({
    super.key,
    required this.items,
    required this.columns,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.actionItems,
    this.onAction,
    this.emptyText = 'No records yet. Tap Add to create the first one.',
  });

  final List<T> items;
  final List<RecordColumn<T>> columns;
  final String Function(T) title;
  final String Function(T)? subtitle;
  final Widget Function(T)? trailing;
  final IconData Function(T)? leadingIcon;

  /// Row actions shown behind a "more" menu; each entry executes a [Future]
  /// (e.g. opens an edit sheet or toggles activation), after which [onAction]
  /// lets the parent refresh.
  final List<PopupMenuEntry<Future<void> Function()>> Function(T)? actionItems;

  /// Called after a row action completes so the owning view can reload.
  final VoidCallback? onAction;

  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(message: emptyText, icon: _defaultLeading());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;
        return wide ? _buildTable(context) : _buildCards(context);
      },
    );
  }

  IconData _defaultLeading() => Icons.receipt_long_outlined;

  Widget _buildTable(BuildContext context) {
    final hasActions = actionItems != null;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          ...columns.map((c) => DataColumn(label: Text(c.header))),
          if (hasActions) const DataColumn(label: Text('')),
        ],
        rows: items.map((item) {
          return DataRow(
            cells: [
              ...columns.map((c) {
                return DataCell(
                  Text(
                    c.text(item),
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
              if (hasActions) _actionCell(context, item),
            ],
          );
        }).toList(),
      ),
    );
  }

  DataCell _actionCell(BuildContext context, T item) {
    return DataCell(
      PopupMenuButton<Future<void> Function()>(
        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
        color: AppColors.surface,
        onSelected: (action) async {
          await action();
          onAction?.call();
        },
        itemBuilder: (context) => actionItems!(item),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _buildCard(context, items[i]),
        ],
      ],
    );
  }

  Widget _buildCard(BuildContext context, T item) {
    final icon = (leadingIcon ?? _defaultLeading)(item);
    final sub = subtitle?.call(item);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelText(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                if (sub != null && sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelText(context)
                        .copyWith(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!(item),
          ],
          if (actionItems != null) ...[
            const SizedBox(width: 4),
            PopupMenuButton<Future<void> Function()>(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textMuted,
              ),
              color: AppColors.surface,
              onSelected: (action) async {
                await action();
                onAction?.call();
              },
              itemBuilder: (context) => actionItems!(item),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyText(context)
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
