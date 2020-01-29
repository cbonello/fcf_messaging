import 'dart:math' as math;

import 'package:flutter/material.dart';

class Tabbar extends StatelessWidget {
  const Tabbar({
    Key key,
    @required PageController pageController,
    @required Color left,
    @required Color right,
    double width = 350.0,
  })  : _pageController = pageController,
        _left = left,
        _right = right,
        _width = width,
        super(key: key);

  final PageController _pageController;
  final Color _left, _right;
  final double _width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: 52.0,
      decoration: const BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: _TabIndicationPainter(
          dxTarget: _width / 2.0 - 25.0,
          pageController: _pageController,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.decelerate,
                  );
                }, //_onSignInButtonPress,
                child: Text(
                  'Existing',
                  style: TextStyle(
                    color: _left,
                    fontSize: 16.0,
                    // fontFamily: "WorkSansSemiBold",
                  ),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.decelerate,
                  );
                }, //_onSignUpButtonPress,
                child: Text(
                  'New',
                  style: TextStyle(
                    color: _right,
                    fontSize: 16.0,
                    // fontFamily: "WorkSansSemiBold",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabIndicationPainter extends CustomPainter {
  _TabIndicationPainter({
    this.dxTarget = 125.0,
    this.dxEntry = 25.0,
    this.radius = 21.0,
    this.dy = 25.0,
    this.pageController,
  }) : super(repaint: pageController) {
    painter = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
  }

  Paint painter;
  final double dxTarget;
  final double dxEntry;
  final double radius;
  final double dy;

  final PageController pageController;

  @override
  void paint(Canvas canvas, Size size) {
    final ScrollPosition pos = pageController.position;
    final double fullExtent =
        pos.maxScrollExtent - pos.minScrollExtent + pos.viewportDimension;
    final double pageOffset = pos.extentBefore / fullExtent;
    final bool left2right = dxEntry < dxTarget;
    final Offset entry = Offset(left2right ? dxEntry : dxTarget, dy);
    final Offset target = Offset(left2right ? dxTarget : dxEntry, dy);

    final Path path = Path();
    path.addArc(
      Rect.fromCircle(center: entry, radius: radius),
      0.5 * math.pi,
      1 * math.pi,
    );
    path.addRect(Rect.fromLTRB(entry.dx, dy - radius, target.dx, dy + radius));
    path.addArc(
      Rect.fromCircle(center: target, radius: radius),
      1.5 * math.pi,
      1 * math.pi,
    );

    canvas.translate(size.width * pageOffset, 0.0);
    // canvas.drawShadow(path, const Color(0xFFfbab66), 3.0, true);
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(_TabIndicationPainter oldDelegate) => true;
}
