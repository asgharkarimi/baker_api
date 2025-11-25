import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    Widget content = Container(
      width: responsive.contentWidth,
      padding: padding ?? responsive.padding(horizontal: 16),
      child: child,
    );
    
    if (centerContent && responsive.isDesktop) {
      content = Center(child: content);
    }
    
    return content;
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.responsive.fontSize(fontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return SizedBox(
      width: width != null ? responsive.spacing(width!) : null,
      height: height != null ? responsive.spacing(height!) : null,
      child: child,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Card(
      margin: margin ?? responsive.padding(all: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius(12)),
      ),
      color: color,
      child: Padding(
        padding: padding ?? responsive.padding(all: 16),
        child: child,
      ),
    );
  }
}
