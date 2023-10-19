import 'dart:io';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes/shared/adaptive/LoadingIndicator.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/components/Constants.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/Colors.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  var titleController = TextEditingController();
  var contentController = TextEditingController();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();


  final ScrollController scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    titleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    scrollController.dispose();
    super.dispose();
  }


  // void scrollToBottom() {
  //   if(scrollController.hasClients) {
  //     scrollController.animateTo(
  //         scrollController.position.maxScrollExtent,
  //         duration: const Duration(milliseconds: 500),
  //         curve: Curves.easeIn);
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);

    final bool isDarkTheme = themeData.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {

        var cubit = AppCubit.get(context);

        // if(state is SuccessGetImageAppState) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     scrollToBottom();
        //   });
        // }

        if(state is SuccessAddImageNoteIntoDataBaseAppState) {
          cubit.clearImage();
        }
      },
      builder: (context, state) {

        var cubit = AppCubit.get(context);

        return WillPopScope(
          onWillPop: () async {
            if((titleController.text.isNotEmpty && titleController.text.trim().isNotEmpty)
                || (contentController.text.isNotEmpty && contentController.text.trim().isNotEmpty)) {
              cubit.insertIntoDataBase(
                  title: titleController.text,
                  content: contentController.text,
                  date: DateFormat('dd MMM yyyy').format(DateTime.timestamp()).toString(),
                  dateTime: DateTime.timestamp().toString(),
                  context: context,
              );
            }
            return true;
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                Navigator.pop(context);
              },
              title: 'Add Note',
              actions: [
                if(cubit.image == null && titleController.text.isNotEmpty)
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
                const SizedBox(
                  width: 8.0,
                ),
              ],
            ),
            body: SingleChildScrollView(
              controller: scrollController,
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
                    if(cubit.image != null)
                    const SizedBox(
                      height: 50.0,
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
