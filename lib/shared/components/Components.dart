import 'dart:io';
import 'dart:ui' as ui;
import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/presentation/modules/notesModule/EditNoteScreen.dart';
import 'package:notes/shared/adaptive/LoadingIndicator.dart';
import 'package:notes/shared/components/Constants.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/styles/Colors.dart';


navigateTo({required BuildContext context , required Widget screen}) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));



navigateAndNotReturn({required BuildContext context, required Widget screen}) =>
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => screen), (route) => false);



Route createRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}



Route createSecondRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}



Route createThirdRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}



Widget buildItemNote(note, selectNote, isDarkTheme, context) => SlideInRight(
  duration: const Duration(milliseconds: 400),
  child: Dismissible(
    key: UniqueKey(),
    onDismissed: (direction) {
      AppCubit.get(context).moveToRecycleBin(id: note['id'], context: context);
    },
    child: GestureDetector(
      onTap: () {
        if(!AppCubit.get(context).isSelected) {
          AppCubit.get(context).getImageNoteFromDataBase(note['id'], AppCubit.get(context).dataBase);
          Navigator.of(context).push(createSecondRoute(screen: EditNoteScreen(note: note)));
        } else {
          if(selectNote[note['id']]) {
            AppCubit.get(context).cancelSelectNote(id: note['id'], isDeleted: false);
          } else {
            AppCubit.get(context).selectNote(id: note['id'], isDeleted: false);
          }
        }
      },
      onLongPress: () {
        if(!selectNote[note['id']]) {
          HapticFeedback.vibrate();
          AppCubit.get(context).selectNote(id: note['id']);
        }
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: isDarkTheme ? 12.0 : 8.0,
        margin: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 12.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${note['title']}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 40.0,
                  ),
                  if(!AppCubit.get(context).isSelected)
                  FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: Tooltip(
                      message: 'Remove',
                      enableFeedback: true,
                      child: InkWell(
                        onTap: () {
                          AppCubit.get(context).moveToRecycleBin(id: note['id'], context: context);
                        },
                        borderRadius: BorderRadius.circular(14.0,),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 28.0,
                            color: redColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(selectNote[note['id']] && AppCubit.get(context).isSelected)
                    FadeIn(
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          EvaIcons.checkmarkCircle2Outline,
                          size: 28.0,
                          color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                        ),
                      ),
                    ),
                  if(!selectNote[note['id']] && AppCubit.get(context).isSelected)
                    FadeIn(
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          EvaIcons.radioButtonOffOutline,
                          size: 28.0,
                          color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              if(note['title'] != '')
              const SizedBox(
                height: 6.0,
              ),
              Text(
               '${note['date']}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: isDarkTheme ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
              if(note['content'] != '')
              const SizedBox(
                height: 14.0,
              ),
              if(note['content'] != '')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(
                  '${note['content']}',
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 15.0,
                    letterSpacing: 0.6,
                    height: 1.8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

Widget buildItemNoteDeleted(note, selectNoteDeleted, isDarkTheme, context) => SlideInLeft(
  duration: const Duration(milliseconds: 400),
  child: Dismissible(
    key: UniqueKey(),
    onDismissed: (direction) {
      AppCubit.get(context).deleteFromDataBase(id: note['id']);
    },
    child: GestureDetector(
      onTap: () {
        if(AppCubit.get(context).isSelected) {
          if(selectNoteDeleted[note['id']]) {
            AppCubit.get(context).cancelSelectNote(id: note['id'], isDeleted: true);
          } else {
            AppCubit.get(context).selectNote(id: note['id'], isDeleted: true);
          }
        }
      },
      onLongPress: () {
        if(!selectNoteDeleted[note['id']]) {
          HapticFeedback.vibrate();
          AppCubit.get(context).selectNote(id: note['id'], isDeleted: true);
        }
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: isDarkTheme ? 12.0 : 8.0,
        margin: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 12.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${note['title']}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 40.0,
                  ),
                  Row(
                    children: [
                      if(!AppCubit.get(context).isSelected)
                      FadeIn(
                        duration: const Duration(milliseconds: 200),
                        child: Tooltip(
                          message: 'Restore',
                          enableFeedback: true,
                          child: InkWell(
                            onTap: () {
                              AppCubit.get(context).restoreFromRecycleBin(id: note['id'], context: context);
                            },
                            borderRadius: BorderRadius.circular(14.0,),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.replay_sharp,
                                size: 28.0,
                                color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if(!AppCubit.get(context).isSelected)
                      const SizedBox(
                        width: 4.0,
                      ),
                      if(!AppCubit.get(context).isSelected)
                      FadeIn(
                        duration: const Duration(milliseconds: 200),
                        child: Tooltip(
                          message: 'Remove',
                          enableFeedback: true,
                          child: InkWell(
                            onTap: () {
                              AppCubit.get(context).deleteFromDataBase(id: note['id']);
                            },
                            borderRadius: BorderRadius.circular(14.0,),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 28.0,
                                color: redColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if(selectNoteDeleted[note['id']] && AppCubit.get(context).isSelected)
                        FadeIn(
                          duration: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              EvaIcons.checkmarkCircle2Outline,
                              size: 28.0,
                              color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                            ),
                          ),
                        ),
                      if(!selectNoteDeleted[note['id']] && AppCubit.get(context).isSelected)
                        FadeIn(
                          duration: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              EvaIcons.radioButtonOffOutline,
                              size: 28.0,
                              color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if(note['title'] != '')
              const SizedBox(
                height: 6.0,
              ),
              Text(
               '${note['date']}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: isDarkTheme ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
              if(note['content'] != '')
              const SizedBox(
                height: 14.0,
              ),
              if(note['content'] != '')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(
                  '${note['content']}',
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 15.0,
                    letterSpacing: 0.6,
                    height: 1.8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);


defaultAppBar({
  required Function onPress,
  String? title,
  List<Widget>? actions,
}) => AppBar(
  clipBehavior: Clip.antiAlias,
  scrolledUnderElevation: 0.0,
  leading: IconButton(
      onPressed: () {
        onPress();
      },
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
      ),
    tooltip: 'Back',
  ),
  title: Text(
    title ?? '',
    maxLines: 1,
    style: const TextStyle(
      overflow: TextOverflow.ellipsis,
    ),
  ),
  titleSpacing: 0.6,
  actions: actions,
);



Widget defaultTextFormField({
  required TextEditingController controller,
  required FocusNode focusNode,
  required String hintText,
  Function? onPress,
  bool isTitle = true,

}) => TextFormField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      maxLength: (isTitle) ? 40 : null,
      keyboardType: (isTitle) ? TextInputType.text : TextInputType.multiline,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        height: (!isTitle) ? 1.8 : 1.0,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: (isTitle) ? FontWeight.bold : FontWeight.w100,
          letterSpacing: 0.6,
        ),
        border: (isTitle == false) ? InputBorder.none : null,
      ),
      onEditingComplete: () {
        onPress!();
      },
);


dynamic showLoading(context, isDarkTheme) => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
                padding: const EdgeInsets.all(26.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: (isDarkTheme) ? HexColor('202020') : Colors.white,
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: LoadingIndicator(os: getOs())),
          ),
        );
      });


void showOptions(isDarkTheme, context) {
  showModalBottomSheet(
      context: context,
      builder: (context)
      {
        return SafeArea(
          child: Material(
            color: isDarkTheme ?
               darkColor : Colors.white,
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                      Icons.camera_alt_rounded),
                  title: const Text(
                      'Take a new photo'),
                  onTap: () async {
                    AppCubit.get(context).getImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                      Icons.photo_library_rounded),
                  title: const Text(
                      'Choose from gallery'),
                  onTap: () async {
                    AppCubit.get(context).getImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      });

}


Widget buildItemImagePicked(AppCubit cubit, File imagePicked, index, isDarkTheme, context) => GestureDetector(
  onTap: () async {
    showFullImage(imagePicked, isDarkTheme, context);
  },
  child: SizedBox(
    width: MediaQuery.of(context).size.width / 1.2,
    height: 250.0,
    child: Stack(
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              width: 1.0,
              color: isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.file(imagePicked,
              width: MediaQuery.of(context).size.width / 1.2,
              height: 250.0,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if(frame == null) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 1.2,
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
                  width: MediaQuery.of(context).size.width / 1.2,
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
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
          ),
          child: Material(
            elevation: 4.0,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(20.0),
            color: isDarkTheme ? Colors.blueGrey : Colors.blueGrey.shade100,
            child: InkWell(
              onTap: () {
                cubit.clearImage(index);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close_rounded,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);


void scrollToBottom(scrollController) {
  if(scrollController.hasClients) {
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut);
  }
}


int getSizeImage(AppCubit cubit) {
  int sizeImage = File(cubit.imagePaths[cubit.imagePaths.length - 1].path).lengthSync();
  return sizeImage;
}


Future<void> saveImage(GlobalKey globalKey, context) async {

  final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

  await Future.delayed(const Duration(milliseconds: 300)).then((value) async {

    RenderRepaintBoundary boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    ui.Image? image = await boundary.toImage(pixelRatio: devicePixelRatio);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List? imageBytes = byteData?.buffer.asUint8List();

    await ImageGallerySaver.saveImage(imageBytes!);

  });


}


dynamic showFullImage(image, isDarkTheme, context) {

  return Navigator.of(context).push(createSecondRoute(screen: Scaffold(
    body: SafeArea(
      child: SlideInRight(
        duration: const Duration(seconds: 1),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: InteractiveViewer(
            child: Image.file(image,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if(frame == null) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: LoadingIndicator(os: getOs())),
                    );
                  }
                  return child;
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                        child: Icon(
                      Icons.error_outline_rounded,
                      color: isDarkTheme ? Colors.white : Colors.black, size: 30.0,
                    )),
                  );
                },
            ),
          ),
        ),
      ),
    ),
  ),));


}

dynamic showFullImageAndSave(id, GlobalKey globalKey, image, isDarkTheme, context) {

  return Navigator.of(context).push(createSecondRoute(screen: Scaffold(
    appBar: defaultAppBar(
        onPress: () {
          Navigator.pop(context);
        },
      actions: [
        PopupMenuButton(
          clipBehavior: Clip.antiAlias,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'save',
              child: Row(
                children: [
                  Icon(
                    EvaIcons.downloadOutline,
                    color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: redColor,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  const Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),),
          ],
          onSelected: (value) async {
            if(value == 'save') {
              showLoading(context, isDarkTheme);
              await saveImage(globalKey, context).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                      content: const Text('Image has been saved to your gallery',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                    ));
              });
            } else if(value == 'remove') {
              AppCubit.get(context).deleteImageNoteFromDataBase(id: id);
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(
          width: 4.0,
        ),
      ],
    ),
    body: SafeArea(
      child: SlideInRight(
        duration: const Duration(seconds: 1),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: RepaintBoundary(
            key: globalKey,
            child: InteractiveViewer(
              child: Image.file(File(image),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if(frame == null) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(child: LoadingIndicator(os: getOs())),
                    );
                  }
                  return child;
                },
                errorBuilder: (context, error, stackTrace) {
                 return SizedBox(
                   width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height,
                   child: Center(
                       child: Icon(
                         Icons.error_outline_rounded,
                         color: isDarkTheme ? Colors.white : Colors.black,
                         size: 30.0,
                       ),
                   ),
                );},
              ),
            ),
          ),
        ),
      ),
    ),
  ),));
}




