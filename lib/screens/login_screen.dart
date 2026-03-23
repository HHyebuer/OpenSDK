import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/flow_diagram.dart';
import '../widgets/login_dialog.dart';
import 'sdk_console_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Auth State ─────────────────────────────────────────────────────────────
  bool _sdkInitialized = false;
  bool _sdkInitializing = false;
  bool _loginProcessing = false;
  bool _logoutProcessing = false;
  bool _autoLoginProcessing = false;
  bool _isLoggedIn = false;
  String? _loggedInUser;
  String? _userId;
  String? _gameToken;

  FlowPhase _currentPhase = FlowPhase.initial;
  final List<LoginStep> _flowSteps = [];

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _bgController;
  late AnimationController _heroController;
  late AnimationController _userCardController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _userCardAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));
    _heroController.forward();

    _userCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _userCardAnim = CurvedAnimation(
      parent: _userCardController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _heroController.dispose();
    _userCardController.dispose();
    super.dispose();
  }

  // ── SDK Init + Login ───────────────────────────────────────────────────────
  Future<void> _triggerLogin() async {
    if (_isLoggedIn || _loginProcessing || _sdkInitializing) return;

    if (!_sdkInitialized) {
      // First: init SDK
      setState(() {
        _sdkInitializing = true;
        _currentPhase = FlowPhase.initialization;
        _flowSteps.clear();
      });
      await for (final step in AuthService.initSDK()) {
        if (!mounted) return;
        setState(() => _flowSteps.add(step));
      }
      if (!mounted) return;
      setState(() {
        _sdkInitialized = true;
        _sdkInitializing = false;
      });
    }

    // Then: show login dialog
    _showLoginDialog();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (ctx) => LoginDialog(
        onLoginSuccess: (username) {
          Navigator.of(ctx).pop();
          _runActiveLoginFlow(username);
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _runActiveLoginFlow(String username) async {
    setState(() {
      _loginProcessing = true;
      _currentPhase = FlowPhase.login;
    });

    String? capturedUserId;
    String? capturedToken;

    await for (final step in AuthService.activeLogin(username, '***')) {
      if (!mounted) return;
      setState(() => _flowSteps.add(step));
      // Extract userId and gameToken from log messages
      if (step.message.contains('userID assigned:')) {
        capturedUserId = step.message.split('userID assigned:').last.trim();
      }
      if (step.message.contains('gameToken:')) {
        capturedToken =
            'GT_${username.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    if (!mounted) return;
    setState(() {
      _loginProcessing = false;
      _isLoggedIn = true;
      _loggedInUser = username;
      _userId =
          capturedUserId ??
          'USR_${username.toUpperCase().substring(0, math.min(6, username.length))}';
      _gameToken = capturedToken ?? 'GT_CACHED_TOKEN';
    });
    _userCardController.forward(from: 0);
  }

  // ── Auto Login (Start Game) ────────────────────────────────────────────────
  Future<void> _triggerAutoLogin() async {
    if (!_isLoggedIn) {
      _showToast('请先登录账号', isError: true);
      return;
    }
    if (_autoLoginProcessing) return;

    setState(() {
      _autoLoginProcessing = true;
      _currentPhase = FlowPhase.autoLogin;
    });

    await for (final step in AuthService.autoLogin()) {
      if (!mounted) return;
      setState(() => _flowSteps.add(step));
    }

    if (!mounted) return;
    setState(() => _autoLoginProcessing = false);
    _showToast('🎮 游戏免登成功！正在启动游戏...', isError: false);
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _triggerLogout() async {
    if (!_isLoggedIn || _logoutProcessing) return;

    setState(() {
      _logoutProcessing = true;
      _currentPhase = FlowPhase.logout;
    });

    await for (final step in AuthService.logout(_userId ?? 'unknown')) {
      if (!mounted) return;
      setState(() => _flowSteps.add(step));
    }

    if (!mounted) return;
    _userCardController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _logoutProcessing = false;
      _isLoggedIn = false;
      _loggedInUser = null;
      _userId = null;
      _gameToken = null;
      _sdkInitialized = false; // reset so next login re-inits
    });
    _showToast('已退出登录', isError: false);
  }

  // ── Toast ──────────────────────────────────────────────────────────────────
  void _showToast(String message, {required bool isError}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(message: message, isError: isError),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 860;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBg(),
          SafeArea(child: isWide ? _buildWideLayout() : _buildNarrowLayout()),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 55,
          child: FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: _heroSlide,
              child: _buildLauncherPage(constrained: true),
            ),
          ),
        ),
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
            child: FlowDiagram(
              currentPhase: _currentPhase,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLauncherPage(constrained: false),
          if (_flowSteps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 400,
                child: FlowDiagram(
                  currentPhase: _currentPhase,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Game Launcher Page ─────────────────────────────────────────────────────
  Widget _buildLauncherPage({bool constrained = true}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLauncherTopBar(),
        if (constrained) const Spacer(flex: 2),
        if (!constrained) const SizedBox(height: 40),
        _buildGameHero(),
        if (constrained) const Spacer(flex: 1),
        if (!constrained) const SizedBox(height: 20),
        _buildGameInfo(),
        const SizedBox(height: 20),
        // User info card (shown after login)
        AnimatedBuilder(
          animation: _userCardAnim,
          builder: (_, child) => Transform.scale(
            scale: _userCardAnim.value,
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: _userCardAnim.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
          child: _isLoggedIn ? _buildUserInfoCard() : const SizedBox.shrink(),
        ),
        if (_isLoggedIn) const SizedBox(height: 16),
        _buildActionButtons(),
        if (constrained) const Spacer(flex: 2),
        if (!constrained) const SizedBox(height: 40),
        _buildBottomBar(),
      ],
    );
    return Padding(padding: const EdgeInsets.all(32), child: content);
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildLauncherTopBar() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.gamepad_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'NEXUS LAUNCHER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        // Nav items
        ...[('首页', true), ('游戏库', false), ('社区', false), ('商城', false)].map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              item.$1,
              style: TextStyle(
                color: item.$2 ? Colors.white : Colors.white38,
                fontSize: 13,
                fontWeight: item.$2 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // SDK Console entry
        GestureDetector(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SdkConsoleScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.dashboard_outlined, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'SDK控制台',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isLoggedIn
                ? const Color(0xFF6C63FF).withOpacity(0.2)
                : Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: _isLoggedIn
                ? Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5))
                : null,
          ),
          child: Icon(
            _isLoggedIn ? Icons.person : Icons.person_outline,
            color: _isLoggedIn ? const Color(0xFF6C63FF) : Colors.white54,
            size: 18,
          ),
        ),
      ],
    );
  }

  // ── User Info Card ─────────────────────────────────────────────────────────
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.08),
            const Color(0xFF10B981).withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (_loggedInUser ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _loggedInUser ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        '已登录',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'ID: ${_userId ?? ''}  ·  Token: ${_gameToken?.substring(0, math.min(20, _gameToken?.length ?? 0)) ?? ''}...',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Logout button
          GestureDetector(
            onTap: _logoutProcessing ? null : _triggerLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _logoutProcessing
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _logoutProcessing
                      ? Colors.white12
                      : const Color(0xFFEF4444).withOpacity(0.35),
                ),
              ),
              child: _logoutProcessing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFEF4444),
                        ),
                      ),
                    )
                  : const Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xFFEF4444), size: 14),
                        SizedBox(width: 4),
                        Text(
                          '退出登录',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Game Hero Banner ───────────────────────────────────────────────────────
  Widget _buildGameHero() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0533), Color(0xFF0D1B4B), Color(0xFF0A2A1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 40,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW RELEASE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'NEXUS\nCHRONICLES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => const Icon(
                        Icons.star,
                        color: Color(0xFFFBBF24),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '4.9  ·  RPG  ·  Online',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 28,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Row(
      children: [
        _buildInfoChip(
          Icons.download_outlined,
          '2.4 GB',
          const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 12),
        _buildInfoChip(
          Icons.people_outline,
          '1.2M 在线',
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 12),
        _buildInfoChip(Icons.update, 'v3.2.1', const Color(0xFFF59E0B)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
              SizedBox(width: 5),
              Text(
                '服务器正常',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    final bool anyProcessing =
        _sdkInitializing ||
        _loginProcessing ||
        _autoLoginProcessing ||
        _logoutProcessing;

    return Row(
      children: [
        // ── Login Button ──
        Expanded(
          flex: 2,
          child: _buildMainBtn(
            label: _sdkInitializing
                ? 'SDK 初始化中...'
                : _loginProcessing
                ? '登录验证中...'
                : _isLoggedIn
                ? '已登录'
                : '登录账号',
            icon: _isLoggedIn ? Icons.check_circle_outline : Icons.login,
            isLoading: _sdkInitializing || _loginProcessing,
            isDisabled: _isLoggedIn || anyProcessing,
            gradient: _isLoggedIn
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            glowColor: _isLoggedIn
                ? const Color(0xFF10B981)
                : const Color(0xFF6C63FF),
            onTap: _triggerLogin,
          ),
        ),
        const SizedBox(width: 12),
        // ── Start Game Button ──
        Expanded(
          flex: 3,
          child: _buildMainBtn(
            label: _autoLoginProcessing ? '免登验证中...' : '开始游戏',
            icon: Icons.play_arrow_rounded,
            isLoading: _autoLoginProcessing,
            isDisabled: anyProcessing,
            gradient: anyProcessing && !_autoLoginProcessing
                ? const LinearGradient(
                    colors: [Color(0xFF2A2A3A), Color(0xFF2A2A3A)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFF6584), Color(0xFFFF8C42)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            glowColor: const Color(0xFFFF6584),
            onTap: _triggerAutoLogin,
          ),
        ),
        const SizedBox(width: 12),
        _buildSecondaryBtn(Icons.download_rounded, '下载'),
        const SizedBox(width: 10),
        _buildSecondaryBtn(Icons.info_outline, '详情'),
      ],
    );
  }

  Widget _buildMainBtn({
    required String label,
    required IconData icon,
    required bool isLoading,
    required bool isDisabled,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          gradient: isDisabled && !isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF2A2A3A), Color(0xFF2A2A3A)],
                )
              : gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDisabled && !isLoading
              ? []
              : [
                  BoxShadow(
                    color: glowColor.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSecondaryBtn(IconData icon, String label) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        const Text(
          'Powered by  ',
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
          ),
          child: const Text(
            'NexusAuth SDK v2.4.1',
            style: TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const Spacer(),
        const Text(
          '© 2024 Nexus Games  ·  隐私政策  ·  用户协议',
          style: TextStyle(color: Color(0x2EFFFFFF), fontSize: 10),
        ),
      ],
    );
  }

  // ── Animated Background ────────────────────────────────────────────────────
  Widget _buildAnimatedBg() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(_bgController.value),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0A1A), Color(0xFF0F0C29), Color(0xFF1A0A2E)],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Toast Widget ───────────────────────────────────────────────────────────────
class _ToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  const _ToastWidget({required this.message, required this.isError});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, child) => Transform.scale(
            scale: _anim.value,
            child: Opacity(opacity: _anim.value.clamp(0.0, 1.0), child: child),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.message,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Background Painter ─────────────────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final double progress;
  _BgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final orbs = [
      (0.1, 0.15, 200.0, const Color(0xFF6C63FF), 0.0),
      (0.85, 0.1, 140.0, const Color(0xFFFF6584), 0.25),
      (0.7, 0.8, 180.0, const Color(0xFF10B981), 0.5),
      (0.05, 0.85, 120.0, const Color(0xFF3B82F6), 0.75),
      (0.95, 0.5, 100.0, const Color(0xFFF59E0B), 0.1),
    ];
    for (final orb in orbs) {
      final phase = (progress + orb.$5) % 1.0;
      final ox = math.sin(phase * 2 * math.pi) * 25;
      final oy = math.cos(phase * 2 * math.pi) * 18;
      final center = Offset(
        size.width * orb.$1 + ox,
        size.height * orb.$2 + oy,
      );
      paint.color = orb.$4.withOpacity(0.03);
      canvas.drawCircle(center, orb.$3 * 3, paint);
      paint.color = orb.$4.withOpacity(0.06);
      canvas.drawCircle(center, orb.$3 * 1.5, paint);
      paint.color = orb.$4.withOpacity(0.1);
      canvas.drawCircle(center, orb.$3, paint);
    }
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const gs = 70.0;
    for (double x = 0; x < size.width; x += gs) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gs) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.progress != progress;
}
