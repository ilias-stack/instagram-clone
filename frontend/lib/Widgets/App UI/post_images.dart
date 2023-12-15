import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class PostImages extends StatelessWidget {
  final List imagesIds;
  final void Function(int) onScroll;
  PostImages({super.key, required this.imagesIds, required this.onScroll});

  final _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final url = "http://$serverIpAddress:5000";
    return InteractiveViewer(
      maxScale: 4,
      child: CarouselSlider(
          carouselController: _controller,
          items: imagesIds
              .map((item) => Container(
                    color: Colors.black,
                    child: Image.network(
                      '$url/posts/postImage/${item["id"]}',
                      loadingBuilder: (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator()),
                    ),
                  ))
              .toList(),
          options: CarouselOptions(
            scrollPhysics: imagesIds.length <= 1
                ? const NeverScrollableScrollPhysics()
                : null,
            height: double.maxFinite,
            onPageChanged: (index, reason) => onScroll(index),
            viewportFraction: 1.0,
          )),
    );
  }
}
