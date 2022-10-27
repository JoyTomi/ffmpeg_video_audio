import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_selector/file_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> resultStrs = [];
  Future<void> openFileA() async {
    const XTypeGroup mp4TypeGroup = XTypeGroup(
      label: 'MP4s',
      extensions: <String>['MP4'],
    );
    openFiles(acceptedTypeGroups: <XTypeGroup>[
      mp4TypeGroup,
    ]).then((files) {
      resultStrs = [];
      for (var element in files) {
        resultStrs.add(element.name);
      }
      files.asMap().forEach((index, file) {
        save(file, index, files.length);
      });
    });
  }

  void save(XFile file, int index, int total) {
    final path = file.path;
    final name = file.name.replaceAll(RegExp('mp4'), 'm4a');
    resultStrs[index] += ':start.......';
    FFmpegKit.execute(
            '-i $path -vn -acodec copy /Users/joytomi/downloads/$name')
        .then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        final result = '$name:complete';
        resultStrs[index] += result;
        setState(() {});
      } else if (ReturnCode.isCancel(returnCode)) {
        final result = '$name:cancel';
        resultStrs[index] += result;
        setState(() {});
      } else {
        final result = '$name:error';
        resultStrs[index] += result;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              height: 200,
              child: ListView(
                children: resultStrs
                    .map((e) => Text(
                          e,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ))
                    .toList(),
              ),
            ),
            InkWell(
              onTap: openFileA,
              child: Container(
                  color: Colors.blue,
                  width: 100,
                  height: 30,
                  child: const Center(
                    child: Text(
                      '选择文件',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
