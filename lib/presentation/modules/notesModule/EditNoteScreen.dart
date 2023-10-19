import 'dart:async';
import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notes/shared/adaptive/LoadingIndicator.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/components/Constants.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/pdf/Pdf.dart';
import 'package:notes/shared/styles/Colors.dart';

class EditNoteScreen extends StatefulWidget {

  final Map note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {

  var titleController = TextEditingController();
  var contentController = TextEditingController();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  GlobalKey globalKey = GlobalKey();


  Future<File> generatePdfInBackground({
    required String title,
    required String content,
    required String imagePath,
  }) async {
    Completer<File> completer = Completer();

    // Start the PDF generation in the background
    Future(() async {
     await Pdf.generate(
          title: title,
          content: content,
          imagePath: imagePath,
        ).then((value) {
       completer.complete(value);
     }).catchError((error) {
       completer.completeError(error);
     });
    });

    return completer.future;
  }


  @override
  void initState() {
    super.initState();
    titleController.addListener(() {
      setState(() {});
    });
    contentController.addListener(() {
      setState(() {});
    });
    titleController.text = widget.note['title'];
    contentController.text = widget.note['content'];
  }

    @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);

    final bool isDarkTheme = themeData.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessDeleteImageNoteFromDataBaseAppState) {

          cubit.getImageNoteFromDataBase(widget.note['id'], cubit.dataBase);

        }

        if(state is SuccessUpdateImageNoteFromDataBaseAppState) {
          cubit.clearImage();
        }

        if(state is SuccessAddImageNoteIntoDataBaseAppState) {
          cubit.clearImage();
        }

      },
      builder: (context, state) {

        var cubit = AppCubit.get(context);

        return WillPopScope(
          onWillPop: () async {
            if((titleController.text != widget.note['title'])
                || (contentController.text != widget.note['content'])
                || cubit.image != null) {
              cubit.updateIntoDataBase(
                  id: widget.note['id'],
                  title: titleController.text,
                  content: contentController.text,
                  date: DateFormat('dd MMM yyyy').format(DateTime.timestamp()).toString(),
                  dateTime: DateTime.timestamp().toString(),
                  isEmptyNote:((titleController.text == '' || titleController.text.trim().isEmpty)
                      && (contentController.text == '' || contentController.text.trim().isEmpty) ) ? true : false,
              );
            }
            return true;
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                Navigator.pop(context);
              },
              title: 'Edit Note',
              actions: [
                if(titleController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                        focusNode1.unfocus();
                        focusNode2.unfocus();
                        showOptions(isDarkTheme, context);
                    },
                    icon: Icon(
                      EvaIcons.imageOutline,
                      color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                      size: 30.0,
                    ),
                    tooltip: 'Add Image',
                  ),
                 IconButton(
                    onPressed: () async {
                      focusNode1.unfocus();
                      focusNode2.unfocus();
                      showLoading(context, isDarkTheme);
                      await generatePdfInBackground(
                          title: titleController.text,
                          content: contentController.text,
                          imagePath: (cubit.dataImg.isNotEmpty) ? cubit.dataImg[0]['image'] : '').then((value) async {
                           await Future.delayed(const Duration(milliseconds: 500)).then((v) async {
                             Navigator.pop(context);
                             await Pdf.openFile(value);
                           });
                      });

                    },
                    icon: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                      size: 30.0,
                    ),
                  tooltip: 'PDF',
                ),
                const SizedBox(
                  width: 8.0,
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    defaultTextFormField(
                        controller: titleController,
                        focusNode: focusNode1,
                        hintText: 'Title',
                        onPress: () {
                          FocusScope.of(context).requestFocus(focusNode2);
                        },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    defaultTextFormField(
                      controller: contentController,
                      focusNode: focusNode2,
                      hintText: 'Content',
                      isTitle: false,
                    ),
                    if(cubit.dataImg.isNotEmpty || cubit.image != null)
                      const SizedBox(
                        height: 50.0,
                      ),
                    if(cubit.dataImg.isNotEmpty && cubit.image == null)
                     GestureDetector(
                            child: Hero(
                              tag: 'image',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    width: 0.0,
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Image.file(File(cubit.dataImg[0]['image']),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.fitWidth,
                                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                    if(frame == null) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.0,
                                            color: isDarkTheme ? Colors.white : Colors.black,
                                          ),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        child: Center(child: LoadingIndicator(os: getOs())),
                                      );
                                    }
                                    return child;
                                  },
                                ),
                              ),
                            ),
                            onTap: () {
                              showFullImageAndSave(widget.note['id'], globalKey, XFile(cubit.dataImg[0]['image']), 'image', isDarkTheme, context, isSaved: true);
                            },
                          ),
                    if(cubit.image != null)
                      SizedBox(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            GestureDetector(
                              child: Hero(
                                tag: 'image',
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      width: 0.0,
                                      color: isDarkTheme ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Image.file(File(cubit.image!.path),
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    fit: BoxFit.cover,
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                      if(frame == null) {
                                        return Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 0.0,
                                              color: isDarkTheme ? Colors.white : Colors.black,
                                            ),
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          child: Center(child: LoadingIndicator(os: getOs())),
                                        );
                                      }
                                      return child;
                                    },
                                  ),
                                ),
                              ),
                              onTap: () {
                                showFullImage(cubit.image, 'image', context);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 22.0,
                                backgroundColor: isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300,
                                child: IconButton(
                                  onPressed: () {
                                    AppCubit.get(context).clearImage();
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.blue.shade500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
