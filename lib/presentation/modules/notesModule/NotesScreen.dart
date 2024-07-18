import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/presentation/modules/notesModule/AddNoteScreen.dart';
import 'package:notes/presentation/modules/notesModule/DeletedNotesScreen.dart';
import 'package:notes/presentation/modules/notesModule/SearchNoteScreen.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/components/Extentions.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/Colors.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {

  bool isVisible = true;

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    final bool isDarkTheme = theme.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context , state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessUpdateIntoDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          if(!state.isEmptyNote) {

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                  content: const Text('Note Edited',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: const Duration(milliseconds: 850),
                ));
          }

        }


        if(state is SuccessMoveToRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.notes.isEmpty) {
              cubit.cancelAll();
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                content: const Text('Note Moved To Recycle Bin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: const Duration(seconds: 1),
              ));

        }


        if(state is SuccessMoveAllSelectedNotesToRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                content: const Text('All Notes Selected Moved To Recycle Bin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: const Duration(seconds: 1),
              ));

        }



        // For Empty Note
        if(state is SuccessDeleteFromDataBaseAppState) {

          if(state.isEmptyNote) {

            cubit.getFromDataBase(cubit.dataBase, context);

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                  content: const Text('Note Empty Discarded',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: const Duration(seconds: 1),
                ));
          }

        }

      },
      builder: (context , state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          canPop: cubit.isSelected ? false : true,
          onPopInvoked: (v) {
            if(cubit.isSelected) {
              cubit.cancelAll();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: FadeIn(
                duration: const Duration(milliseconds: 400),
                child: const Text(
                  'Notes',
                  style: TextStyle(
                    fontFamily: 'Josefin',
                    letterSpacing: 0.6,
                    fontSize: 22.0,
                  ),
                ),
              ),
              actions: [
                if(!cubit.isSelected) ... [
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(createThirdRoute(screen: const DeletedNotesScreen()));
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                      ),
                      tooltip: 'Recycle Bin',
                    ),
                  ),
                ],
                if(!cubit.isSelected && cubit.notes.length > 4) ... [
                  FadeInRight(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(createRoute(screen: const SearchNoteScreen()));
                      },
                      icon: const Icon(
                        EvaIcons.searchOutline,
                      ),
                      tooltip: 'Search',
                    ),
                  ),
                ],
                if(cubit.isSelected &&
                    cubit.selectNotes.values.any((element) => element == true) &&
                    cubit.notes.isNotEmpty) ...[
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        cubit.moveAllSelectedNotesToRecycleBin(selectNotes: cubit.selectNotes);
                      },
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        color: redColor,
                        size: 30.0,
                      ),
                      tooltip: 'Move To Bin',
                    ),
                  ),
                ],
                8.0.hrSpace,
              ],
            ),
            body: ConditionalBuilder(
              condition: cubit.notes.isNotEmpty,
              builder: (context) => NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if(notification.direction == ScrollDirection.forward) {
                    setState(() {isVisible = true;});
                  } else if(notification.direction == ScrollDirection.reverse) {
                    setState(() {isVisible = false;});
                  }
                  return true;
                },
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context , index) => buildItemNote(cubit.notes[index],
                      cubit.selectNotes, isDarkTheme, context),
                  separatorBuilder: (context , index) => 8.0.vrSpace,
                  itemCount: cubit.notes.length,
                ),
              ),
              fallback: (context) => Center(
                child: FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'There is no notes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19.0,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      12.0.vrSpace,
                      const Text(
                        'Press on the button to create one',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.grey,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: (!cubit.isSelected) ? Visibility(
              visible: isVisible,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 60.0,
                  height: 60.0,
                  child: FloatingActionButton(
                    enableFeedback: true,
                    tooltip: 'New Note',
                    elevation: 8.0,
                    onPressed: () {
                      Navigator.of(context).push(createRoute(screen: const AddNoteScreen()));
                    },
                    child: const Icon(
                      EvaIcons.edit2Outline,
                      color: Colors.white,
                      size: 27.0,
                    ),
                  ),
                ),
              ),
            ) : null,
          ),
        );
      },
    );
  }
}
