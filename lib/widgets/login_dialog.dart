import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class LoginDialog extends StatefulWidget {
  final Function(String username) onLoginSuccess;
  final VoidCallback onClose;

  const LoginDialog({
    super.key,
    required this.onLoginSuccess,
    required this.onClose,
  });

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pwdFormKey = GlobalKey<FormState>();
  final _smsFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123456');
  final _phoneController = TextEditingController(text: '138****8888');
  final _smsCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeTerms = true;
  bool _isLoading = false;
  int _smsCountdown = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  void _startSmsCountdown() {
    setState(() => _smsCountdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _smsCountdown--);
      return _smsCountdown > 0;
    });
  }

  Future<void> _handleLogin({bool isSms = false}) async {
    final formKey = isSms ? _smsFormKey : _pwdFormKey;
    if (!formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Simulate brief loading then callback
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    // Use phone number for SMS login, username for password login
    final username = isSms ? _phoneController.text.trim() : _usernameController.text.trim();
    widget.onLoginSuccess(username);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(),
              _buildSDKBadge(),
              _buildTabBar(),
              _buildTabContent(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NexusAuth SDK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'v2.4.1  ·  Secure Login',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 20),
            onPressed: widget.onClose,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildSDKBadge() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: Color(0xFF06B6D4),
            size: 14,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'SDK已初始化  ·  AppID: APP_20240322_NEXUS  ·  设备已绑定',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.all(3),
        tabs: const [
          Tab(text: '账号密码登录'),
          Tab(text: '验证码登录'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 280,
      child: TabBarView(
        controller: _tabController,
        children: [_buildPasswordTab(), _buildSmsTab()],
      ),
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Form(
        key: _pwdFormKey,
        child: Column(
          children: [
            _buildField(
              controller: _usernameController,
              label: '账号',
              hint: '请输入账号/邮箱/手机号',
              icon: Icons.person_outline,
              enabled: !_isLoading,
              validator: (v) => v == null || v.trim().isEmpty ? '请输入账号' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _passwordController,
              label: '密码',
              hint: '请输入密码',
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              enabled: !_isLoading,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white30,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入密码';
                if (v.length < 6) return '密码至少6位';
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '忘记密码？',
                    style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildLoginButton(onTap: () => _handleLogin(isSms: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Form(
        key: _smsFormKey,
        child: Column(
          children: [
            _buildField(
              controller: _phoneController,
              label: '手机号',
              hint: '请输入手机号',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              enabled: !_isLoading,
              validator: (v) => v == null || v.trim().isEmpty ? '请输入手机号' : null,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(
                    controller: _smsCodeController,
                    label: '验证码',
                    hint: '请输入验证码',
                    icon: Icons.sms_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v == null || v.isEmpty) return '请输入验证码';
                      if (v.length < 4) return '验证码格式错误';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: _smsCountdown > 0 ? null : _startSmsCountdown,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _smsCountdown > 0
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _smsCountdown > 0
                              ? Colors.white12
                              : const Color(0xFF6C63FF).withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _smsCountdown > 0 ? '${_smsCountdown}s' : '获取验证码',
                          style: TextStyle(
                            color: _smsCountdown > 0
                                ? Colors.white30
                                : const Color(0xFF6C63FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLoginButton(onTap: () => _handleLogin(isSms: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool enabled = true,
    Widget? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: Colors.white30, size: 18),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton({required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF3A3760), Color(0xFF3A3760)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _isLoading ? null : onTap,
            child: Center(
              child: _isLoading
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
                        const SizedBox(width: 10),
                        const Text(
                          '登录中...',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '立即登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          // Other login options
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '其他登录方式',
                  style: TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildThirdPartyBtn(
                Icons.g_mobiledata,
                'Google',
                const Color(0xFFEA4335),
              ),
              const SizedBox(width: 16),
              _buildThirdPartyBtn(
                Icons.wechat,
                'WeChat',
                const Color(0xFF07C160),
              ),
              const SizedBox(width: 16),
              _buildThirdPartyBtn(
                Icons.business_center_outlined,
                'SSO',
                const Color(0xFF0078D4),
              ),
              const SizedBox(width: 16),
              _buildThirdPartyBtn(
                Icons.qr_code_scanner,
                '扫码',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Terms
          GestureDetector(
            onTap: () => setState(() => _agreeTerms = !_agreeTerms),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _agreeTerms
                        ? const Color(0xFF6C63FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _agreeTerms
                          ? const Color(0xFF6C63FF)
                          : Colors.white24,
                    ),
                  ),
                  child: _agreeTerms
                      ? const Icon(Icons.check, color: Colors.white, size: 11)
                      : null,
                ),
                const SizedBox(width: 6),
                const Text(
                  '已阅读并同意',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const Text(
                  '《用户协议》',
                  style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11),
                ),
                const Text(
                  '和',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const Text(
                  '《隐私政策》',
                  style: TextStyle(color: Color(0xFF6C63FF), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyBtn(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
