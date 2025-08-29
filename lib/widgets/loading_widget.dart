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

class _LoadingWidgetState extends State<LoadingWidget> {

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
          // Dönen circle animasyonu
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark 
                    ? AppColors.darkAccent 
                    : AppColors.gradientStart,
              ),
            ),
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
