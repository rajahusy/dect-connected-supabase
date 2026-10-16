import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const section = 24.0;
  static const cardGap = 12.0;
  static const card = 16.0;
  static double page(double width) => width < 360 ? 16 : width < 600 ? 20 : width < 1024 ? 24 : 32;
}

/// A phone-safe page gutter that follows the app's compact spacing scale.
EdgeInsets pageInsets(double width,
        {double top = 20, double bottom = 32}) =>
    EdgeInsets.fromLTRB(AppSpacing.page(width), top, AppSpacing.page(width), bottom);

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 760, this.scrollable = true, this.bottomPadding = 32});
  final Widget child;
  final double maxWidth;
  final bool scrollable;
  final double bottomPadding;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final horizontal = AppSpacing.page(c.maxWidth);
    final content = Center(child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, bottomPadding), child: child),
    ));
    final body = scrollable
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: content)
        : content;
    return SafeArea(top: false, child: body);
  });
}

Color adaptiveTint(BuildContext context, Color light, {double darkAlpha = .14}) {
  final scheme = Theme.of(context).colorScheme;
  return scheme.brightness == Brightness.dark ? scheme.primary.withValues(alpha: darkAlpha) : light;
}
