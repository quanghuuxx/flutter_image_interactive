// quanghuuxx (quanghuuxx@gmail.com)
// ------
// Copyright 2023 quanghuuxx, Ltd. All rights reserved.

import 'package:flutter/material.dart';

import 'package:crop_image/crop_image.dart';

class Croping extends StatefulWidget {
  const Croping({super.key});

  @override
  State<Croping> createState() => _CropingState();
}

class _CropingState extends State<Croping> {
  final controller = CropController(
    aspectRatio: null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, controller.cropSize);
            },
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: Center(
        child: CropImage(
          controller: controller,
          image: Image.asset('assets/rm_bgr_origin.png'),
          alwaysMove: true,
        ),
      ),
    );
  }
}
