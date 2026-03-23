import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class SdkProject {
  final String id;
  final String name;
  final String appId;
  final String appKey;
  final String platform;
  final String status;
  final int dau;
  final int totalUsers;
  final DateTime createdAt;

  SdkProject({
    required this.id,
    required this.name,
    required this.appId,
    required this.appKey,
    required this.platform,
    required this.status,
    required this.dau,
    required this.totalUsers,
    required this.createdAt,
  });
}

// ─── SDK Console Screen ───────────────────────────────────────────────────────

class SdkConsoleScreen extends StatefulWidget {
  const SdkConsoleScreen({super.key});

  @override
  State<SdkConsoleScreen> createState() => _SdkConsoleScreenState();
}

class _SdkConsoleScreenState extends State<SdkConsoleScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNav = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Mock data
  final List<SdkProject> _projects = [
    SdkProject(
      id: '1',
      name: 'Nexus Chronicles',
      appId: 'APP_20240322_NEXUS',
      appKey: 'sk-nexus-9f3a2b1c4d5e6f7a',
      platform: 'PC / Mobile',
      status: 'active',
      dau: 12847,
      totalUsers: 1284700,
      createdAt: DateTime(2024, 3, 22),
    ),
    SdkProject(
      id: '2',
      name: 'StarForge Online',
      appId: 'APP_20240115_STAR',
      appKey: 'sk-star-a1b2c3d4e5f6g7h8',
      platform: 'PC',
      status: 'active',
      dau: 8320,
      totalUsers: 432100,
      createdAt: DateTime(2024, 1, 15),
    ),
    SdkProject(
      id: '3',
      name: 'MythBlade Mobile',
      appId: 'APP_20231201_MYTH',
      appKey: 'sk-myth-z9y8x7w6v5u4t3s2',
      platform: 'Mobile',
      status: 'testing',
      dau: 0,
      totalUsers: 0,
      createdAt: DateTime(2023, 12, 1),
    ),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, '概览'),
    _NavItem(Icons.apps_outlined, Icons.apps, '项目管理'),
    _NavItem(Icons.tune_outlined, Icons.tune, '参数配置'),
    _NavItem(Icons.lock_outline, Icons.lock, '登录方式'),
    _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, '数据分析'),
    _NavItem(Icons.security_outlined, Icons.security, '安全策略'),
    _NavItem(Icons.notifications_outlined, Icons.notifications, '消息通知'),
    _NavItem(Icons.people_outline, Icons.people, '团队管理'),
    _NavItem(Icons.receipt_long_outlined, Icons.receipt_long, '操作日志'),
    _NavItem(Icons.help_outline, Icons.help, '文档中心'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchNav(int index) {
    if (index == _selectedNav) return;
    _fadeCtrl.forward(from: 0);
    setState(() => _selectedNav = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sidebar ────────────────────────────────────────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(right: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NexusAuth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'SDK 控制台',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF21262D), height: 1),
          const SizedBox(height: 8),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: _navItems.length,
              itemBuilder: (_, i) {
                final item = _navItems[i];
                final selected = _selectedNav == i;
                return GestureDetector(
                  onTap: () => _switchNav(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6C63FF).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected
                              ? const Color(0xFF6C63FF)
                              : Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected
                                ? const Color(0xFF6C63FF)
                                : Colors.white54,
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (i == 4) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom user info
          const Divider(color: Color(0xFF21262D), height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@nexus.com',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white24,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    final titles = [
      '概览',
      '项目管理',
      '参数配置',
      '登录方式',
      '数据分析',
      '安全策略',
      '消息通知',
      '团队管理',
      '操作日志',
      '文档中心',
    ];
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Row(
        children: [
          Text(
            titles[_selectedNav],
            style: const TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
              ),
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
          // Search
          Container(
            width: 200,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.search, color: Colors.white24, size: 16),
                SizedBox(width: 6),
                Text(
                  '搜索...',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Notification
          Stack(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white38,
                  size: 18,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Content Router ─────────────────────────────────────────────────────────
  Widget _buildContent() {
    switch (_selectedNav) {
      case 0:
        return _buildOverviewPage();
      case 1:
        return _buildProjectsPage();
      case 2:
        return _buildConfigPage();
      case 3:
        return _buildLoginMethodsPage();
      case 4:
        return _buildAnalyticsPage();
      case 5:
        return _buildSecurityPage();
      case 6:
        return _buildNotificationsPage();
      case 7:
        return _buildTeamPage();
      case 8:
        return _buildLogsPage();
      case 9:
        return _buildDocsPage();
      default:
        return _buildOverviewPage();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 0: Overview
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildOverviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(
            '欢迎使用 NexusAuth SDK 控制台。在这里您可以管理所有接入项目、配置登录参数、查看数据分析，以及监控安全状态。',
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _statCard(
                '接入项目',
                '3',
                Icons.apps,
                const Color(0xFF6C63FF),
                '+1 本月',
              ),
              const SizedBox(width: 16),
              _statCard(
                '今日活跃用户',
                '21,167',
                Icons.people,
                const Color(0xFF10B981),
                '+12.3%',
              ),
              const SizedBox(width: 16),
              _statCard(
                '累计注册用户',
                '1,716,800',
                Icons.person_add,
                const Color(0xFF3B82F6),
                '+5.8%',
              ),
              const SizedBox(width: 16),
              _statCard(
                '今日登录次数',
                '48,392',
                Icons.login,
                const Color(0xFFF59E0B),
                '+8.1%',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRecentActivity()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildQuickActions()),
            ],
          ),
          const SizedBox(height: 16),
          _buildSystemStatus(),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      ('Nexus Chronicles', '新增用户登录', '2分钟前', const Color(0xFF10B981)),
      ('StarForge Online', 'SDK初始化成功', '5分钟前', const Color(0xFF3B82F6)),
      ('MythBlade Mobile', '测试环境部署', '12分钟前', const Color(0xFFF59E0B)),
      ('Nexus Chronicles', '批量用户导入', '1小时前', const Color(0xFF6C63FF)),
      ('StarForge Online', '安全策略更新', '2小时前', const Color(0xFFEF4444)),
      ('Nexus Chronicles', 'gameToken刷新', '3小时前', const Color(0xFF10B981)),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('最近活动', Icons.history),
          const SizedBox(height: 14),
          ...activities.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: a.$4,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.$1,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          a.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    a.$3,
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        '新建项目',
        Icons.add_circle_outline,
        const Color(0xFF6C63FF),
        '快速接入新游戏，自动生成AppID和AppKey',
      ),
      (
        '查看文档',
        Icons.menu_book_outlined,
        const Color(0xFF3B82F6),
        '查阅SDK集成文档和API参考手册',
      ),
      (
        '数据导出',
        Icons.download_outlined,
        const Color(0xFF10B981),
        '导出用户数据和登录统计报表',
      ),
      ('安全检查', Icons.shield_outlined, const Color(0xFFF59E0B), '运行安全扫描，检测潜在风险'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('快捷操作', Icons.flash_on_outlined),
          const SizedBox(height: 14),
          ...actions.map(
            (a) => GestureDetector(
              onTap: () => _showActionToast(a.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: a.$3.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: a.$3.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(a.$2, color: a.$3, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.$1,
                            style: TextStyle(
                              color: a.$3,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            a.$4,
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: a.$3.withOpacity(0.5),
                      size: 12,
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

  Widget _buildSystemStatus() {
    final services = [
      ('SDK 认证服务', '正常', const Color(0xFF10B981), '99.98%'),
      ('技术中心通行证', '正常', const Color(0xFF10B981), '99.95%'),
      ('游戏业务服务器', '正常', const Color(0xFF10B981), '99.91%'),
      ('数据分析服务', '维护中', const Color(0xFFF59E0B), '98.20%'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('系统状态', Icons.monitor_heart_outlined),
          const SizedBox(height: 14),
          Row(
            children: services
                .map(
                  (s) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: s.$3.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: s.$3.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: s.$3,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.$2,
                                style: TextStyle(
                                  color: s.$3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.$1,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '可用率 ${s.$4}',
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 1: Projects
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildProjectsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(
            '管理所有接入 NexusAuth SDK 的游戏项目。每个项目拥有独立的 AppID 和 AppKey，用于 SDK 初始化时的身份验证。新建项目后，系统将自动生成密钥对，请妥善保管 AppKey，切勿泄露。',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                '项目列表',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _actionButton(
                '新建项目',
                Icons.add,
                const Color(0xFF6C63FF),
                () => _showCreateProjectDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._projects.map((p) => _buildProjectCard(p)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(SdkProject p) {
    final statusColor = p.status == 'active'
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final statusLabel = p.status == 'active' ? '运行中' : '测试中';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: statusColor.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '平台: ${p.platform}  ·  创建于 ${p.createdAt.year}-${p.createdAt.month.toString().padLeft(2, '0')}-${p.createdAt.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _iconBtn(Icons.settings_outlined, '配置', () => _switchNav(2)),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.bar_chart_outlined, '数据', () => _switchNav(4)),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.more_horiz, '更多', () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF21262D), height: 1),
          const SizedBox(height: 14),
          // AppID / AppKey
          Row(
            children: [
              Expanded(child: _keyField('AppID', p.appId, canCopy: true)),
              const SizedBox(width: 16),
              Expanded(
                child: _keyField(
                  'AppKey',
                  '${p.appKey.substring(0, 12)}••••••••••••••••',
                  canCopy: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _keyField(
                  'DAU',
                  p.dau > 0 ? '${(p.dau / 1000).toStringAsFixed(1)}K' : '-',
                  canCopy: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _keyField(
                  '累计用户',
                  p.totalUsers > 0
                      ? '${(p.totalUsers / 10000).toStringAsFixed(1)}W'
                      : '-',
                  canCopy: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyField(String label, String value, {required bool canCopy}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (canCopy)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  _showActionToast('已复制到剪贴板');
                },
                child: const Icon(
                  Icons.copy_outlined,
                  color: Colors.white24,
                  size: 14,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 2: Config
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildConfigPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(
            '配置 SDK 的核心运行参数。这些参数将影响 SDK 的初始化行为、Token 有效期、加密策略等。修改配置后需重新初始化 SDK 才能生效，建议在低峰期进行变更。',
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTokenConfig()),
              const SizedBox(width: 16),
              Expanded(child: _buildEncryptConfig()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildNetworkConfig()),
              const SizedBox(width: 16),
              Expanded(child: _buildEnvConfig()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenConfig() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Token 配置', Icons.token_outlined),
          _configDesc('gameToken 是用户登录成功后颁发的游戏凭证，用于免登流程。合理设置有效期可以平衡安全性与用户体验。'),
          const SizedBox(height: 14),
          _configItem('gameToken 有效期', '7 天', '用户登录后 gameToken 的存活时间，超期需重新登录'),
          _configItem('自动续期', '开启', '在 Token 过期前 24 小时自动刷新，避免用户被强制下线'),
          _configItem('最大并发设备数', '3 台', '同一账号允许同时在线的设备数量上限'),
          _configItem('Token 刷新策略', '滑动窗口', '每次使用 Token 时重置有效期计时'),
          const SizedBox(height: 12),
          _actionButton(
            '保存配置',
            Icons.save_outlined,
            const Color(0xFF6C63FF),
            () => _showActionToast('Token 配置已保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptConfig() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('加密配置', Icons.enhanced_encryption_outlined),
          _configDesc(
            'SDK 使用多层加密保护用户凭证。前端使用 RSA-2048 加密传输，服务端使用 AES-256 存储。定期轮换密钥可提升安全性。',
          ),
          const SizedBox(height: 14),
          _configItem('传输加密算法', 'RSA-2048', '用于客户端到服务端的凭证加密传输'),
          _configItem('存储加密算法', 'AES-256-GCM', '用于本地 gameToken 和用户信息的加密存储'),
          _configItem('密钥轮换周期', '90 天', '服务端公私钥对的自动轮换周期'),
          _configItem('TLS 版本', 'TLS 1.3', '网络传输层安全协议版本'),
          const SizedBox(height: 12),
          _actionButton(
            '轮换密钥',
            Icons.refresh,
            const Color(0xFFF59E0B),
            () => _showActionToast('密钥轮换任务已提交'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkConfig() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('网络配置', Icons.wifi_outlined),
          _configDesc('配置 SDK 的网络请求策略。合理的超时和重试配置可以提升弱网环境下的用户体验，避免因网络抖动导致登录失败。'),
          const SizedBox(height: 14),
          _configItem('请求超时时间', '10 秒', '单次 HTTP 请求的最大等待时间'),
          _configItem('重试次数', '3 次', '请求失败后的自动重试次数'),
          _configItem('重试间隔', '指数退避', '每次重试间隔时间按 2 的幂次递增'),
          _configItem('CDN 加速', '开启', '通过 CDN 节点就近接入，降低网络延迟'),
          const SizedBox(height: 12),
          _actionButton(
            '保存配置',
            Icons.save_outlined,
            const Color(0xFF6C63FF),
            () => _showActionToast('网络配置已保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvConfig() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('环境配置', Icons.cloud_outlined),
          _configDesc(
            '管理不同部署环境的 SDK 配置。开发环境用于本地调试，测试环境用于 QA 验证，生产环境为正式上线环境，三套环境数据完全隔离。',
          ),
          const SizedBox(height: 14),
          _configItem('当前环境', '生产环境', '当前 SDK 运行的目标环境'),
          _configItem('服务端地址', 'api.nexusauth.com', '当前环境的 SDK 服务端 API 地址'),
          _configItem('日志级别', 'ERROR', '生产环境建议仅记录错误日志，避免性能损耗'),
          _configItem('调试模式', '关闭', '生产环境必须关闭调试模式，防止信息泄露'),
          const SizedBox(height: 12),
          _actionButton(
            '切换环境',
            Icons.swap_horiz,
            const Color(0xFF10B981),
            () => _showActionToast('环境切换需重启 SDK'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 3: Login Methods
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLoginMethodsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(
            '配置游戏支持的登录方式。SDK 支持多种登录方式并行开启，用户可自由选择。每种登录方式都有独立的配置项，请根据业务需求和目标用户群体进行选择。',
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLoginMethodCard(
                  '账号密码登录',
                  Icons.lock_outline,
                  const Color(0xFF6C63FF),
                  true,
                  '最基础的登录方式，用户使用注册的账号和密码进行身份验证。密码在客户端经过 SHA-256 哈希后，再通过 RSA-2048 加密传输，服务端解密后与数据库中的哈希值比对。',
                  [
                    '密码强度要求: 8位以上，含大小写字母和数字',
                    '登录失败锁定: 连续失败5次锁定30分钟',
                    '密码重置: 支持邮箱/手机号找回',
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLoginMethodCard(
                  '手机验证码登录',
                  Icons.sms_outlined,
                  const Color(0xFF10B981),
                  true,
                  '通过向用户手机发送一次性验证码（OTP）完成身份验证。验证码有效期为 5 分钟，每个手机号每天最多发送 10 条。适合不想记忆密码的用户群体。',
                  ['验证码有效期: 5 分钟', '每日发送上限: 10 条/手机号', '短信服务商: 阿里云 / 腾讯云'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLoginMethodCard(
                  '微信登录',
                  Icons.wechat,
                  const Color(0xFF07C160),
                  true,
                  '通过微信 OAuth 2.0 授权登录。用户无需注册，直接使用微信账号授权即可登录游戏。首次登录时系统会自动创建游戏账号并绑定微信 OpenID。',
                  ['需配置微信开放平台 AppID', '支持微信扫码和移动端授权', '可绑定已有游戏账号'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLoginMethodCard(
                  'Google 登录',
                  Icons.g_mobiledata,
                  const Color(0xFFEA4335),
                  false,
                  '通过 Google OAuth 2.0 授权登录，适合面向海外用户的游戏。需要在 Google Cloud Console 配置 OAuth 客户端，并在 SDK 控制台填入 Client ID。',
                  [
                    '需配置 Google Cloud OAuth 客户端',
                    '支持 Web 和移动端',
                    '需要用户有 Google 账号',
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLoginMethodCard(
                  'SSO 单点登录',
                  Icons.business_center_outlined,
                  const Color(0xFF0078D4),
                  false,
                  '企业级单点登录方案，支持 SAML 2.0 和 OIDC 协议。适合有内部员工账号体系的企业游戏，员工可使用公司账号直接登录，无需额外注册。',
                  [
                    '支持 SAML 2.0 / OIDC 协议',
                    '可对接 Azure AD、Okta 等 IdP',
                    '适合企业内部游戏场景',
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLoginMethodCard(
                  '游客登录',
                  Icons.person_outline,
                  const Color(0xFFFB923C),
                  true,
                  '允许用户无需注册直接以游客身份进入游戏。系统会自动生成临时账号，游客数据与设备绑定。建议引导游客用户绑定正式账号，防止数据丢失。',
                  ['自动生成临时 deviceID 账号', '数据与设备绑定，换设备后丢失', '建议引导绑定正式账号'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginMethodCard(
    String title,
    IconData icon,
    Color color,
    bool enabled,
    String desc,
    List<String> features,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Toggle
              GestureDetector(
                onTap: () =>
                    _showActionToast('${enabled ? "已关闭" : "已开启"} $title'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 22,
                  decoration: BoxDecoration(
                    color: enabled ? color.withOpacity(0.8) : Colors.white12,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: enabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: color.withOpacity(0.7),
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _actionButton(
            '配置详情',
            Icons.settings_outlined,
            color,
            () => _showActionToast('打开 $title 配置'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 4: Analytics
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAnalyticsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(
            '查看 SDK 的登录数据分析。包括用户活跃度、登录方式分布、登录成功率、设备分布等核心指标。数据每小时更新一次，支持按项目和时间范围筛选。',
          ),
          const SizedBox(height: 20),
          // Time range selector
          Row(
            children: [
              ...['今日', '近7天', '近30天', '自定义'].map(
                (t) => GestureDetector(
                  onTap: () => _showActionToast('切换到$t数据'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: t == '近7天'
                          ? const Color(0xFF6C63FF).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: t == '近7天'
                            ? const Color(0xFF6C63FF).withOpacity(0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: t == '近7天'
                            ? const Color(0xFF6C63FF)
                            : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _actionButton(
                '导出报表',
                Icons.download_outlined,
                const Color(0xFF10B981),
                () => _showActionToast('报表导出中...'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statCard(
                '登录成功率',
                '98.7%',
                Icons.check_circle_outline,
                const Color(0xFF10B981),
                '+0.3%',
              ),
              const SizedBox(width: 16),
              _statCard(
                '平均登录耗时',
                '1.24s',
                Icons.timer_outlined,
                const Color(0xFF3B82F6),
                '-0.08s',
              ),
              const SizedBox(width: 16),
              _statCard(
                '免登成功率',
                '94.2%',
                Icons.bolt_outlined,
                const Color(0xFF6C63FF),
                '+1.1%',
              ),
              const SizedBox(width: 16),
              _statCard(
                '新增用户',
                '3,847',
                Icons.person_add_outlined,
                const Color(0xFFF59E0B),
                '+15.2%',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildLoginTrendChart()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildLoginMethodPie()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDeviceDistribution()),
              const SizedBox(width: 16),
              Expanded(child: _buildLoginFailureAnalysis()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTrendChart() {
    final data = [42, 58, 51, 67, 73, 89, 95, 78, 82, 91, 88, 76, 84, 92];
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('登录趋势（近14天）', Icons.show_chart),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((e) {
                final h = (e.value / maxVal) * 100;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF6C63FF),
                                const Color(0xFF6C63FF).withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginMethodPie() {
    final methods = [
      ('账号密码', 0.42, const Color(0xFF6C63FF)),
      ('手机验证码', 0.28, const Color(0xFF10B981)),
      ('微信登录', 0.18, const Color(0xFF07C160)),
      ('游客登录', 0.12, const Color(0xFFFB923C)),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('登录方式分布', Icons.pie_chart_outline),
          const SizedBox(height: 16),
          ...methods.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: m.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.$1,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${(m.$2 * 100).toInt()}%',
                        style: TextStyle(
                          color: m.$3,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: m.$2,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(m.$3),
                      minHeight: 5,
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

  Widget _buildDeviceDistribution() {
    final devices = [
      ('Windows PC', '54.2%', const Color(0xFF3B82F6)),
      ('Android', '28.7%', const Color(0xFF10B981)),
      ('iOS', '12.4%', const Color(0xFFF59E0B)),
      ('macOS', '4.7%', const Color(0xFF6C63FF)),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('设备分布', Icons.devices_outlined),
          const SizedBox(height: 14),
          ...devices.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: d.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.$1,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    d.$2,
                    style: TextStyle(
                      color: d.$3,
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

  Widget _buildLoginFailureAnalysis() {
    final reasons = [
      ('密码错误', '45.3%', const Color(0xFFEF4444)),
      ('账号不存在', '22.1%', const Color(0xFFF59E0B)),
      ('Token 过期', '18.7%', const Color(0xFF6C63FF)),
      ('网络超时', '9.4%', const Color(0xFF3B82F6)),
      ('其他', '4.5%', Colors.white38),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('登录失败原因分析', Icons.error_outline),
          const SizedBox(height: 14),
          ...reasons.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: r.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.$1,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    r.$2,
                    style: TextStyle(
                      color: r.$3,
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

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 5: Security
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSecurityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(
            '配置 SDK 的安全防护策略。包括防暴力破解、IP 黑名单、异常登录检测等。完善的安全策略可以有效防止账号被盗和恶意攻击，保护用户资产安全。',
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSecurityCard(
                  '防暴力破解',
                  Icons.shield_outlined,
                  const Color(0xFFEF4444),
                  '检测并阻止针对账号密码的暴力破解攻击。当同一账号或 IP 在短时间内多次登录失败时，系统将自动触发锁定机制。',
                  [
                    ('账号锁定阈值', '5次/30分钟'),
                    ('IP 封禁阈值', '20次/分钟'),
                    ('锁定时长', '30分钟'),
                    ('解锁方式', '自动解锁/人工审核'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecurityCard(
                  '异常登录检测',
                  Icons.gpp_maybe_outlined,
                  const Color(0xFFF59E0B),
                  '基于机器学习模型检测异常登录行为，包括异地登录、设备突变、登录时间异常等。检测到异常时将触发二次验证或通知用户。',
                  [
                    ('异地登录检测', '开启'),
                    ('设备指纹验证', '开启'),
                    ('行为分析', '开启'),
                    ('风险通知', '短信+邮件'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSecurityCard(
                  'IP 访问控制',
                  Icons.language_outlined,
                  const Color(0xFF3B82F6),
                  '通过 IP 白名单和黑名单控制访问权限。可以限制特定地区或 IP 段的访问，也可以为内部测试人员配置白名单，绕过部分安全检查。',
                  [
                    ('IP 黑名单', '已配置 127 条'),
                    ('IP 白名单', '已配置 8 条'),
                    ('地区限制', '未开启'),
                    ('代理检测', '开启'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecurityCard(
                  '数据合规',
                  Icons.policy_outlined,
                  const Color(0xFF10B981),
                  '确保 SDK 的数据处理符合 GDPR、CCPA 等数据保护法规。包括用户数据最小化收集、数据留存期限设置、用户数据删除权等。',
                  [
                    ('数据留存期限', '3年'),
                    ('用户数据导出', '支持'),
                    ('账号注销', '支持'),
                    ('合规认证', 'ISO 27001'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(
    String title,
    IconData icon,
    Color color,
    String desc,
    List<(String, String)> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _actionButton(
            '配置策略',
            Icons.settings_outlined,
            color,
            () => _showActionToast('打开 $title 配置'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGE 6-9: Placeholder pages
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildNotificationsPage() => _buildPlaceholderPage(
    '消息通知',
    Icons.notifications_outlined,
    const Color(0xFF6C63FF),
    '配置 SDK 事件的通知规则。当发生登录异常、Token 过期、安全告警等事件时，系统将通过邮件、短信或 Webhook 的方式通知相关人员。支持自定义通知模板和接收人分组，确保关键事件第一时间得到响应。',
    ['登录异常告警', '安全事件通知', 'Webhook 推送', '自定义通知模板', '接收人分组管理'],
  );

  Widget _buildTeamPage() => _buildPlaceholderPage(
    '团队管理',
    Icons.people_outline,
    const Color(0xFF10B981),
    '管理控制台的访问权限和团队成员。支持基于角色的访问控制（RBAC），可以为不同成员分配不同的权限级别：超级管理员、项目管理员、数据分析员、只读成员等。所有操作均有审计日志记录。',
    ['成员邀请与管理', '角色权限配置（RBAC）', '操作审计日志', '多因素认证（MFA）', 'SSO 企业账号登录'],
  );

  Widget _buildLogsPage() => _buildPlaceholderPage(
    '操作日志',
    Icons.receipt_long_outlined,
    const Color(0xFFF59E0B),
    '查看控制台的所有操作记录。每一次配置变更、权限修改、密钥操作都会被完整记录，包括操作人、操作时间、操作内容和操作结果。支持按时间、操作类型、操作人进行筛选和导出。',
    ['配置变更记录', '权限操作记录', '密钥操作记录', '登录审计日志', '日志导出（CSV/JSON）'],
  );

  Widget _buildDocsPage() => _buildPlaceholderPage(
    '文档中心',
    Icons.menu_book_outlined,
    const Color(0xFF3B82F6),
    '查阅 NexusAuth SDK 的完整技术文档。包括快速接入指南、API 参考手册、最佳实践、常见问题解答等。文档持续更新，建议收藏常用页面。如有问题，可通过文档页面直接提交工单。',
    ['快速接入指南（5分钟上手）', 'API 参考手册', 'SDK 更新日志', '最佳实践与案例', '常见问题 FAQ'],
  );

  Widget _buildPlaceholderPage(
    String title,
    IconData icon,
    Color color,
    String desc,
    List<String> features,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageDesc(desc),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '功能模块',
                          style: TextStyle(
                            color: color.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '功能特性',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: features
                      .map(
                        (f) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: color,
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                f,
                                style: TextStyle(
                                  color: color.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                _actionButton(
                  '进入$title',
                  icon,
                  color,
                  () => _showActionToast('$title 功能即将上线'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: const Color(0xFF161B22),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF21262D)),
  );

  Widget _pageDesc(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF6C63FF).withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Color(0xFF6C63FF), size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _cardTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: Colors.white54, size: 15),
      const SizedBox(width: 7),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _configDesc(String text) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white30, fontSize: 11, height: 1.5),
    ),
  );

  Widget _configItem(String label, String value, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    ),
  );

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text(
              tooltip,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A1D2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF6C63FF), width: 0.5),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '新建项目',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '创建新项目后，系统将自动生成 AppID 和 AppKey。AppKey 仅在创建时显示一次，请立即保存。',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _dialogField('项目名称', '例如：我的游戏'),
              const SizedBox(height: 14),
              _dialogField('游戏平台', 'PC / Mobile / Console'),
              const SizedBox(height: 14),
              _dialogField('项目描述', '简要描述项目用途（可选）'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showActionToast('项目创建成功！AppKey 已发送至邮箱');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        '创建项目',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Nav Item Model ─────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
