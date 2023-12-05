import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum TrimMode {
  length,
  line,
}

class ReadMoreText extends StatefulWidget {
  final String data;
  final String showLessText;
  final String seeMoreText;
  final int maxCharsLength;
  final int maxLines;
  final TrimMode trimMode;
  final TextStyle textStyle;
  final TextDirection? textDirection;

  const ReadMoreText(
    this.data, {
    Key? key,
    this.showLessText = "... show less",
    this.seeMoreText = "... see more",
    this.maxCharsLength = 240,
    this.maxLines = 2,
    this.trimMode = TrimMode.length,
    required this.textStyle,
    this.textDirection,
  }) : super(key: key);

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

const String _kEllipsis = '\u2026';
const String _kLineSeparator = '\u2028';

class ReadMoreTextState extends State<ReadMoreText> {
  bool _isExpanded = true;
  void _onTapLink() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = widget.textStyle;
    if (widget.textStyle.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.textStyle);
    }
    const textAlign = TextAlign.justify;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final overflow = defaultTextStyle.overflow;
    TextSpan link = TextSpan(
      text: _isExpanded ? widget.seeMoreText : widget.showLessText,
      style: const TextStyle(
        color: Colors.blue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: widget.maxLines,
          ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
        );
        textPainter.layout(
            minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        final linkSize = textPainter.size;
        textPainter.text =
            TextSpan(style: effectiveTextStyle, text: widget.data);
        textPainter.layout(
            minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        final textSize = textPainter.size;
        bool linkLongerThanLine = false;
        int endIndex;
        if (linkSize.width < constraints.maxWidth) {
          final pos = textPainter.getPositionForOffset(Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset)!;
        } else {
          var pos = textPainter
              .getPositionForOffset(textSize.bottomLeft(Offset.zero));
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }
        TextSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.maxCharsLength < widget.data.length) {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: _isExpanded
                    ? widget.data.substring(0, widget.maxCharsLength)
                    : widget.data,
                children: <TextSpan>[link],
              );
            } else {
              textSpan = TextSpan(style: effectiveTextStyle, text: widget.data);
            }
            break;
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: _isExpanded
                    ? widget.data.substring(0, endIndex) +
                        (linkLongerThanLine ? _kLineSeparator : '')
                    : widget.data,
                children: <TextSpan>[link],
              );
            } else {
              textSpan = TextSpan(style: effectiveTextStyle, text: widget.data);
            }
            break;
          default:
            throw Exception(
                'TrimMode type: ${widget.trimMode} is not supported');
        }
        return RichText(
            textAlign: textAlign,
            textDirection: textDirection,
            softWrap: true,
            overflow: TextOverflow.clip,
            text: textSpan);
      },
    );
  }
}
