import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

// import 'package:skripsifishh/Camera.dart';

void main() => runApp(MaterialApp(
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late File image;
  List<dynamic>? _output;
  bool isImageloaded = false;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
        isImageloaded = true;
      });
      classifyImage(this.image);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
        isImageloaded = true;
      });
      classifyImage(this.image);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  int _currentIndex = 0;

  classifyImage(File _image) async {
    var output = await Tflite.runModelOnImage(
        path: _image.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    print(output);
    setState(() {
      _output = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/label.txt',
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {});
  }

  @override
  void dispose() {
    Tflite.close();
    setState(() {
      _output = null;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size srz = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00b4d8),
        title: Center(
          child: Text(
            'AHLI DETEKSI IKAN',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 18),
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: Container(
            color: Color(0xffDCF9FF),
            child: Center(
                child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    // SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          isImageloaded
                              ? Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: srz.height * 0.4,
                                        width: srz.width * 0.85,
                                        margin: EdgeInsets.all(25.0),
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image:
                                                    FileImage(File(image.path)),
                                                fit: BoxFit.contain)),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 3,
                                              blurRadius: 10,
                                              offset: Offset(5,
                                                  8), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(top: 5.0),
                                              // color: Colors.white,
                                              height: srz.height * 0.0575,
                                              width: srz.width * 0.85,
                                              child: Center(
                                                child: _output != null
                                                    ? Text(
                                                        getLabel(
                                                            '${_output![0]["label"]}'),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      )
                                                    : CircularProgressIndicator(),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 20.0,
                                                  right: 20.0,
                                                  bottom: 15.0),
                                              height: srz.height * 0.3,
                                              width: srz.width * 0.85,
                                              // color: Colors.yellow,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    _output != null
                                                        ? Text(
                                                            getDeskripsi(
                                                                '${_output![0]["label"]}'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                          )
                                                        : Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    Container(
                                      height: srz.height * 0.1,
                                      // height: 500,
                                      width: srz.width * 0.7,
                                      // color: Colors.yellow,
                                      child: Center(
                                        child: Text(
                                          "Choose kamera or gallery",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF00b4d8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: () {
                  pickImageC();
                },
                icon: Icon(Icons.camera)),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                pickImage();
              },
              icon: Icon(Icons.photo),
            ),
            label: 'Gallery',
          ),
        ],
        // onTap: (index) {
        //   setState(() {
        //     _currentIndex = index;
        //   });
        // },
      ),
    );
  }
}

String getLabel(String nama) {
  switch (nama) {
    case 'kardus':
      return 'Kardus';
      break;
    case 'kaca':
      return 'Kaca';
      break;
    case 'kaleng':
      return 'Kaleng';
      break;
    case 'plastik':
      return 'Plastik';
      break;
    default:
      return "Gagal";
      break;
  }
}

String getDeskripsi(String nama) {
  if (nama == 'kardus') {
    return 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
        'Lorem Ipsum has been the industrys standard dummy text ever since the 1500s,'
        'when an unknown printer took a galley of type and scrambled it to make a type'
        'specimen book. It has survived not only five centuries, but also the leap into ';
  } else if (nama == 'kaca') {
    return 'Deskripsi Kardus';
  } else if (nama == 'kaleng') {
    return 'Deskripsi Kaleng';
  } else if (nama == 'plastik') {
    return 'Deskripsi Platik';
  } else {
    return 'Gagal';
  }
}
