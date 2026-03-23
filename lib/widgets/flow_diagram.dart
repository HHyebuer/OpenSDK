import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';

export '../services/auth_service.dart' show FlowPhase;

class FlowDiagram extends StatefulWidget {
  final FlowPhase currentPhase;

  const FlowDiagram({
    super.key,
    required this.currentPhase,
  });

  @override
  State<FlowDiagram> createState() => _FlowDiagramState();
}

class _FlowDiagramState extends State<FlowDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlowDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPhase != widget.currentPhase) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF1a1a2e),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildFlowChart(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlowChart() {
    switch (widget.currentPhase) {
      case FlowPhase.initial:
        return _buildInitialView();
      case FlowPhase.initialization:
        return _buildInitializationFlow();
      case FlowPhase.login:
        return _buildLoginFlow();
      case FlowPhase.autoLogin:
        return _buildAutoLoginFlow();
      case FlowPhase.logout:
        return _buildLogoutFlow();
      case FlowPhase.networkError:
        return _buildInitialView();
    }
  }

  Widget _buildInitialView() {
    return Container(
      width: 400,
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            '点击左侧按钮查看流程时序图',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // 前置流程：OpenSDK初始化
  Widget _buildInitializationFlow() {
    final participants = ['业务调用方', 'OpenSDK\n(客户端)', 'OpenSDK\n(服务端)'];
    final colors = [
      const Color(0xFFE8D5B7),
      const Color(0xFFB8E6D4),
      const Color(0xFFB8D4E6),
    ];

    final messages = [
      _Message(0, 1, '初始化请求\n(AppID、AppKey、业务标识)'),
      _Message(1, 1, '初始化本地环境\n(加密/缓存)'),
      _Message(1, 2, '初始化校验\n(AppID、AppKey、业务标识)'),
      _Message(2, 1, '初始化结果\n(成功/失败+错误码)'),
      _Message(1, 0, '初始化结果\n(成功/失败+错误码)'),
    ];

    return _buildSequenceDiagram(
      '前置流程：OpenSDK初始化',
      participants,
      colors,
      messages,
      laneWidth: 280.0,
    );
  }

  // 流程1：主动登录（账号密码/验证码）
  Widget _buildLoginFlow() {
    final participants = ['业务调用方', 'OpenSDK\n(客户端)', 'OpenSDK\n(服务端)', '技术中心\n账号管理', '用户'];
    final colors = [
      const Color(0xFFE8D5B7),
      const Color(0xFFB8E6D4),
      const Color(0xFFB8D4E6),
      const Color(0xFFE6B8D4),
      const Color(0xFFD4B8E6),
    ];

    final messages = [
      _Message(0, 1, '调用登录窗口'),
      _Message(1, 2, '请求登录'),
      _Message(2, 1, '返回配置信息'),
      _Message(1, 1, '展示登录UI/页面'),
      _Message(4, 1, '输入账号/密码/验证码'),
      _Message(1, 1, '校验格式及规则\n加密敏感数据'),
      _Message(1, 2, '请求凭证+AppID+AppKey'),
      _Message(2, 2, '解密+接入方权限校验'),
      _Message(2, 3, '登录校验请求\n(登录标识信息+业务标识)'),
      _Message(3, 2, '情况1：返回验证结果，校验失败', isError: true),
      _Message(2, 1, '登录失败结果+错误码', isError: true),
      _Message(1, 0, '登录失败结果+错误码', isError: true),
      _Message(3, 2, '情况2：返回登录结果，登录成功'),
      _Message(2, 1, '登录成功结果'),
      _Message(1, 1, '本地加密缓存用户信息\n登录token存储'),
      _Message(1, 0, '登录成功结果'),
    ];

    return _buildSequenceDiagram(
      '流程1：主动登录（账号密码/验证码）',
      participants,
      colors,
      messages,
    );
  }

  // 流程2：免登/自动登录（基于gameToken）
  Widget _buildAutoLoginFlow() {
    final participants = ['业务调用方', 'OpenSDK\n(客户端)', 'OpenSDK\n(服务端)', '技术中心\n账号管理', '西瓜SDK\n/游戏服务', '终端应用'];
    final colors = [
      const Color(0xFFE8D5B7),
      const Color(0xFFB8E6D4),
      const Color(0xFFB8D4E6),
      const Color(0xFFE6B8D4),
      const Color(0xFFD4E6B8),
      const Color(0xFFE6D4B8),
    ];

    final messages = [
      _Message(0, 5, '调用终端应用'),
      _Message(5, 4, '登录请求'),
      _Message(4, 2, '请求gameToken'),
      _Message(2, 2, '登录token校验\n+deviceID'),
      _Message(2, 3, '请求gameToken\n(原token+deviceID)'),
      _Message(3, 2, '返回gameToken'),
      _Message(2, 4, '返回gameToken+deviceID'),
      _Message(4, 3, '请求免登校验服务\n(gameToken+deviceID)'),
      _Message(3, 4, '返回免登校验结果\n(成功/失败+错误码)'),
      _Message(4, 2, '返回免登结果'),
      _Message(2, 0, '返回免登结果'),
    ];

    return _buildSequenceDiagram(
      '流程2：免登/自动登录（基于gameToken）',
      participants,
      colors,
      messages,
    );
  }

  // 流程3：退出登录
  Widget _buildLogoutFlow() {
    final participants = ['业务调用方', 'OpenSDK\n(客户端)', 'OpenSDK\n(服务端)'];
    final colors = [
      const Color(0xFFE8D5B7),
      const Color(0xFFB8E6D4),
      const Color(0xFFB8D4E6),
    ];

    final messages = [
      _Message(0, 1, '调用退出登录'),
      _Message(1, 1, '读取登录token\n准备登出请求'),
      _Message(1, 2, '请求登出'),
      _Message(2, 2, '清除账号token'),
      _Message(2, 1, '返回登出成功'),
      _Message(1, 1, '清除用户凭证及本地缓存'),
      _Message(1, 0, '返回登出成功'),
    ];

    return _buildSequenceDiagram(
      '流程3：退出登录',
      participants,
      colors,
      messages,
      laneWidth: 280.0,
    );
  }

  Widget _buildSequenceDiagram(
    String title,
    List<String> participants,
    List<Color> colors,
    List<_Message> messages, {
    double laneWidth = 160.0,
  }) {
    final headerHeight = 80.0;
    final messageHeight = 70.0;
    final totalWidth = laneWidth * participants.length;
    final totalHeight = headerHeight + messageHeight * messages.length + 120;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Container(
          width: totalWidth,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF252542),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // 时序图
        Container(
          width: totalWidth,
          height: totalHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF252542),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: CustomPaint(
            size: Size(totalWidth, totalHeight),
            painter: _SequenceDiagramPainter(
              participants: participants,
              participantColors: colors,
              messages: messages,
              animationValue: _animation.value,
              laneWidth: laneWidth,
              headerHeight: headerHeight,
              messageHeight: messageHeight,
            ),
          ),
        ),
      ],
    );
  }
}

