import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../core/widgets/sheet/sheet.dart';
import '../../../dormitory/presentation/widgets/dormitory_view.dart';
import '../../../ai/presentation/widgets/song_recommendation_sheet.dart';
import '../widgets/home_floating_actions.dart';
import '../widgets/home_view.dart';
import '../widgets/menu_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userName = '민솔', this.studentId = '2403'});

  /// 메뉴 드로어 인사말에 표시할 사용자 이름.
  final String userName;

  /// 메뉴 드로어에 표시할 학번.
  final String studentId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 현재 본문에 표시 중인 섹션. 드로어에서 전환하며 페이지 이동 없이
  /// 같은 화면(앱바·드로어 유지)에서 본문만 교체한다.
  MenuDestination _section = MenuDestination.home;

  //TODO Controller 연결해 서버로부터 인원 수 불러오기
  final int studyCount = 4;
  final int massageCount = 4;

  /// 본문 섹션을 [section] 으로 교체한다. 드로어는 열린 채로 두고
  /// 뒤 본문만 바뀐다.
  void _selectSection(MenuDestination section) {
    if (_section == section) return;
    setState(() => _section = section);
  }

  /// 플로팅 AI 버튼 → 오늘의 노래 추천 팝업.
  Future<void> _openSongRecommendation() async {
    // Todo: 추천 곡 목록을 서버에서 받아오도록 교체.
    const songs = [
      SongRecommendation(
        title: 'Numb (Official Music Video) [4K UPGRADE] – Linkin Park',
        duration: '3:08',
      ),
      SongRecommendation(title: 'Viva La Vida – Coldplay', duration: '4:02'),
      SongRecommendation(title: 'Bohemian Rhapsody – Queen', duration: '5:55'),
    ];
    final song = await SongRecommendationSheet.show(context, songs: songs);
    if (!mounted || song == null) return;
    // Todo: 선택한 곡 신청 API 연동.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('신청: ${song.title}')));
  }

  /// 드로어 로그아웃 → 확인 후 로그아웃.
  Future<void> _confirmLogout() async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '로그아웃',
      message: '정말로 로그아웃 하시겠습니까?',
      confirmLabel: '로그아웃',
    );
    if (!mounted || ok != true) return;
    // Todo: 로그아웃 처리.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('로그아웃되었어요')));
  }

  /// 드로어 회원탈퇴 → 확인 후 탈퇴.
  Future<void> _confirmWithdraw() async {
    final ok = await AppConfirmDialog.show(
      context,
      title: '회원 탈퇴',
      message: '정말로 회원을 탈퇴하시겠습니까?',
      confirmLabel: '탈퇴 하기',
    );
    if (!mounted || ok != true) return;
    // Todo: 회원탈퇴 처리.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('회원탈퇴되었어요')));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      endDrawer: MenuDrawer(
        userName: widget.userName,
        studentId: widget.studentId,
        selected: _section,
        onProfileEdit: () {
          // Todo: 프로필 편집 기능 구현
        },
        onHomeTap: () => _selectSection(MenuDestination.home),
        onDormitoryTap: () => _selectSection(MenuDestination.dormitory),
        onLogout: _confirmLogout,
        onWithdraw: _confirmWithdraw,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          right: AppSpacing.s8,
          bottom: AppSpacing.s24,
        ),
        child: HomeFloatingActions(
          onAiTap: _openSongRecommendation,
          onChatTap: () {
            // Todo: 챗봇 기능 구현
          },
        ),
      ),
      body: switch (_section) {
        MenuDestination.home => HomeView(
          studyCount: studyCount,
          massageCount: massageCount,
        ),
        MenuDestination.dormitory => DormitoryView(
          studyCount: studyCount,
          massageCount: massageCount,
        ),
      },
    );
  }
}
