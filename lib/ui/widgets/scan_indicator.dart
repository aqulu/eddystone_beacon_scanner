import 'package:eddystone_beacon_scanner/ui/pixel_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_border/pixel_border.dart';

///
/// A visual indicator suggesting beacon scan is currently in progress
///
class ScanIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final double radioWaveMaxSize;

  const ScanIndicator({
    Key key,
    this.size,
    this.color,
  })  : this.radioWaveMaxSize = size / 4,
        super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
        size: Size(size, size),
        child: Stack(
          children: [
            Icon(
              PixelIcons.pixel_person,
              size: size,
              color: color,
            ),
            Positioned(
              top: 0.49 * size - radioWaveMaxSize / 2,
              left: 0.55 * size,
              child: SizedBox.fromSize(
                size: Size(radioWaveMaxSize, radioWaveMaxSize),
                child: Center(
                  child: RadioWave(
                    maxSize: radioWaveMaxSize,
                    color: color,
                    waveWidth: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

///
/// An animated radio wave growing incrementally until it reaches [maxSize]
/// after [animationSteps] steps. After [maxSize] has been reached, the
/// animation will continue from it's initial state.
///
class RadioWave extends StatefulWidget {
  final Color color;
  final double waveWidth;
  final double maxSize;

  final int animationSteps;

  const RadioWave({
    @required this.maxSize,
    @required this.color,
    @required this.waveWidth,
    this.animationSteps = 3,
  })  : assert(animationSteps > 0),
        assert(maxSize > 0),
        assert(waveWidth > 0);

  @override
  _RadioWaveState createState() => _RadioWaveState();
}

class _RadioWaveState extends State<RadioWave>
    with SingleTickerProviderStateMixin {
  Animation<int> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    animation = FullRangeStepTween(
      begin: 1,
      end: widget.animationSteps,
    ).animate(controller)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // restart animation
          controller.forward(from: 0);
        }
      });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          decoration: ShapeDecoration(
            shape: PixelBorder(
              borderRadius: BorderRadius.circular(animation.value * 4.0),
              pixelSize: 2.0,
              style: BorderStyle.solid,
              borderColor: widget.color,
            ),
          ),
          height: widget.maxSize / widget.animationSteps * animation.value,
          width: widget.maxSize / widget.animationSteps * animation.value,
        ),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// An interpolation between two integers that truncates.
///
/// This class specializes the interpolation of [Tween<int>] to be
/// appropriate for integers by interpolating between the given begin
/// and end values by discarding fractional digits using [double.truncate].
///
/// The resulting value includes both [begin] and [end].
class FullRangeStepTween extends Tween<int> {
  FullRangeStepTween({int begin, int end}) : super(begin: begin, end: end);

  @override
  int lerp(double t) => (begin + end * t).truncate();
}
