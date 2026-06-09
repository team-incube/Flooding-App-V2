import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_size.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/color/app_colors.dart';
import '../../../../core/theme/icon/app_icon.dart';
import '../../../../core/theme/text_style/app_text_style.dart';
import '../../../../core/widgets/scaffold/base_scaffold.dart';
import '../models/chat_message.dart';
import '../widgets/chat_empty_view.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';

/// AI 챗봇 대화 페이지.
///
/// 채팅 기록이 없으면 [ChatEmptyView]를 보여주고, 메시지가 있으면
/// 말풍선 목록을 보여준다. 하단 입력 바로 메시지를 전송한다.
class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, text: text));
    });
    _inputController.clear();
    _scrollToBottom();

    // TODO: AI 응답 API 연동 후 받은 답변을 ChatRole.ai 메시지로 추가.
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
      showDefaultAppBar: false,
      appBar: const _ChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const ChatEmptyView()
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    itemCount: _messages.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s16),
                    itemBuilder: (context, index) =>
                        ChatMessageBubble(message: _messages[index]),
                  ),
          ),
          ChatInputBar(controller: _inputController, onSend: _send),
        ],
      ),
    );
  }
}

/// 뒤로가기 + 타이틀로 구성된 채팅 상단 바.
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(AppSize.s57);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: AppIcon.chevronLeft(color: AppColors.lightMainText),
      ),
      title: Text(
        'AI 챗봇',
        style: AppTextStyle.title3.copyWith(color: AppColors.lightMainText),
      ),
    );
  }
}
