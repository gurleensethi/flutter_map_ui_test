import 'package:flutter/material.dart';

// Callback fired when the bottom layout has been completely expanded.
typedef OnCompleteExpanded();

typedef OnBottomSheetClosed();

typedef _OnBottomSheetExpandRequest();

typedef _OnBottomSheetCollapseRequest();

typedef _OnBottomSheetCloseRequest();

class BottomExpandableController {
  _OnBottomSheetExpandRequest _onBottomSheetExpandRequest;
  OnCompleteExpanded _onCompleteExpanded;
  OnBottomSheetClosed _onBottomSheetClosed;
  _OnBottomSheetCollapseRequest _onBottomSheetCollapseRequest;
  _OnBottomSheetCloseRequest _onBottomSheetCloseRequest;

  void expandBottomSheet() {
    if (_onBottomSheetExpandRequest != null) {
      _onBottomSheetExpandRequest();
    }
  }

  void collapseBottomSheet() {
    if (_onBottomSheetCollapseRequest != null) {
      _onBottomSheetCollapseRequest();
    }
  }

  void closeBottomSheet() {
    if (_onBottomSheetCloseRequest != null) {
      _onBottomSheetCloseRequest();
    }
  }

  void addOnCompleteExpandedListener(OnCompleteExpanded expanded) {
    _onCompleteExpanded = expanded;
  }

  void addOnBottomSheetClosedListener(OnBottomSheetClosed onBottomSheetClosed) {
    _onBottomSheetClosed = onBottomSheetClosed;
  }
}

class BottomExpandablePage extends StatefulWidget {
  /// Layout that appears from the bottom.
  final Widget bottomLayout;

  /// Layout over which [bottomLayout] should be shown.
  final Widget child;

  /// Height of the bottom content.
  final double contentHeight;

  /// Controller provided by user Widget.
  final BottomExpandableController controller;

  const BottomExpandablePage({
    Key key,
    this.bottomLayout,
    this.child,
    this.contentHeight,
    this.controller,
  })  : assert(contentHeight != null),
        assert(controller != null),
        super(key: key);

  @override
  BottomExpandablePageState createState() {
    return new BottomExpandablePageState();
  }
}

class BottomExpandablePageState extends State<BottomExpandablePage>
    with TickerProviderStateMixin {
  double _topMargin = 0.0;

  /// Is the list being scrolled automatically
  bool _isAutoScrolling = false;

  AnimationController _openAnimationController;

  Animation<double> _openAnimation;

  ScrollController _scrollController;

  /// Minimum displacement required to expand the bottom widget to top
  final double _MIN_SLIDE_UP_DISPLACEMENT = 150.0;

  /// Minimum displacement required to close the bottom widget when
  /// slided down.
  final double _MIN_SLIDE_DOWN_DISPLACEMENT = 100.0;

  double get _emptySpace =>
      MediaQuery.of(context).size.height - widget.contentHeight;

  bool get _isBottomPageClosed =>
      _scrollController.position.pixels == 0.0 &&
      !_openAnimationController.isCompleted;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // MediaQueries only work after build has been done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final height = MediaQuery.of(context).size.height;

      _openAnimationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 300,
        ),
      )..addListener(() {
          setState(() {
            _topMargin = _openAnimation.value;
          });
        });

      _openAnimation =
          Tween(begin: height, end: 0.0).animate(_openAnimationController);

      setState(() {
        _topMargin = height;
      });
    });

    _initBottomExpandableController();
    _initScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: widget.child,
        ),
        Positioned(
          top: _topMargin,
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: NotificationListener(
            onNotification: _onScrollNotification,
            child: ScrollConfiguration(
              behavior: RemoveScrollEffectsBehaviour(),
              child: ListView(
                shrinkWrap: true,
                controller: _scrollController,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _closeBottomPage();
                    },
                    child: Container(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Text(''),
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      widget.bottomLayout,
                      Container(
                        height: MediaQuery.of(context).size.height -
                            widget.contentHeight,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _initScrollController() {
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_isBottomPageClosed) {
      return false;
    }

    final scrollPosition = _scrollController.position.pixels;

    print(notification);
    if (notification is ScrollEndNotification) {
      // If user has scrolled the panel up a certain value
      // Then expand the panel
      if (scrollPosition >
              (widget.contentHeight + _MIN_SLIDE_UP_DISPLACEMENT) &&
          !_isAutoScrolling) {
        _isAutoScrolling = true;
        _scrollController.jumpTo(MediaQuery.of(context).size.height);
        return false;
      }

      // If user has scrolled the panel down a certain value
      // Then close the bottom page
      if (scrollPosition <
              (widget.contentHeight - _MIN_SLIDE_DOWN_DISPLACEMENT) &&
          !_isAutoScrolling) {
        _isAutoScrolling = true;
        _closeBottomPage();
      }

      if (scrollPosition == 0.0) {
        _isAutoScrolling = false;
        _closeBottomPage();
        return false;
      }

      // Reset [_isAutoScrolling] when list reaches a destination
      if (scrollPosition == widget.contentHeight ||
          scrollPosition == MediaQuery.of(context).size.height) {
        _isAutoScrolling = false;

        if (scrollPosition == MediaQuery.of(context).size.height) {
          if (widget.controller._onCompleteExpanded != null) {
            widget.controller._onCompleteExpanded();
          }
        }

        return false;
      }

      if (!_isAutoScrolling) {
        _isAutoScrolling = true;
        _initScrollToTop();
      }
    }

    return true;
  }

  void _initBottomExpandableController() {
    widget.controller._onBottomSheetExpandRequest = () {
      _scrollController.jumpTo(widget.contentHeight);
      _openAnimationController.forward();
    };

    widget.controller._onBottomSheetCollapseRequest = () {
      _scrollController.jumpTo(widget.contentHeight);
    };

    widget.controller._onBottomSheetCloseRequest = () {
      _openAnimationController.reverse();
    };
  }

  _initScrollToTop() {
    _scrollController.jumpTo(widget.contentHeight);
  }

  void _closeBottomPage() {
    print('Closing Bottom Page');

    _openAnimationController.reverse(from: _topMargin);
    _scrollController.jumpTo(0.0); // Bring list to bottom

    if (widget.controller._onBottomSheetClosed != null) {
      widget.controller._onBottomSheetClosed();
    }
  }
}

class RemoveScrollEffectsBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
