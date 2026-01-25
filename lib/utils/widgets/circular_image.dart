import 'package:flutter/material.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    required this.image,
    this.isNetworkImage = false,
    this.width = 50,
    this.height = 50,
    this.padding = 0.0
  });

  final String image;
  final bool isNetworkImage;
  final double width;
  final double height;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = image.startsWith('http');

    return Padding(
      padding: EdgeInsets.all(padding),
      child: ClipOval(
        child: isNetwork
            ? Image.network(
          image,
          width: width,
          height: height,
          fit: BoxFit.cover,
          // Show a loading spinner while the image downloads
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(width: width, height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
          },
          // Fallback if the URL fails
          errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/settings/user.png", width: width, height: height, fit: BoxFit.cover),
        )
        : Image.asset(
          image,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
