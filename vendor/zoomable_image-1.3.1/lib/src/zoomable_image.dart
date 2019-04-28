import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

// Given a canvas and an image, determine what size the image should be to be
// contained in but not exceed the canvas while preserving its aspect ratio.
Size _containmentSize(Size canvas, Size image) {}

class ZoomableImage extends StatefulWidget {
  final ImageProvider image;
  final double maxScale;
  final double minScale;
  final GestureTapCallback onTap;
  final Color backgroundColor;
  final Widget placeholder;
  final int isUpdate;
  final Size imageSize;
  final Alignment alignment;
  final int quarterTurns;
  final bool dropFilter;
  final ImageProvider backgroundImage;
  final bool showColor;
  final bool flipHorizontally;
  ZoomableImage(
    this.image, {
    Key key,
    @deprecated double scale,

    /// Maximum ratio to blow up image pixels. A value of 2.0 means that the
    /// a single device pixel will be rendered as up to 4 logical pixels.
    this.maxScale = 2.0,
    this.minScale = 0.0,
        this.isUpdate = 0,
        this.quarterTurns = 0,
        this.dropFilter = false,
        this.showColor = false,
        this.flipHorizontally = false,

        this.imageSize,
        this.alignment = Alignment.center,
        this.backgroundImage,

        this.onTap,
    this.backgroundColor = Colors.black,

    /// Placeholder widget to be used while [image] is being resolved.
    this.placeholder,
  }) : super(key: key);

  @override
  _ZoomableImageState createState() => new _ZoomableImageState();
}

// See /flutter/examples/layers/widgets/gestures.dart
class _ZoomableImageState extends State<ZoomableImage> {
  ImageStream _imageStream;
  ui.Image _image;
  Size _imageSize;

  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset; // where the top left corner of the image is drawn

  double _previousScale;
  double _scale; // multiplier applied to scale the full image
  int _isChange; // multiplier applied to scale the full image

  Orientation _previousOrientation;

  Size _canvasSize;

  Size _contentSize;

  void _centerAndScaleImage() {
    _imageSize = new Size(
      _image.width.toDouble(),
      _image.height.toDouble(),
    );

    _contentSize = _canvasSize;
    _canvasSize =widget.imageSize;

    _scale = math.min(
      _canvasSize.width / _imageSize.width,
      _canvasSize.height / _imageSize.height,
    );
    Size fitted = new Size(
      _imageSize.width * _scale,
      _imageSize.height * _scale,
    );
    if (widget.quarterTurns == 3){
      fitted = new Size(
        _imageSize.height * _scale,
        _imageSize.width * _scale,
      );
      Offset delta = _contentSize - fitted;
      _offset = delta / 2.0;
      _offset = Offset(_offset.dy, _offset.dx);
    }else  if (widget.quarterTurns == 2){
      fitted = new Size(
        _imageSize.width * _scale,
        _imageSize.height * _scale,
      );
      Offset delta = _contentSize - fitted;
      _offset = delta / 2.0;
    }else if (widget.quarterTurns == 1){
      fitted = new Size(
        _imageSize.height * _scale,
        _imageSize.width * _scale,
      );
      Offset delta = _contentSize - fitted;
      _offset = delta / 2.0;
      _offset = Offset(_offset.dy, _offset.dx);
    }else {
      Offset delta = _contentSize - fitted;
      _offset = delta / 2.0;
    }
  }

  Function() _handleDoubleTap(BuildContext ctx) {
    return () {
      double newScale = _scale * 2;
      if (newScale > widget.maxScale) {
        _centerAndScaleImage();
        setState(() {});
        return;
      }

      // We want to zoom in on the center of the screen.
      // Since we're zooming by a factor of 2, we want the new offset to be twice
      // as far from the center in both width and height than it is now.
      Offset center = ctx.size.center(Offset.zero);
      Offset newOffset = _offset - (center - _offset);
      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });
    };
  }

  void _handleScaleStart(ScaleStartDetails d) {
    print("starting scale at ${d.focalPoint} from $_offset $_scale");
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    double newScale = _previousScale * d.scale;
    if (newScale > widget.maxScale || newScale < widget.minScale) {
      return;
    }

    // Ensure that item under the focal point stays in the same place despite zooming
    final Offset normalizedOffset =
        (_startingFocalPoint - _previousOffset) / _previousScale;
    final Offset newOffset = d.focalPoint - normalizedOffset * newScale;
    setState(() {
      _scale = newScale;
      _offset = newOffset;
      if (widget.quarterTurns == 3){
        _offset = Offset(-newOffset.dy, newOffset.dx);

      }else  if (widget.quarterTurns == 2){
        _offset = Offset(-newOffset.dx, -newOffset.dy);

      }else if (widget.quarterTurns == 1){
        _offset = Offset(newOffset.dy, -newOffset.dx);
      }
    });
  }

  @override
  Widget build(BuildContext ctx) {
    Widget paintWidget() {
      return new CustomPaint(
        child: Container(color: Colors.white.withOpacity(0),),
        foregroundPainter: new _ZoomableImagePainter(
          image: _image,
          offset: _offset,
          scale: _scale,
            flipHorizontally: widget.flipHorizontally
        ),

      );
    }

    Widget filterWidget() {
      return new CustomPaint(
        child:
        Container(color: Colors.white.withOpacity(0),),

        foregroundPainter: new _ZoomableImagePainter(
          image: _image,
          offset: _offset,
          scale: _scale,
          flipHorizontally: widget.flipHorizontally
        ),

      );
    }
    if (_image == null) {
      return widget.placeholder ?? Center(child: CircularProgressIndicator());
    }

    return new LayoutBuilder(builder: (ctx, constraints) {
      Orientation orientation = MediaQuery.of(ctx).orientation;
      if (orientation != _previousOrientation || _isChange != widget.isUpdate) {
        _isChange  = widget.isUpdate;
        _previousOrientation = orientation;
        _canvasSize = constraints.biggest;
        _centerAndScaleImage();
      }

      return Stack(children: <Widget>[
        Container(child: widget.showColor ? Container(color: widget.backgroundColor,):Stack(children: <Widget>[
          ConstrainedBox(
            child: new Image(image: widget.backgroundImage!=null ? widget.backgroundImage:widget.image,fit: BoxFit.cover,),
            constraints: new BoxConstraints.expand(),
          ),
          BackdropFilter(
            filter:new ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: new Container(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],),),
        new GestureDetector(
          child:RotatedBox(quarterTurns: widget.quarterTurns,child:paintWidget()),
        ),
        new GestureDetector(
          child:Container(color: Colors.white.withOpacity(0),),
          onTap: widget.onTap,
          onDoubleTap: _handleDoubleTap(ctx),
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
        ),
      ],);
    });
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    _imageStream.addListener(_handleImageLoaded);
  }

  void _handleImageLoaded(ImageInfo info, bool synchronousCall) {
    print("image loaded: $info");
    setState(() {
      _image = info.image;
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(_handleImageLoaded);
    super.dispose();
  }
}

class _ZoomableImagePainter extends CustomPainter {
  const _ZoomableImagePainter({this.image, this.offset, this.scale,this.flipHorizontally});

  final ui.Image image;
  final Offset offset;
  final double scale;
  final bool flipHorizontally;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    Size imageSize = new Size(image.width.toDouble(), image.height.toDouble());
    Size targetSize = imageSize * scale;
    paintImage(
      canvas: canvas,
      rect: offset & targetSize,
      image: image,
      fit: BoxFit.fitHeight,
        flipHorizontally:flipHorizontally,
    );
  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.image != image || old.offset != offset || old.scale != scale;
  }
}
