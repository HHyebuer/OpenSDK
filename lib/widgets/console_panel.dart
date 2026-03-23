import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ConsolePanel extends StatefulWidget {
  final List<LoginStep> steps;
  final bool isLoading;

  const ConsolePanel({super.key, required this.steps, required this.isLoading});

  @override
  State<ConsolePanel> createState() => _ConsolePanelState();
}

class _ConsolePanelState extends State<ConsolePanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ConsolePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps.length != oldWidget.steps.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStepColor(LoginStepType type) {
    switch (type) {
      case LoginStepType.info:
        return const Color(0xFF64B5F6);
      case LoginStepType.success:
        return const Color(0xFF81C784);
      case LoginStepType.warning:
        return const Color(0xFFFFD54F);
      case LoginStepType.error:
        return const Color(0xFFE57373);
      case LoginStepType.processing:
        return const Color(0xFFCE93D8);
    }
  }

  IconData _getStepIcon(LoginStepType type) {
    switch (type) {
      case LoginStepType.info:
        return Icons.info_outline;
      case LoginStepType.success:
        return Icons.check_circle_outline;
      case LoginStepType.warning:
        return Icons.warning_amber_outlined;
      case LoginStepType.error:
        return Icons.error_outline;
      case LoginStepType.processing:
        return Icons.sync;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${(time.millisecond ~/ 10).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Console header
          _buildHeader(),
          // Console body
          Expanded(
            child: widget.steps.isEmpty ? _buildEmptyState() : _buildLogList(),
          ),
          // Status bar
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF30363D), width: 1)),
      ),
      child: Row(
        children: [
          // Traffic light buttons
          Row(
            children: [
              _buildDot(const Color(0xFFFF5F57)),
              const SizedBox(width: 6),
              _buildDot(const Color(0xFFFFBD2E)),
              const SizedBox(width: 6),
              _buildDot(const Color(0xFF28C840)),
            ],
          ),
          const SizedBox(width: 16),
          const Icon(Icons.terminal, color: Color(0xFF8B949E), size: 16),
          const SizedBox(width: 8),
          const Text(
            'Auth Console — bash',
            style: TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          if (widget.isLoading)
            Row(
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF58A6FF),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'running',
                  style: TextStyle(
                    color: Color(0xFF58A6FF),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.terminal, color: const Color(0xFF30363D), size: 48),
          const SizedBox(height: 12),
          const Text(
            'Waiting for login...',
            style: TextStyle(
              color: Color(0xFF484F58),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Console output will appear here',
            style: TextStyle(
              color: Color(0xFF30363D),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: widget.steps.length,
      itemBuilder: (context, index) {
        final step = widget.steps[index];
        final isLast = index == widget.steps.length - 1;
        return _buildLogItem(step, isLast && widget.isLoading);
      },
    );
  }

  Widget _buildLogItem(LoginStep step, bool isAnimating) {
    final color = _getStepColor(step.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            _formatTime(step.timestamp),
            style: const TextStyle(
              color: Color(0xFF484F58),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          // Icon
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: isAnimating
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(_getStepIcon(step.type), color: color, size: 12),
          ),
          const SizedBox(width: 8),
          // Message
          Expanded(
            child: Text(
              step.message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final successCount = widget.steps
        .where((s) => s.type == LoginStepType.success)
        .length;
    final errorCount = widget.steps
        .where((s) => s.type == LoginStepType.error)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: widget.isLoading
                ? const Color(0xFFFFBD2E)
                : widget.steps.isEmpty
                ? const Color(0xFF484F58)
                : errorCount > 0
                ? const Color(0xFFFF5F57)
                : const Color(0xFF28C840),
          ),
          const SizedBox(width: 6),
          Text(
            widget.isLoading
                ? 'Processing...'
                : widget.steps.isEmpty
                ? 'Idle'
                : errorCount > 0
                ? 'Failed'
                : 'Completed',
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          if (widget.steps.isNotEmpty) ...[
            Text(
              '✓ $successCount',
              style: const TextStyle(
                color: Color(0xFF81C784),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.steps.length} lines',
              style: const TextStyle(
                color: Color(0xFF484F58),
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