class _Message {
  final int from;
  final int to;
  final String label;
  final bool isError;
  final bool isSelfMessage;

  _Message(this.from, this.to, this.label, {this.isError = false})
      : isSelfMessage = from == to;
}

class _SequenceDiagramPainter extends CustomPainter {
  final List<String> participants;
  final List<Color> participantColors;
  final List<_Message> messages;
  final double animationValue;
  final double laneWidth;
  final double headerHeight;
  final double messageHeight;

  _SequenceDiagramPainter({
    required this.participants,
    required this.participantColors,
    required this.messages,
    required this.animationValue,
    required this.laneWidth,
    required this.headerHeight,
    required this.messageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final errorTextStyle = TextStyle(
      color: Colors.red.shade300,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    // 绘制参与者标题
    for (int i = 0; i < participants.length; i++) {
      final x = i * laneWidth + laneWidth / 2;
      final rect = Rect.fromCenter(
        center: Offset(x, headerHeight / 2 - 10),
        width: laneWidth - 16,
        height: 50,
      );

      // 绘制背景
      final bgPaint = Paint()
        ..color = participantColors[i].withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        bgPaint,
      );

      // 绘制边框
      final borderPaint = Paint()
        ..color = participantColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        borderPaint,
      );

      // 绘制文本
      final textSpan = TextSpan(
        text: participants[i],
        style: textStyle.copyWith(
          color: participantColors[i].withOpacity(0.9),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: laneWidth - 24);
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, headerHeight / 2 - 10 - textPainter.height / 2),
      );

      // 绘制生命线
      final lifelinePaint = Paint()
        ..color = participantColors[i].withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(x, headerHeight - 10),
        Offset(x, size.height - 60),
        lifelinePaint,
      );
    }

    // 绘制消息
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      final y = headerHeight + 20 + i * messageHeight;
      
      // 动画进度
      final msgProgress = (animationValue * messages.length - i).clamp(0.0, 1.0);
      if (msgProgress <= 0) continue;

      final fromX = msg.from * laneWidth + laneWidth / 2;
      final toX = msg.to * laneWidth + laneWidth / 2;
      
      // 消息颜色
      final msgColor = msg.isError ? Colors.red.shade300 : Colors.white.withOpacity(0.8);
      final arrowPaint = Paint()
        ..color = msgColor.withOpacity(msgProgress)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      if (msg.isSelfMessage) {
        // 自循环消息
        final loopWidth = 40.0;
        final loopHeight = 40.0;
        final path = Path()
          ..moveTo(fromX, y)
          ..lineTo(fromX + loopWidth, y)
          ..lineTo(fromX + loopWidth, y + loopHeight)
          ..lineTo(fromX, y + loopHeight);
        
        canvas.drawPath(path, arrowPaint);
        _drawArrowHead(canvas, fromX, y + loopHeight, -math.pi / 2, msgColor.withOpacity(msgProgress));
      } else {
        // 普通消息
        final currentToX = fromX + (toX - fromX) * msgProgress;
        canvas.drawLine(
          Offset(fromX, y),
          Offset(currentToX, y),
          arrowPaint,
        );

        // 箭头
        if (msgProgress > 0.9) {
          final angle = fromX < toX ? 0.0 : math.pi;
          _drawArrowHead(canvas, currentToX, y, angle, msgColor.withOpacity(msgProgress));
        }
      }

      // 消息标签
      final labelStyle = msg.isError ? errorTextStyle : textStyle;
      final labelSpan = TextSpan(
        text: msg.label,
        style: labelStyle.copyWith(fontSize: 11),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      labelPainter.layout(maxWidth: laneWidth - 20);
      
      // 标签背景
      final labelBgRect = Rect.fromCenter(
        center: Offset((fromX + toX) / 2, msg.isSelfMessage ? y + 20 : y - 15),
        width: labelPainter.width + 12,
        height: labelPainter.height + 8,
      );
      final labelBgPaint = Paint()
        ..color = msg.isError ? Colors.red.withOpacity(0.15) : const Color(0xFF1a1a2e)
        ..style = PaintingStyle.fill;
      canvas.drawRect(labelBgRect, labelBgPaint);
      
      labelPainter.paint(
        canvas,
        Offset((fromX + toX) / 2 - labelPainter.width / 2, 
               msg.isSelfMessage ? y + 20 - labelPainter.height / 2 : y - 15 - labelPainter.height / 2),
      );
    }

    // 底部泳道标签
    for (int i = 0; i < participants.length; i++) {
      final x = i * laneWidth + laneWidth / 2;
      final rect = Rect.fromCenter(
        center: Offset(x, size.height - 30),
        width: laneWidth - 16,
        height: 40,
      );

      final bgPaint = Paint()
        ..color = participantColors[i].withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        bgPaint,
      );

      final borderPaint = Paint()
        ..color = participantColors[i].withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        borderPaint,
      );

      final textSpan = TextSpan(
        text: participants[i].replaceAll('\n', ''),
        style: textStyle.copyWith(
          color: participantColors[i],
          fontSize: 11,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 30 - textPainter.height / 2),
      );
    }
  }

  void _drawArrowHead(Canvas canvas, double x, double y, double angle, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final arrowSize = 8.0;
    final path = Path()
      ..moveTo(x, y)
      ..lineTo(x - arrowSize * math.cos(angle - math.pi / 6), y - arrowSize * math.sin(angle - math.pi / 6))
      ..lineTo(x - arrowSize * math.cos(angle + math.pi / 6), y - arrowSize * math.sin(angle + math.pi / 6))
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
