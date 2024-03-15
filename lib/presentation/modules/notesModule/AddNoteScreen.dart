import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes/shared/components/Components.dart';
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
    contentController.addListener(() {
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
      },
      builder: (context, state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          onPopInvoked: (v) async {
            addNote(cubit, context);
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                addNote(cubit, context);
                Navigator.pop(context);
              },
              title: 'Add Note',
              actions: [
                if(titleController.text.isNotEmpty &&
                    titleController.text.trim().isNotEmpty &&
                    cubit.imagePaths.length < 6)
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
                const SizedBox(
                  width: 8.0,
                ),
              ]
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              clipBehavior: Clip.antiAlias,
              physics: const BouncingScrollPhysics(),
              child: FadeInUp(
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
                      if(cubit.imagePaths.isNotEmpty) ...[
                        FadeIn(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            '${cubit.imagePaths.length} / 6',
                            style: const TextStyle(
                              fontSize: 16.0,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
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

  void addNote(AppCubit cubit, BuildContext context) {
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
  }

}
