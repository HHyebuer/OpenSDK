import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────

enum FlowNodeRole {
  caller,
  sdkClient,
  sdkServer,
  techCenter,
  gameServer,
  endApp,
  user,
}

class _Participant {
  final String id;
  final String label;
  final FlowNodeRole role;
  const _Participant(this.id, this.label, this.role);
}

class _FlowArrow {
  final String from;
  final String to;
  final String label;
  final FlowPhase phase;
  const _FlowArrow(this.from, this.to, this.label, this.phase);
}

// ─── Flow Diagram Widget ──────────────────────────────────────────────────────

class FlowDiagram extends StatefulWidget {
  final List<LoginStep> steps;
  final bool isLoading;
  final FlowPhase currentPhase;

  const FlowDiagram({
    super.key,
    required this.steps,
    required this.isLoading,
    required this.currentPhase,
  });

  @override
  State<FlowDiagram> createState() => _FlowDiagramState();
}

class _FlowDiagramState extends State<FlowDiagram>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _participants = [
    _Participant('caller', '业务调用方\n(启动器)', FlowNodeRole.caller),
    _Participant('sdkClient', '新SDK\n(客户端)', FlowNodeRole.sdkClient),
    _Participant('sdkServer', '新SDK\n(服务端)', FlowNodeRole.sdkServer),
    _Participant('techCenter', '技术中心\n通行证', FlowNodeRole.techCenter),
    _Participant('gameServer', '游戏业务\n服务器', FlowNodeRole.gameServer),
    _Participant('endApp', '终端应用\n(游戏)', FlowNodeRole.endApp),
    _Participant('user', '用户', FlowNodeRole.user),
  ];

  static const _arrows = [
    // ── Init ──
    _FlowArrow(
      'caller',
      'sdkClient',
      '初始化请求\n(appKey,deviceID)',
      FlowPhase.init,
    ),
    _FlowArrow('sdkClient', 'sdkClient', '初始化本地环境\n(加密/存储模块)', FlowPhase.init),
    _FlowArrow(
      'sdkClient',
      'sdkServer',
      '初始化校验\n(appKey,deviceID)',
      FlowPhase.init,
    ),
    _FlowArrow('sdkServer', 'sdkClient', '初始化结果\n(成功/失败+错误码)', FlowPhase.init),
    // ── Active Login ──
    _FlowArrow(
      'caller',
      'sdkClient',
      '调用登录接口\n(指定登录类型)',
      FlowPhase.activeLogin,
    ),
    _FlowArrow('user', 'endApp', '输入登录凭证\n(账号密码/验证码)', FlowPhase.activeLogin),
    _FlowArrow(
      'sdkClient',
      'sdkClient',
      '前端格式校验\n敏感信息加密',
      FlowPhase.activeLogin,
    ),
    _FlowArrow(
      'sdkClient',
      'sdkServer',
      '加密凭证\n+deviceID+appKey',
      FlowPhase.activeLogin,
    ),
    _FlowArrow(
      'sdkServer',
      'techCenter',
      '凭证校验请求\n(解密后凭证+业务标识)',
      FlowPhase.activeLogin,
    ),
    _FlowArrow(
      'techCenter',
      'sdkServer',
      '用户信息(userID)',
      FlowPhase.activeLogin,
    ),
    _FlowArrow(
      'sdkServer',
      'sdkServer',
      '生成gameToken\n(userID/deviceID/appKey)',
      FlowPhase.activeLogin,
    ),
    _FlowArrow(
      'sdkServer',
      'gameServer',
      '绑定gameToken\n与用户/设备',
      FlowPhase.activeLogin,
    ),
    _FlowArrow('gameServer', 'sdkServer', '绑定成功确认', FlowPhase.activeLogin),
    _FlowArrow(
      'sdkServer',
      'sdkClient',
      '登录成功\n(userID,gameToken)',
      FlowPhase.activeLogin,
    ),
    _FlowArrow(
      'sdkClient',
      'sdkClient',
      '本地加密储存\ngameToken+用户信息',
      FlowPhase.activeLogin,
    ),
    _FlowArrow('sdkClient', 'caller', '登录成功+核心信息', FlowPhase.activeLogin),
    // ── Auto Login ──
    _FlowArrow(
      'caller',
      'sdkClient',
      '调用免登接口\n(deviceID,appKey)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow(
      'sdkClient',
      'sdkClient',
      '读取本地gameToken\n(校验有效期)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow(
      'sdkClient',
      'sdkServer',
      '免登请求\n(gameToken,deviceID,appKey)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow(
      'sdkServer',
      'sdkServer',
      '校验gameToken\n(Token+设备+权限)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow('sdkServer', 'techCenter', '用户信息(userID)', FlowPhase.autoLogin),
    _FlowArrow(
      'techCenter',
      'sdkServer',
      '同步免登结果\n(userID,gameToken)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow(
      'sdkServer',
      'gameServer',
      '游戏业务鉴权\n(成功/失败)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow('gameServer', 'sdkServer', '用户游戏业务信息', FlowPhase.autoLogin),
    _FlowArrow(
      'sdkServer',
      'sdkClient',
      '免登成功\n(userInfo+游戏信息)',
      FlowPhase.autoLogin,
    ),
    _FlowArrow('sdkClient', 'endApp', '免登结果+启动参数', FlowPhase.autoLogin),
    _FlowArrow('endApp', 'caller', '终端应用初始化完成', FlowPhase.autoLogin),
    // ── Logout ──
    _FlowArrow('caller', 'sdkClient', '调用退出登录接口\n(userID)', FlowPhase.logout),
    _FlowArrow(
      'sdkClient',
      'sdkClient',
      '读取本地gameToken\n准备注销请求',
      FlowPhase.logout,
    ),
    _FlowArrow(
      'sdkClient',
      'sdkServer',
      '退出请求\n(userID,gameToken,deviceID)',
      FlowPhase.logout,
    ),
    _FlowArrow(
      'sdkServer',
      'sdkServer',
      '吊销gameToken\n(服务端失效)',
      FlowPhase.logout,
    ),
    _FlowArrow('sdkServer', 'gameServer', '通知游戏服务器\n会话终止', FlowPhase.logout),
    _FlowArrow('gameServer', 'sdkServer', '游戏状态已保存\n会话终止确认', FlowPhase.logout),
    _FlowArrow('sdkServer', 'techCenter', '注销用户会话\nToken', FlowPhase.logout),
    _FlowArrow('techCenter', 'sdkServer', '会话已失效确认', FlowPhase.logout),
    _FlowArrow(
      'sdkServer',
      'sdkClient',
      '退出成功\n(所有Token已吊销)',
      FlowPhase.logout,
    ),
    _FlowArrow(
      'sdkClient',
      'sdkClient',
      '清除本地缓存\n(gameToken+用户信息)',
      FlowPhase.logout,
    ),
    _FlowArrow('sdkClient', 'caller', '退出登录成功回调', FlowPhase.logout),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _roleColor(FlowNodeRole role) {
    switch (role) {
      case FlowNodeRole.caller:
        return const Color(0xFF818CF8);
      case FlowNodeRole.sdkClient:
        return const Color(0xFF60A5FA);
      case FlowNodeRole.sdkServer:
        return const Color(0xFF22D3EE);
      case FlowNodeRole.techCenter:
        return const Color(0xFFA78BFA);
      case FlowNodeRole.gameServer:
        return const Color(0xFF34D399);
      case FlowNodeRole.endApp:
        return const Color(0xFFFBBF24);
      case FlowNodeRole.user:
        return const Color(0xFFF472B6);
    }
  }

  Color _phaseColor(FlowPhase phase) {
    switch (phase) {
      case FlowPhase.init:
        return const Color(0xFF22D3EE);
      case FlowPhase.activeLogin:
        return const Color(0xFF818CF8);
      case FlowPhase.autoLogin:
        return const Color(0xFF34D399);
      case FlowPhase.logout:
        return const Color(0xFFFB923C);
      case FlowPhase.networkError:
        return const Color(0xFFF87171);
    }
  }

  String _phaseLabel(FlowPhase phase) {
    switch (phase) {
      case FlowPhase.init:
        return '前置流程：新SDK初始化';
      case FlowPhase.activeLogin:
        return '流程1：主动登录';
      case FlowPhase.autoLogin:
        return '流程2：gameToken免登';
      case FlowPhase.logout:
        return '流程3：退出登录';
      case FlowPhase.networkError:
        return '全局异常：网络中断';
    }
  }

  int _participantIndex(String id) =>
      _participants.indexWhere((p) => p.id == id);

  bool _isArrowVisible(_FlowArrow arrow) {
    if (widget.steps.isEmpty) return false;
    final phaseArrows = _arrows.where((a) => a.phase == arrow.phase).toList();
    final phaseSteps = widget.steps
        .where((s) => s.phase == arrow.phase)
        .toList();
    final idx = phaseArrows.indexOf(arrow);
    return idx >= 0 && idx < phaseSteps.length;
  }

  bool _isArrowActive(_FlowArrow arrow) {
    if (!widget.isLoading) return false;
    if (arrow.phase != widget.currentPhase) return false;
    final phaseArrows = _arrows.where((a) => a.phase == arrow.phase).toList();
    final phaseSteps = widget.steps
        .where((s) => s.phase == arrow.phase)
        .toList();
    final idx = phaseArrows.indexOf(arrow);
    return idx == phaseSteps.length - 1;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262D)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return _buildBody(constraints.maxWidth);
              },
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_tree_outlined,
            color: Color(0xFF58A6FF),
            size: 15,
          ),
          const SizedBox(width: 7),
          const Text(
            'SDK 业务时序图',
            style: TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (widget.isLoading)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Opacity(
                opacity: _pulseAnim.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _phaseColor(widget.currentPhase).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _phaseColor(widget.currentPhase).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _phaseColor(widget.currentPhase),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _phaseLabel(widget.currentPhase),
                        style: TextStyle(
                          color: _phaseColor(widget.currentPhase),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(double totalWidth) {
    final colCount = _participants.length;
    final colW = totalWidth / colCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Participant headers
          _buildParticipantHeaders(colW),
          const SizedBox(height: 4),
          // Phase sections
          _buildPhaseSection(FlowPhase.init, colW),
          _buildPhaseSection(FlowPhase.activeLogin, colW),
          _buildPhaseSection(FlowPhase.autoLogin, colW),
          _buildPhaseSection(FlowPhase.logout, colW),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildParticipantHeaders(double colW) {
    return Row(
      children: _participants.map((p) {
        final color = _roleColor(p.role);
        return SizedBox(
          width: colW,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Text(
              p.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhaseSection(FlowPhase phase, double colW) {
    final phaseArrows = _arrows.where((a) => a.phase == phase).toList();
    final color = _phaseColor(phase);
    final hasActivity = widget.steps.any((s) => s.phase == phase);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: hasActivity
            ? color.withOpacity(0.04)
            : Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasActivity
              ? color.withOpacity(0.25)
              : const Color(0xFF21262D),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              _phaseLabel(phase),
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Arrows
          ...phaseArrows.map((arrow) {
            final visible = _isArrowVisible(arrow);
            final active = _isArrowActive(arrow);
            return _buildArrowRow(arrow, visible, active, colW);
          }),
        ],
      ),
    );
  }

  Widget _buildArrowRow(
    _FlowArrow arrow,
    bool visible,
    bool active,
    double colW,
  ) {
    final fromIdx = _participantIndex(arrow.from);
    final toIdx = _participantIndex(arrow.to);
    final isSelf = fromIdx == toIdx;
    final color = _phaseColor(arrow.phase);

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.12,
      duration: const Duration(milliseconds: 400),
      child: SizedBox(
        height: isSelf ? 44 : 38,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Lifelines
            ..._participants.asMap().entries.map((e) {
              final cx = (e.key + 0.5) * colW;
              final lc = _roleColor(e.value.role);
              return Positioned(
                left: cx - 0.5,
                top: 0,
                bottom: 0,
                width: 1,
                child: Container(color: lc.withOpacity(0.15)),
              );
            }),
            // Arrow + label
            if (visible)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => CustomPaint(
                  painter: _SequenceArrowPainter(
                    fromX: (fromIdx + 0.5) * colW,
                    toX: (toIdx + 0.5) * colW,
                    isSelf: isSelf,
                    color: active ? color : color.withOpacity(0.75),
                    isActive: active,
                    pulse: _pulseAnim.value,
                    label: arrow.label,
                  ),
                  size: Size(double.infinity, isSelf ? 44 : 38),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Row(
        children: [
          _dot('初始化', const Color(0xFF22D3EE)),
          const SizedBox(width: 10),
          _dot('主动登录', const Color(0xFF818CF8)),
          const SizedBox(width: 10),
          _dot('免登', const Color(0xFF34D399)),
          const SizedBox(width: 10),
          _dot('退出登录', const Color(0xFFFB923C)),
          const Spacer(),
          Text(
            '${widget.steps.length} events',
            style: const TextStyle(color: Color(0xFF484F58), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _dot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 9)),
      ],
    );
  }
}

// ─── Sequence Arrow Painter ───────────────────────────────────────────────────

class _SequenceArrowPainter extends CustomPainter {
  final double fromX;
  final double toX;
  final bool isSelf;
  final Color color;
  final bool isActive;
  final double pulse;
  final String label;

  _SequenceArrowPainter({
    required this.fromX,
    required this.toX,
    required this.isSelf,
    required this.color,
    required this.isActive,
    required this.pulse,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveColor = isActive ? color.withOpacity(pulse) : color;
    final linePaint = Paint()
      ..color = effectiveColor
      ..strokeWidth = isActive ? 1.8 : 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final midY = isSelf ? size.height * 0.45 : size.height / 2;

    if (isSelf) {
      // Self-loop
      final path = Path()
        ..moveTo(fromX, midY - 8)
        ..cubicTo(fromX + 22, midY - 16, fromX + 22, midY + 8, fromX, midY + 8);
      canvas.drawPath(path, linePaint);
      _arrowHead(
        canvas,
        effectiveColor,
        fromX + 3,
        midY + 8,
        fromX,
        midY + 8,
        goRight: false,
      );
    } else {
      // Horizontal arrow
      final goRight = toX > fromX;
      canvas.drawLine(Offset(fromX, midY), Offset(toX, midY), linePaint);
      _arrowHead(
        canvas,
        effectiveColor,
        fromX,
        midY,
        toX,
        midY,
        goRight: goRight,
      );
    }

    // Glow when active
    if (isActive && !isSelf) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.18 * pulse)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(Offset(fromX, midY), Offset(toX, midY), glowPaint);
    }

    // Label
    _drawLabel(canvas, size, midY);
  }

  void _arrowHead(
    Canvas canvas,
    Color c,
    double x1,
    double y1,
    double x2,
    double y2, {
    required bool goRight,
  }) {
    const s = 5.5;
    final paint = Paint()
      ..color = c
      ..style = PaintingStyle.fill;
    final path = Path();
    if (goRight) {
      path.moveTo(x2, y2);
      path.lineTo(x2 - s, y2 - s * 0.55);
      path.lineTo(x2 - s, y2 + s * 0.55);
    } else {
      path.moveTo(x2, y2);
      path.lineTo(x2 + s, y2 - s * 0.55);
      path.lineTo(x2 + s, y2 + s * 0.55);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLabel(Canvas canvas, Size size, double midY) {
    final lines = label.split('\n');
    final textColor = isActive ? color : color.withOpacity(0.85);
    final fontSize = isActive ? 7.5 : 7.0;

    double labelX;
    if (isSelf) {
      labelX = fromX + 26;
    } else {
      final minX = fromX < toX ? fromX : toX;
      final maxX = fromX < toX ? toX : fromX;
      labelX = (minX + maxX) / 2;
    }

    for (int i = 0; i < lines.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: lines[i],
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final yOffset = midY - (lines.length * 8.5) / 2 + i * 8.5 - 1;
      tp.paint(canvas, Offset(labelX - tp.width / 2, yOffset));
    }
  }

  @override
  bool shouldRepaint(_SequenceArrowPainter old) =>
      old.isActive != isActive ||
      old.pulse != pulse ||
      old.color != color ||
      old.label != label;
}
