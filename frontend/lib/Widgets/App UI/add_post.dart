import 'dart:io';

import 'package:flutter/material.dart';
import 'package:horizontal_list/horizontal_list.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

class AddPostCollection extends StatefulWidget {
  const AddPostCollection({super.key});

  @override
  State<AddPostCollection> createState() => AddPostCollectionState();
}

class AddPostCollectionState extends State<AddPostCollection> {
  List<XFile>? images;
  int _currentImageIndex = 1;

  Future<void> _selectImages() async {
    try {
      images = await ImagePicker().pickMultiImage();
      images = images!.sublist(0, images!.length > 10 ? 10 : images!.length);
      images!.isEmpty ? images = null : 0;
      setState(() {
        _currentImageIndex = 1;
      });
    } catch (e) {
      CoreMethods.showSnackBar(context, 'Error picking images!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
            onTap: images == null ? _selectImages : null,
            child: Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(108, 80, 80, 80),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: images == null
                  ? const EdgeInsets.symmetric(vertical: 10)
                  : null,
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: images == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width: 80,
                              child: Image(
                                  fit: BoxFit.contain,
                                  image: AssetImage(
                                      'assets/images/PostImages.png'))),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Click to add a single image or a collection of up to 10 photos from your device.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.primaryTextStyle
                                .copyWith(fontSize: 17),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    : Container(
                        color: Colors.black,
                        child: HorizontalListView(
                            onNextPressed: () => setState(() {
                                  _currentImageIndex++;
                                }),
                            onPreviousPressed: () => setState(() {
                                  _currentImageIndex--;
                                }),
                            itemWidth: MediaQuery.of(context).size.width,
                            enableManualScroll: false,
                            height: double.maxFinite,
                            width: double.maxFinite,
                            iconNext: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ), // Icon for button next
                            iconPrevious: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            durationAnimation:
                                const Duration(milliseconds: 300),
                            list: List.generate(
                                images != null ? images!.length : 0,
                                (index) => Container(
                                      color: Colors.black,
                                      child: Image.file(
                                        File(images![index].path),
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ))),
                      ),
              ),
            )),
        images != null
            ? Align(
                alignment: Alignment.topRight,
                child: Text(
                  '$_currentImageIndex/${images!.length}',
                  style: AppTextStyles.primaryTextStyle,
                ))
            : const SizedBox.shrink(),
        images != null
            ? Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        images = null;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color.fromARGB(255, 228, 162, 157),
                    )))
            : const SizedBox.shrink(),
      ],
    );
  }
}
