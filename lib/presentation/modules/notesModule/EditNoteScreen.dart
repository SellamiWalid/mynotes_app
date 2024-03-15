import 'dart:async';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes/shared/components/Components.dart';
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

  final ScrollController scrollController = ScrollController();

  GlobalKey globalKey = GlobalKey();

  Future<File> generatePdfInBackground({
    required String title,
    required String content,
    required List<dynamic> imagePaths,
  }) async {
    Completer<File> completer = Completer();

    // Start the PDF generation in the background
    Future(() async {
     await Pdf().generate(
          title: title,
          content: content,
          imagePaths: imagePaths,
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

        if(state is SuccessGetImageAppState) {

          if(getSizeImage(cubit) > 7340032) {  // 7MB

            cubit.clearAllImages();
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: redColor,
                    content: const Text('Image is bigger than 7MB',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    duration: const Duration(seconds: 1),
                  ));
            });

          } else {

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 300)).then((value) {
                scrollToBottom(scrollController);
              });
            });
          }
        }


        if(state is SuccessDeleteImageNoteFromDataBaseAppState) {
          cubit.getImageNoteFromDataBase(widget.note['id'], cubit.dataBase);
        }


        if(state is SuccessUpdateImageNoteFromDataBaseAppState ||
            state is SuccessAddImageNoteIntoDataBaseAppState) {
          cubit.clearAllImages();
        }

      },
      builder: (context, state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          onPopInvoked: (v) {
            editNote(cubit);
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                editNote(cubit);
                Navigator.pop(context);
              },
              title: 'Edit Note',
              actions: [
                if(titleController.text.isNotEmpty &&
                    titleController.text.trim().isNotEmpty &&
                    (cubit.dataImg.length + cubit.imagePaths.length) < 6)
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
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
                      enableFeedback: true,
                      tooltip: 'Add Image',
                    ),
                  ),
                if(cubit.imagePaths.isEmpty)
                FadeInRight(
                  duration: const Duration(milliseconds: 400),
                  child: IconButton(
                      onPressed: () async {
                        focusNode1.unfocus();
                        focusNode2.unfocus();
                        showLoading(context, isDarkTheme);
                        await generatePdfInBackground(
                            title: titleController.text,
                            content: contentController.text,
                            imagePaths: cubit.dataImg,
                        ).then((value) async {
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
                ),
                const SizedBox(
                  width: 8.0,
                ),
              ],
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              clipBehavior: Clip.antiAlias,
              physics: const BouncingScrollPhysics(),
              child: FadeInRight(
                duration: const Duration(milliseconds: 400),
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
                      const SizedBox(
                        height: 40.0,
                      ),
                      if(cubit.dataImg.isNotEmpty || cubit.imagePaths.isNotEmpty)
                        FadeIn(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            '${cubit.dataImg.length + cubit.imagePaths.length} / 6',
                            style: const TextStyle(
                              fontSize: 16.0,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      if(cubit.dataImg.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          clipBehavior: Clip.antiAlias,
                          padding: const EdgeInsets.all(10.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1 / 0.9,
                            mainAxisSpacing: 30.0,
                          ),
                          itemBuilder: (context, index) => buildItemImage(cubit.dataImg[index]['id'],
                              cubit.dataImg[index]['image'], isDarkTheme),
                          itemCount: cubit.dataImg.length,
                        ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      if(cubit.imagePaths.isNotEmpty) ...[
                        if(cubit.dataImg.isNotEmpty) ...[
                          FadeIn(
                            duration: const Duration(milliseconds: 200),
                            child: const Text(
                              'New images',
                              style: TextStyle(
                                fontSize: 16.0,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                        ],
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          clipBehavior: Clip.antiAlias,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1 / 0.85,
                          ),
                          itemBuilder: (context, index) => buildItemImagePicked(
                              cubit, cubit.imagePaths[index], index, isDarkTheme, context),
                          itemCount: cubit.imagePaths.length,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void editNote(AppCubit cubit) {
      if((titleController.text != widget.note['title'])
          || (contentController.text != widget.note['content'])
          || (cubit.imagePaths.isNotEmpty)) {
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
    }

  Widget buildItemImage(id, String imagePath, isDarkTheme) => GestureDetector(
    onTap: () async {
      showFullImageAndSave(id, globalKey, imagePath, isDarkTheme, context);},
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          width: 1.0,
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.file(File(imagePath),
          height: 250.0,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if(frame == null) {
              return Container(
                height: 250.0,
                decoration: BoxDecoration(
                  color: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    width: 1.0,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              );
            }
            return FadeIn(
                duration: const Duration(milliseconds: 300),
                child: child);
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 250.0,
              decoration: BoxDecoration(
                color: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  width: 1.0,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 30.0,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    ),
  );



}
