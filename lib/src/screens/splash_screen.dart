import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AssetImage logo;

  @override
  void initState() {
    logo = const AssetImage('assets/images/app_logo.png');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(logo, context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image(image: logo),
                    // SpinKitThreeBounce(
                    //   color: Colors.white,
                    //   size: size.width * 0.5 * 0.3,
                    //   duration: widget._duration,
                    // ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 1),
                child: Text(
                  context.l10n().appTitle,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// const Duration BOUNCE_DURATION = Duration(seconds: 2);

// class SpinKitThreeBounce extends StatefulWidget {
//   const SpinKitThreeBounce({
//     Key key,
//     this.color,
//     this.size = 50.0,
//     this.duration,
//   })  : assert(size != null),
//         super(key: key);

//   final Color color;
//   final double size;
//   final Duration duration;

//   @override
//   _SpinKitThreeBounceState createState() => _SpinKitThreeBounceState();
// }

// class _SpinKitThreeBounceState extends State<SpinKitThreeBounce>
//     with SingleTickerProviderStateMixin {
//   AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: BOUNCE_DURATION)..repeat();
//     Future<void>.delayed(widget.duration, () {
//       final AuthenticationBloc authenticationBloc = context.bloc<AuthenticationBloc>();
//       authenticationBloc.add(SplashScreenCompleted());
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox.fromSize(
//         size: Size(widget.size * 2, widget.size),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: List<Widget>.generate(3, (int i) {
//             return ScaleTransition(
//               scale: DelayTween(
//                 begin: 0.0,
//                 end: 1.0,
//                 delay: i * 0.2,
//               ).animate(_controller),
//               child: SizedBox.fromSize(
//                 size: Size.square(widget.size * 0.5),
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class DelayTween extends Tween<double> {
//   DelayTween({double begin, double end, this.delay}) : super(begin: begin, end: end);

//   final double delay;

//   @override
//   double lerp(double t) => super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

//   @override
//   double evaluate(Animation<double> animation) => lerp(animation.value);
// }
