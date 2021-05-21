
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_compresser1/progress_dialog.dart';
import 'package:video_compresser1/video_compress_api.dart';

import 'button_widget.dart';
//import 'file:///C:/Users/uakan/AndroidStudioProjects/video_compresser1/lib/progress_dialog.dart';
//import 'file:///C:/Users/uakan/AndroidStudioProjects/video_compresser1/lib/video_compress_api.dart';
//import '../../video_compresser1/lib/button_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? fileVideo;
  Uint8List? thumbnailBytes;
  int? videoSize;
  MediaInfo? compressedVideoInfo;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Video Compressor",textScaleFactor: 1.3,),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: clearSelection,
            child: Text('Clear',textScaleFactor: 1.3,),
            style: TextButton.styleFrom(primary: Colors.white),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(40),
        child: buildContent(),
      ),
    );
  }
  buildContent() {
    if(fileVideo==null){
      return ButtonWidget(
        text :'Pick Video',
        onClicked: pickVideo,
      );
    }else{
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildThumbnail(),
          SizedBox(height: 24,),
          buildVideoinfo(),
          SizedBox(height: 24,),
          buildVideoCompressedInfo(),
          ButtonWidget(text: 'compressVideo',
            onClicked: compressVideo,
          ),
        ],
      );
    }
  }

  Widget buildThumbnail()=>thumbnailBytes==null?CircularProgressIndicator()
      :Image.memory(thumbnailBytes!,height: 150,);

  Future pickVideo() async {
    final picker =ImagePicker();
    final pickedFile= await picker.getVideo(source: ImageSource.gallery);
    if(pickedFile==null)return;
    final file=File(pickedFile.path);
    setState(() {
      fileVideo=file;
    });
    generateThumbnail(fileVideo!);
    getVideoSize(fileVideo!);

  }

  Future generateThumbnail(File file) async{
    final thumbnailBytes = await VideoCompress.getByteThumbnail(file.path);
    setState(() {
      this.thumbnailBytes= thumbnailBytes;
    });
  }

  Future getVideoSize(File file) async {
    final size=await file.length();
    setState(() {
      videoSize=size;
    });

  }

  Widget buildVideoinfo() {
    if(videoSize==null)return Container();
    final size=videoSize!/1000;
    return Column(
      children: [
        Text('Original Video Info',
          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8,),
        Text(
          'Size: $size KB',
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }

  Future compressVideo() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>Dialog(child: ProgressDialogWidget()));
    final info=await VideoCompressApi.compressVideo(fileVideo!);
    setState(() {
      compressedVideoInfo=info;
    });
    Navigator.of(context).pop();
  }

  Widget buildVideoCompressedInfo() {
    if(compressedVideoInfo==null)return Container();
    final size= compressedVideoInfo!.filesize!/ 1000;
    return Column(
      children: [
        Text('Compressed Video Info',
          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
        const SizedBox(height: 8,),
        Text(
          'Size: $size KB',
          style: TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 8,),
        Text(
          '${compressedVideoInfo!.path}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8,),
      ],
    );
  }

  void clearSelection() {
    setState(() {
      compressedVideoInfo=null;
      fileVideo=null;
    });
  }
}
