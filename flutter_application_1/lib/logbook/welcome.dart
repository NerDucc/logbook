// ignore_for_file: prefer_const_constructors

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase/image_entity.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final imageController = CarouselController();
  final txtUrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // final urlList = [
  //   'http://i.dailymail.co.uk/i/pix/2011/10/24/article-0-0E819BFF00000578-626_468x230.jpg',
  //   'http://3.bp.blogspot.com/-jRG-e3ysNp8/UVWUe9HYLOI/AAAAAAAAhFQ/IDzXdEtdbHs/s1600/funny-animal-pictures-of-the-week-049-005.jpg',
  //   'https://allhdwallpapers.com/wp-content/uploads/2015/06/Funny-4.jpg',
  //   'https://i.imgflip.com/59i2l7.jpg',
  //   'https://ahseeit.com/king-include/uploads/2021/05/thumb_evaptkb3j0271-7628013661.jpg'
  // ];
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final keyBoard = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log-book"),
        centerTitle: true,
      ),
      body: Center(
          child: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.all(32),
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
      )),
    );
  }

  Widget buildImageSlider() {
    return StreamBuilder<List<ImageEntity>>(
        stream: readData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong with ${snapshot}");
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

  Widget buildImage(
    String urlImage,
    int index,
  ) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.grey,
        child: Image.network(
          urlImage,
          fit: BoxFit.cover,
        ),
      );

  Widget buidIndicator() {
    return StreamBuilder<List<ImageEntity>>(
        stream: readData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong with ${snapshot}");
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

  Widget addButton() => ElevatedButton(
        onPressed: () {
          add();
        },
        child: Icon(Icons.upload_file_outlined),
      );

  void next() {
    imageController.nextPage(duration: Duration(milliseconds: 500));
  }

  void previous() =>
      imageController.previousPage(duration: Duration(milliseconds: 500));


  void animatedToSlide(int index) => imageController.animateToPage(index);


  Widget addImage({bool stretch = false}) => TextFormField(
        key: _formKey,
        controller: txtUrl,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: requiredFied,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      );

  void add() {
    var focus = FocusScope.of(context);
     {
      setState(() {
        if (!focus.hasPrimaryFocus) {
          focus.unfocus();
        }
        var anImage = ImageEntity.newImage(txtUrl.text);
        var db = FirebaseFirestore.instance;

        db
            .collection('image')
            .add(anImage.getHash())
            .then((docsnap) => {print("Add Data with ID: ${docsnap.id}")});
      });
      txtUrl.clear();
    }
  }
  @override
  void dispose() {
    txtUrl.dispose();
    super.dispose();
  }

  String? requiredFied(String? value) {
    // String pattern =
    //     r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    // RegExp regExp = new RegExp(pattern);
    // final Uri? uri = Uri.tryParse(value!);
    if (value == null || value.isEmpty) {
      return ("This field can not be empty");}


    return null;
  }

  Stream<List<ImageEntity>> readData() {
    return FirebaseFirestore.instance.collection('image').snapshots().map(
        (querySnap) => querySnap.docs
            .map((doc) => ImageEntity.fromJson(doc.id, doc.data()))
            .toList());
  }

  CarouselSlider buildSlider(List<ImageEntity> image) {
    return CarouselSlider.builder(
      carouselController: imageController,
      itemCount: image.length,
      itemBuilder: ((context, index, realIndex) {
        final urlImage = image[index].url;
        return buildImage(urlImage, index);
      }),
      options: CarouselOptions(
          height: 400,
          initialPage: 0,
          reverse: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enlargeCenterPage: true,
          onPageChanged: ((index, reason) => setState(
                () => activeIndex = index,
              ))),
    );
  }

  AnimatedSmoothIndicator buildIndicator(List<ImageEntity> image) {
    return AnimatedSmoothIndicator(
      onDotClicked: animatedToSlide,
      activeIndex: activeIndex,
      count: image.length,
      effect: ScrollingDotsEffect(
        dotWidth: 10,
        dotHeight: 10
      ),
    );
  }
}
