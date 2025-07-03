import 'package:flutter/material.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    required this.image,
    this.width = 50,
    this.height = 50,
    this.padding = 0.0,
    this.isAsset = true, // Assumes asset unless specified
  });

  final String image;
  final double width;
  final double height;
  final double padding;
  final bool isAsset;

  @override
  Widget build(BuildContext context) {
    final imageProvider = isAsset
        ? AssetImage(image)
        : NetworkImage(image) as ImageProvider;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: ClipOval(
        child: Image(
          image: imageProvider,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
