import 'package:flutter/material.dart';

import '../../../../core/widgets/scaffold/drawer/controller/navigation_controller.dart';
import '../../../../core/widgets/scaffold/base_scaffold.dart';
import '../../../dormitory/presentation/widgets/dormitory_view.dart';
import '../widgets/home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.userName = '민솔', this.studentId = '2403'});

  final String userName;
  final String studentId;

  //TODO Controller 연결해 서버로부터 인원 수 불러오기
  static const int _studyCount = 4;
  static const int _massageCount = 4;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: ListenableBuilder(
        listenable: navigationController,
        builder: (context, _) => switch (navigationController.destination) {
          MenuDestination.home => const HomeView(
            studyCount: _studyCount,
            massageCount: _massageCount,
          ),
          MenuDestination.dormitory => const DormitoryView(
            studyCount: _studyCount,
            massageCount: _massageCount,
          ),
        },
      ),
    );
  }
}
