import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WebCarousel<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final VoidCallback? onSeeAll;
  final double height;

  const WebCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.onSeeAll,
    this.height = 280,
  });

  @override
  State<WebCarousel<T>> createState() => _WebCarouselState<T>();
}

class _WebCarouselState<T> extends State<WebCarousel<T>> {
  final ScrollController _scrollController = ScrollController();

  // Scroll distance per click (approx width of 2 items)
  static const double _scrollAmount = 350.0;

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - _scrollAmount,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + _scrollAmount,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ HEADER ROW (Aligned to full width)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (widget.onSeeAll != null)
              TextButton(
                onPressed: widget.onSeeAll,
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 🎠 SCROLLABLE AREA
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // The List
              widget.items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      // Add minimal padding so first/last items aren't cut off by shadow
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      itemCount: widget.items.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return widget.itemBuilder(context, widget.items[index]);
                      },
                    ),

              // ⬅️ LEFT ARROW
              if (widget.items.isNotEmpty)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildArrowButton(
                      icon: Icons.chevron_left,
                      onTap: _scrollLeft,
                    ),
                  ),
                ),

              // ➡️ RIGHT ARROW
              if (widget.items.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildArrowButton(
                      icon: Icons.chevron_right,
                      onTap: _scrollRight,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_clear, size: 40, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'No items found',
              style: TextStyle(color: Colors.grey.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}