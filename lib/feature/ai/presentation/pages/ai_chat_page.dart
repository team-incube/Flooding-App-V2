import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/scaffold/base_scaffold.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_empty_view.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

/// AI 챗봇 대화 페이지.
///
/// [ChatBloc] 을 제공하고, 대화 화면([_AiChatView])을 띄운다.
class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ChatBloc(), child: const _AiChatView());
  }
}

/// 대화 화면 본문.
///
/// 채팅 기록이 없으면 [ChatEmptyView]를 보여주고, 메시지가 있으면
/// 말풍선 목록을 보여준다. 하단 입력 바로 메시지를 전송한다.
class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    context.read<ChatBloc>().add(ChatEvent.messageSent(text));
    _inputController.clear();
  }

  /// 새 메시지가 추가되면 목록 맨 아래로 스크롤한다.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        children: [
          const _ChatHeader(),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (previous, current) =>
                  current.messages.length > previous.messages.length,
              listener: (context, state) => _scrollToBottom(),
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return const ChatEmptyView();
                }
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: state.messages.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.s16),
                  itemBuilder: (context, index) =>
                      ChatMessageBubble(message: state.messages[index]),
                );
              },
            ),
          ),
          ChatInputBar(controller: _inputController, onSend: _send),
        ],
      ),
    );
  }
}

/// 뒤로가기 + 'AI챗봇' 타이틀로 구성된 페이지 서브 헤더.
///
/// 상단 `flooding` 로고 앱바(기본) 아래에 위치하며, 좌측 정렬이다.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.pop(),
            child: AppIcon.chevronLeft(color: AppColors.lightMainText),
          ),
          const SizedBox(width: AppSpacing.s4),
          Text(
            'AI챗봇',
            style: AppTextStyle.text1.copyWith(color: AppColors.lightMainText),
          ),
        ],
      ),
    );
  }
}
