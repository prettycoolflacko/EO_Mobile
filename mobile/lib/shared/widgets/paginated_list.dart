import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';

typedef FetchNextPageCallback = Future<void> Function();

/// A reusable paginated list view with pull-to-refresh and infinite scroll.
class PaginatedListView<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasNextPage;
  final String? errorMessage;
  final FetchNextPageCallback onFetchNextPage;
  final RefreshCallback onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget emptyState;
  final EdgeInsets padding;
  final double gap;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasNextPage,
    required this.onFetchNextPage,
    required this.onRefresh,
    required this.itemBuilder,
    required this.emptyState,
    this.errorMessage,
    this.padding = const EdgeInsets.all(16),
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isLoading && items.isEmpty) {
      if (errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Icon(LucideIcons.alertCircle,
                  color: AppColors.error, size: 48),
              const Gap(16),
              Text(errorMessage!, style: const TextStyle(color: AppColors.error)),
              const Gap(16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(child: emptyState),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: padding,
        itemCount: items.length + (hasNextPage ? 1 : 0),
        separatorBuilder: (_, __) => Gap(gap),
        itemBuilder: (context, index) {
          if (index == items.length) {
            // Reached the bottom, fetch next page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!isLoading) onFetchNextPage();
            });
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }
}
