import "package:flutter/material.dart";

class AvertDynamicAppbar extends StatefulWidget {
  const AvertDynamicAppbar({super.key,
    required this.backgroundColor,
    required this.background,
    required this.leading,
    required this.shrinkedTitle,
    required this.expandedTitle,
    required this.body,
    required this.actions,
  });

  final Color? backgroundColor;
  final Widget? background;
  final Widget? leading;
  final Widget body, shrinkedTitle, expandedTitle;
  final List<Widget>? actions;

  @override
  State<AvertDynamicAppbar> createState() => _DynamicAppbarState();
}

class _DynamicAppbarState extends State<AvertDynamicAppbar> {
  late ScrollController _scrollController;

  bool lastStatus = true;
  double height = 390;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (height - kToolbarHeight);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              actions: widget.actions,
              leading: widget.leading,
              // leading: _isShrink ? const BackButton() : null,
              pinned: true,
              backgroundColor: widget.backgroundColor,
              expandedHeight: height,
              flexibleSpace: FlexibleSpaceBar(
                title: _isShrink ? widget.shrinkedTitle : widget.expandedTitle,
                background: widget.background,
              ),
            )
          ],
          body: widget.body,
        ),
      ),
    );
  }
}
//const Text('pmatatias Statistic', style: TextStyle(fontSize: 16))
//const SizedBox(),
