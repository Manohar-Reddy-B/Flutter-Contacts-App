import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  ScrollController scrollController = ScrollController();
  final _textRecognizer = TextRecognizer();
  String text = "";
  List<int> phoneNumbers = [];
  late List<bool> checked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    _textRecognizer.close();
  }

//app in foreground
  void didChangerAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelcted(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraConroller(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    //select the first rear camera.
    CameraDescription? camera;

    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    _cameraSelcted(camera!);
  }

  Future<void> _cameraSelcted(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController?.initialize();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _scanImage() async {
    String pattern =
        r'^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$'; //India r'^(?:[+0][1-9])?[0-9]{10,12}$';
    RegExp regExp = RegExp(pattern, multiLine: true);
    if (_cameraController == null) return;

    // final navigtor = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();
      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      setState(() {
        text = regExp
            .allMatches(recognizedText.text)
            .map((m) => m.group(0))
            .join(" ");
      });
      phoneNumbers = text.split(" ").map(int.parse).toList();
      checked = List.filled(phoneNumbers.length, false);
      //print("###################$phoneNumbers########################");
      // text = recognizedText.text;
      // await navigtor.pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => Home(text: recognizedText.text, index: 3),
      //   ),
      // );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("An Error Occurred when Scanning text")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraConroller(
                        snapshot.data!.cast<CameraDescription>());
                    return CameraPreview(_cameraController!);
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Center(
                            child: Ink(
                              decoration: ShapeDecoration(
                                  shape: const CircleBorder(),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5)),
                              child: IconButton(
                                color: Colors.white,
                                icon: const Icon(Icons.camera),
                                iconSize: 50,
                                onPressed: () {
                                  _scanImage().whenComplete(() {
                                    showModalBottomSheet(
                                        enableDrag: false,
                                        isDismissible: false,
                                        backgroundColor:
                                            Theme.of(context).canvasColor,
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30.0),
                                          topRight: Radius.circular(30.0),
                                        )),
                                        constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3),
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                            builder: (BuildContext context,
                                                void Function(void Function())
                                                    setState) {
                                              return ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(20),
                                                        bottom: Radius.zero),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Text(
                                                        "Select Contacts",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    phoneNumbers.isNotEmpty
                                                        ? Expanded(
                                                            child: SingleChildScrollView(
                                                                controller: scrollController,
                                                                physics: const ClampingScrollPhysics(),
                                                                child: ListView.builder(
                                                                    controller: scrollController,
                                                                    shrinkWrap: true,
                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                    scrollDirection: Axis.vertical,
                                                                    itemCount: phoneNumbers.length,
                                                                    itemBuilder: (contxt, index) {
                                                                      return CheckboxListTile(
                                                                        secondary:
                                                                            const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 20),
                                                                          child:
                                                                              Icon(Icons.person),
                                                                        ),
                                                                        title:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            phoneNumbers[index].toString(),
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                          ),
                                                                        ),
                                                                        activeColor: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        checkColor:
                                                                            Colors.white,
                                                                        autofocus:
                                                                            false,
                                                                        value: checked[
                                                                            index],
                                                                        selected:
                                                                            checked[index],
                                                                        onChanged:
                                                                            (bool?
                                                                                value) {
                                                                          setState(
                                                                              () {
                                                                            checked[index] =
                                                                                value!;
                                                                          });
                                                                        },
                                                                      );
                                                                    })),
                                                          )
                                                        : const Column(
                                                            children: [
                                                              Text(
                                                                  "Phone Number Not Found"),
                                                              Text("Scan Again")
                                                            ],
                                                          ),
                                                    Container(
                                                      color: Theme.of(context)
                                                          .canvasColor,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              phoneNumbers = [];
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            icon: const Icon(
                                                                Icons
                                                                    .arrow_back),
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                          IconButton(
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                  Icons
                                                                      .person_add),
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary)
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        });
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: const Text(
                          "Camera Permission denied",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            )
          ],
        );
      },
    );
  }
}
