import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class PendingList extends StatelessWidget {
  const PendingList({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () {},
          ),
          title: Text(
            'បញ្ជីរង់ចាំការអនុម័ត',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor:AppColors.darkgreen,
            tabs: [
              Tab(text: 'រងចាំ (១២)'),
              Tab(text: 'បានអនុម័ត'),
              Tab(text: 'បានបដិសេធ'),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.darkBg,
          selectedItemColor: AppColors.darkgreen,
          unselectedItemColor: AppColors.textGrey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: 'ផ្ទាំង',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add_check),
              label: 'កត់ត្រា',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'បុគ្គលិក'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'កំណត់'),
          ],
          onTap: (_) {},
        ),
        body: TabBarView(
          children: [
            _PendingTab(
              cardColor: AppColors.primary,
              borderColor: AppColors.greenSurface,
            ),
            _EmptyState(text: 'មិនមានទិន្នន័យ (បានអនុម័ត)'),
            _EmptyState(text: 'មិនមានទិន្នន័យ (បានបដិសេធ)'),
          ],
        ),
      ),
    );
  }
}

class _PendingTab extends StatelessWidget {
  const _PendingTab({required this.cardColor, required this.borderColor});

  final Color cardColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final items = <_PendingItem>[
      _PendingItem(
        requestId: 'WS-9021',
        name: 'សុន តានីកា',
        role: 'បច្ចេកវិឡាព័ត៍មាន (IT)',
        matchPercent: 98,
        selfieUrl: 'https://picsum.photos/seed/selfie1/600/600',
        referenceUrl: 'https://picsum.photos/seed/ref1/600/600',
      ),
      _PendingItem(
        requestId: 'WS-9025',
        name: 'លី មាលីណា',
        role: 'រដ្ឋបាល (Admin)',
        matchPercent: 92,
        selfieUrl: 'https://picsum.photos/seed/selfie2/600/600',
        referenceUrl: 'https://picsum.photos/seed/ref2/600/600',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        return _PendingCard(
          item: items[i],
          cardColor: cardColor,
          borderColor: borderColor,
          onReject: () {},
          onApprove: () {},
        );
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.item,
    required this.cardColor,
    required this.borderColor,
    required this.onReject,
    required this.onApprove,
  });

  final _PendingItem item;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'លេខសំណើ៖ #${item.requestId}',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'តួនាទី៖ ${item.role}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _MatchBadge(percent: item.matchPercent),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LabeledImage(
                  label: 'រូបថត SELFIE',
                  imageUrl: item.selfieUrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledImage(
                  label: 'រូបថតយោង',
                  imageUrl: item.referenceUrl,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, color: AppColors.error),
                  label: const Text(
                    'បដិសេធ',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3A4A50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFF102126),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 230,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('អនុម័ត'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: const Color(0xFF06251C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0F2A24);
    final fg = const Color(0xFF20C997);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1D4D41)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 18, color: fg),
          const SizedBox(width: 6),
          Text(
            '$percent% Match',
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledImage extends StatelessWidget {
  const _LabeledImage({required this.label, required this.imageUrl});
  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0F2227),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _PendingItem {
  final String requestId;
  final String name;
  final String role;
  final int matchPercent;
  final String selfieUrl;
  final String referenceUrl;

  _PendingItem({
    required this.requestId,
    required this.name,
    required this.role,
    required this.matchPercent,
    required this.selfieUrl,
    required this.referenceUrl,
  });
}
