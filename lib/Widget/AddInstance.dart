import 'dart:convert';
import 'dart:io';

import 'package:rpmlauncher/Launcher/Fabric/FabricClient.dart';
import 'package:rpmlauncher/Launcher/Forge/ForgeClient.dart';
import 'package:rpmlauncher/Launcher/GameRepository.dart';
import 'package:rpmlauncher/Launcher/MinecraftClient.dart';
import 'package:rpmlauncher/Launcher/VanillaClient.dart';
import 'package:rpmlauncher/Utility/ModLoader.dart';
import 'package:rpmlauncher/Utility/i18n.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';

import '../main.dart';

AddInstanceDialog(Color BorderColour, TextEditingController NameController,
    Map Data, String ModLoaderID, String LoaderVersion) {
  Directory InstanceDir = GameRepository.getInstanceRootDir();
  if (File(
          join(InstanceDir.absolute.path, NameController.text, "instance.json"))
      .existsSync()) {
    BorderColour = Colors.red;
  } else {
    BorderColour = Colors.lightBlue;
  }
  return StatefulBuilder(builder: (context, setState) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(i18n.Format("version.list.instance.add")),
      content: Row(
        children: [
          Text(i18n.Format("edit.instance.homepage.instance.name")),
          Expanded(
              child: TextField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: BorderColour, width: 5.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: BorderColour, width: 3.0),
              ),
            ),
            controller: NameController,
            onChanged: (value) {
              if (value == "" ||
                  File(join(InstanceDir.absolute.path, value, "instance.json"))
                      .existsSync()) {
                BorderColour = Colors.red;
              } else {
                BorderColour = Colors.lightBlue;
              }
              setState(() {});
            },
          )),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(i18n.Format("gui.cancel")),
          onPressed: () {
            BorderColour = Colors.lightBlue;
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(i18n.Format("gui.confirm")),
          onPressed: () async {
            bool new_ = false;
            var setState_;
            Navigator.of(context).pop();
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => LauncherHome()),
            );
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, setState) {
                    setState_ = setState;
                    if (new_ == true) {
                      new_ = false;
                    }
                    if (Progress == 1) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(i18n.Format("gui.download.done")),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(i18n.Format("gui.close")))
                        ],
                      );
                    } else {
                      return WillPopScope(
                        onWillPop: () => Future.value(false),
                        child: AlertDialog(
                          title: Text(i18n.Format("version.list.downloading"),
                              textAlign: TextAlign.center),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LinearProgressIndicator(
                                value: Progress,
                              ),
                              Text("${(Progress * 100).toStringAsFixed(2)}%"),
                              Text("正在執行的任務:", textAlign: TextAlign.center),
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: MediaQuery.of(context).size.height / 6,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: RuningTasks.length,
                                    itemBuilder: (context, int Index) {
                                      return Text(RuningTasks[Index]);
                                    }),
                              ),
                              Text(
                                  "${i18n.Format("version.list.downloading.time")}: ${DateTime.fromMillisecondsSinceEpoch(RemainingTime.toInt()).minute} ${i18n.Format("gui.time.minutes")} ${DateTime.fromMillisecondsSinceEpoch(RemainingTime.toInt()).second} ${i18n.Format("gui.time.seconds")}"),
                            ],
                          ),
                          actions: <Widget>[],
                        ),
                      );
                    }
                  });
                });
            final url = Uri.parse(Data["url"]);
            Response response = await get(url);
            Map<String, dynamic> Meta = jsonDecode(response.body);
            var NewInstanceConfig = {
              "name": NameController.text,
              "version": Data["id"].toString(),
              "loader": ModLoaderID,
              "java_version": Meta["javaVersion"]["majorVersion"],
              "loader_version": LoaderVersion,
              "play_time": 0
            };
            File(join(InstanceDir.absolute.path, NameController.text,
                "instance.json"))
              ..createSync(recursive: true)
              ..writeAsStringSync(json.encode(NewInstanceConfig));
            new_ = true;
            if (ModLoaderID == ModLoader().None) {
              VanillaClient.createClient(
                  setState: setState_,
                  Meta: Meta,
                  VersionID: Data["id"].toString());
            } else if (ModLoaderID == ModLoader().Fabric) {
              FabricClient.createClient(
                  setState: setState_,
                  Meta: Meta,
                  VersionID: Data["id"].toString(),
                  LoaderVersion: LoaderVersion);
            } else if (ModLoaderID == ModLoader().Forge) {
              ForgeClient.createClient(
                  setState: setState_,
                  Meta: Meta,
                  gameVersionID: Data["id"].toString(),
                  forgeVersionID: LoaderVersion,
                  InstanceDirName: NameController.text);
            }
          },
        ),
      ],
    );
  });
}
