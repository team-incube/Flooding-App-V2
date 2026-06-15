import 'package:flooding_v2/core/constants/app_spacing.dart';
import 'package:flooding_v2/core/theme/color/app_colors.dart';
import 'package:flooding_v2/core/theme/icon/app_icon.dart';
import 'package:flooding_v2/core/theme/text_style/app_text_style.dart';
import 'package:flooding_v2/core/widgets/search_text_field.dart';
import 'package:flooding_v2/feature/dormitory/presentation/widgets/song_request_card.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Scaffold(body: SongDetailView())));
}

class SongDetailView extends StatefulWidget {
  const SongDetailView({super.key});

  @override
  State<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends State<SongDetailView> {
  final _songSearchController = TextEditingController();
  String _query = '';

  final _songs = [
    {
      'song':
          '06. 멋진헛간 (Wonderful Barn) – 오대천왕 (The 5 Emperor) (정형돈, 밴드 혁오) (Jeong Hyeong Don, hyukoh)',
      'grade': '2205',
      'name': '류수연',
      'requestedAt': DateTime.now(),
    },
    {
      'song':
          '06. 멋진헛간 (Wonderful Barn) – 오대천왕 (The 5 Emperor) (정형돈, 밴드 혁오) (Jeong Hyeong Don, hyukoh)',
      'grade': '2205',
      'name': '류수연',
      'requestedAt': DateTime.now(),
    },
    {
      'song': '06. 멋진헛간 (Wonderful Barn) – 오대천왕',
      'grade': '2205',
      'name': '류수연',
      'requestedAt': DateTime.now(),
    },
    {
      'song': '06. 멋진헛간 (Wonderful Barn) – 오대천왕',
      'grade': '2205',
      'name': '류수연',
      'requestedAt': DateTime.now(),
    },
    {
      'song': '06. 멋진헛간 (Wonderful Barn) – 오대천왕',
      'grade': '2205',
      'name': '음창승',
      'requestedAt': DateTime.now(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _songSearchController.addListener(() {
      setState(() => _query = _songSearchController.text);
    });
  }

  @override
  void dispose() {
    _songSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final filterSongs = q.isEmpty
        ? _songs
        : _songs.where((song) {
            return (song['song'] as String).toLowerCase().contains(q) ||
                (song['name'] as String).toLowerCase().contains(q);
          }).toList();

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: AppIcon.back(),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  Text(
                    '음악신청',
                    style: AppTextStyle.text2.copyWith(
                      color: AppColors.lightMainText,
                    ),
                  ),
                  const Spacer(flex: 1),
                  IconButton(onPressed: () {}, icon: AppIcon.calendar()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SearchTextField(
                textEditingController: _songSearchController,
                hintText: '학생 이름, 노래 제목을 입력해주세요',
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final song = filterSongs[index];
                  return SongRequestCard(
                    song: song['song'] as String,
                    grade: song['grade'] as String,
                    name: song['name'] as String,
                    requestedAt: song['requestedAt'] as DateTime,
                  );
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.s16),
                itemCount: filterSongs.length,
              ),
            ),
          ],
        ),
    );
  }
}
