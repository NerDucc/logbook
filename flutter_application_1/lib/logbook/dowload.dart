// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase/image_entity.dart';
import 'package:flutter_application_1/logbook/route_name.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:validators/validators.dart';

class Dowload extends StatefulWidget {
  const Dowload({super.key});

  @override
  State<Dowload> createState() => _DowloadState();
}

class _DowloadState extends State<Dowload> {
  final imageController = CarouselController();
  final txtUrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final urlList = [
    'https://www.wallpapersin4k.org/wp-content/uploads/2017/03/Funny-Fruit-Wallpaper-8.jpg',
    'https://tse4.mm.bing.net/th?id=OIP.xVseLtIUXWZALjuj5Uc_6gHaJ4&pid=Api&P=0',
    'https://external-preview.redd.it/toJKu37BCDe8OtV-Kwb-yLHKx4x_wtyZpbBti3yiAqE.jpg?width=960&crop=smart&auto=webp&s=2eb0f1eff740d1678fcba087dae12c27cec3d49f',
    'http://newsthump.com/wp-content/uploads/2014/11/Kim-jong-un-flying.jpg',
    'https://i.etsystatic.com/11352370/r/il/d0ed35/2797339888/il_11f40xN.2797339888_f307.jpg'
  ];

  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final keyBoard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log-book"),
        centerTitle: true,
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Home"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Camera"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              Navigator.pushNamed(context, RouteNames.Welcome);
            } else if (value == 1) {
              Navigator.pushNamed(context, RouteNames.MyImage);
            }
          })
        ],
      ),
      body: Center(
          child: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildImageSlider(),
              const SizedBox(height: 12),
              buidIndicator(),
              const SizedBox(height: 12),
              if (!keyBoard) buildButton(),
              const SizedBox(height: 12),
              addImage(),
              // const SizedBox(height: 32),
              addButton()
            ],
          ),
        ),
      )),
    );
  }

  Widget buildImageSlider() {
    return StreamBuilder<List<ImageEntity>>(
        stream: readData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong with $snapshot");
          } else if (snapshot.hasData) {
            final image = snapshot.data!;
            return buildSlider(image);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget buildImage(String urlImage, int index, String locationImage) =>
      Column(children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.grey,
          child: Image.network(
            urlImage,
            fit: BoxFit.cover,
          ),
        ),
        Text(
          "Location: $locationImage",         
        )
      ]);

  Widget buidIndicator() {
    return StreamBuilder<List<ImageEntity>>(
        stream: readData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong with $snapshot");
          } else if (snapshot.hasData) {
            final image = snapshot.data!;
            return buildIndicator(image);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  AnimatedSmoothIndicator buildIndicator(List<ImageEntity> image) {
    return AnimatedSmoothIndicator(
      onDotClicked: animatedToSlide,
      activeIndex: activeIndex,
      count: image.length,
      effect: ScrollingDotsEffect(dotWidth: 10, dotHeight: 10),
    );
  }

  Widget addImage({bool stretch = false}) => TextFormField(
        controller: txtUrl,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (!isURL(value)) {
            return 'Please enter a valid URL';
          } else if (value == null || value.isEmpty) {
            return 'This field is not allowed null';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      );

  void add() {
    if (_formKey.currentState!.validate()) {
      var focus = FocusScope.of(context);
      {
        setState(() {
          if (!focus.hasPrimaryFocus) {
            focus.unfocus();
          }
          var anImage =
              ImageEntity.newImage(txtUrl.text, ImageConstants.location);
          var db = FirebaseFirestore.instance;
          db
              .collection('image')
              .add(anImage.getHash())
              .then((docsnap) => {print("Add Data with ID: ${docsnap.id}")});
        });

        txtUrl.clear();
      }
    }
  }

  Widget buildButton({bool stretch = false}) => (Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            onPressed: previous,
            child: Icon(
              Icons.arrow_back,
              size: 22,
            ),
          ),
          stretch ? Spacer() : SizedBox(width: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
            onPressed: next,
            child: Icon(
              Icons.arrow_forward,
              size: 22,
            ),
          ),
        ],
      ));

  Widget addButton() {
    return StreamBuilder(
        stream: readData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong with $snapshot");
          } else if (snapshot.hasData) {
            final image = snapshot.data!;
            return ElevatedButton(
              onPressed: () {
                add();
                imageController.jumpToPage(image.length);
              },
              child: Icon(Icons.upload_file_outlined),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  void next() {
    imageController.nextPage(duration: Duration(milliseconds: 500));
  }

  void previous() =>
      imageController.previousPage(duration: Duration(milliseconds: 500));

  void animatedToSlide(int index) => imageController.animateToPage(index);

  @override
  void dispose() {
    txtUrl.dispose();
    super.dispose();
  }

  Stream<List<ImageEntity>> readData() {
    return FirebaseFirestore.instance.collection('image').snapshots().map(
        (querySnap) => querySnap.docs
            .map((doc) => ImageEntity.fromJson(doc.id, doc.data()))
            .toList());
  }

  Future<int> getList() async {
    return await readData().length;
  }

  CarouselSlider buildSlider(List<ImageEntity> image) {
    return CarouselSlider.builder(
      carouselController: imageController,
      itemCount: image.length,
      itemBuilder: ((context, index, realIndex) {
        final urlImage = image[index].url;
        final locationImage = image[index].location;
        return buildImage(urlImage, index, locationImage);
      }),
      options: CarouselOptions(
          height: 400,
          reverse: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enlargeCenterPage: true,
          onPageChanged: ((index, reason) => setState(
                () => activeIndex = index,
              ))),
    );
  }
}
