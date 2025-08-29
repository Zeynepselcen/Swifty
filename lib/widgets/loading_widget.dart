import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final bool showMessage;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 60.0,
    this.showMessage = true,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Döndürme animasyonu
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    // Nabız animasyonu
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Animasyonları başlat
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkBackgroundPrimary.withOpacity(0.9)
            : AppColors.backgroundPrimary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ana loading animasyonu
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.size / 2),
                      gradient: isDark
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.darkAccent,
                                AppColors.darkAccentLight,
                              ],
                            )
                          : AppColors.mainGradient,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.darkAccent.withOpacity(0.3)
                              : AppColors.gradientStart.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.photo_library,
                        color: Colors.white,
                        size: widget.size * 0.4,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Mesaj
          if (widget.showMessage && widget.message != null)
            Text(
              widget.message!,
              style: TextStyle(
                color: isDark 
                    ? AppColors.darkTextPrimary 
                    : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 8),
          
          // Nokta animasyonu
          if (widget.showMessage)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final animationValue = (_pulseController.value + delay) % 1.0;
                    final scale = 0.5 + (animationValue * 0.5);
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8 * scale,
                      height: 8 * scale,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppColors.darkAccent 
                            : AppColors.gradientStart,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
        ],
      ),
    );
  }
}

// Tam ekran loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: LoadingWidget(
                message: message ?? 'Yükleniyor...',
                size: 80,
              ),
            ),
          ),
      ],
    );
  }
}

// Küçük loading indicator
class SmallLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const SmallLoadingWidget({
    Key? key,
    this.size = 20.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor = color ?? (isDark 
        ? AppColors.darkAccent 
        : AppColors.gradientStart);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
  }
}
