import 'package:flutter/material.dart';

import 'curved_edges_widget.dart';

class TBackgroundImageHeaderContainer extends StatelessWidget {
  const TBackgroundImageHeaderContainer({
    super.key,
    required this.image,
    required this.child,
  });

  final String image;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgesWidget(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken, // or BlendMode.srcATop
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
