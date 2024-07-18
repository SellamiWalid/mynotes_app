import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/components/extentions.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/Colors.dart';

class DeletedNotesScreen extends StatefulWidget {
  const DeletedNotesScreen({super.key});

  @override
  State<DeletedNotesScreen> createState() => _DeletedNotesScreenState();
}

class _DeletedNotesScreenState extends State<DeletedNotesScreen> {

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    final bool isDarkTheme = theme.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context , state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessRestoreFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.notesDeleted.isEmpty) {
              cubit.cancelAll(isDeleted: true);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                content: const Text('Note Restored',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: const Duration(milliseconds: 850),
              ));
        }

        if(state is SuccessRestoreAllNotesFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                content: const Text('All Notes Restored',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: const Duration(milliseconds: 850),
              ));

        }

        if(state is SuccessDeleteFromDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.notesDeleted.isEmpty) {
              cubit.cancelAll(isDeleted: true);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                content: const Text('Note Deleted',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: const Duration(milliseconds: 850),
              ));

        }

        if(state is SuccessDeleteAllNotesFromDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkPrimaryColor : lightPrimaryColor,
                content: const Text('All Notes Deleted',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                duration: const Duration(milliseconds: 850),
              ));
        }
      },
      builder: (context , state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          canPop: (cubit.isSelected) ? false : true,
          onPopInvoked: (v) {
            if(cubit.isSelected) {
              cubit.cancelAll(isDeleted: true);
            }
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                Navigator.pop(context);
              },
              title: 'Recycle Bin',
              actions: [
                if(cubit.isSelected && cubit.selectNotesDeleted.values.any((element) => element == true)) ...[
                  FadeInRight(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        AppCubit.get(context).restoreAllNotesFromRecycleBin(
                            selectNotesDel: cubit.selectNotesDeleted, context: context);
                      },
                      icon: Icon(
                        Icons.replay,
                        color: isDarkTheme ? anotherPrimaryColor : lightPrimaryColor,
                        size: 30.0,
                      ),
                      tooltip: 'Restore',
                    ),
                  ),
                  FadeInRight(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        AppCubit.get(context).deleteAllNotesFromDataBase(selectNotesDel: cubit.selectNotesDeleted);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: redColor,
                        size: 30.0,
                      ),
                      tooltip: 'Remove',
                    ),
                  ),
                ],
                8.0.hrSpace,
              ],
            ),
            body: ConditionalBuilder(
              condition: cubit.notesDeleted.isNotEmpty,
              builder: (context) => ListView.separated(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context , index) => buildItemNoteDeleted(cubit.notesDeleted[index], cubit.selectNotesDeleted,
                    isDarkTheme, context),
                separatorBuilder: (context , index) => 8.0.vrSpace,
                itemCount: cubit.notesDeleted.length,
              ),
              fallback: (context) => Center(
                child: FadeInLeft(
                  duration: const Duration(milliseconds: 400),
                  child: const Text(
                    'No notes in recycle bin',
                    style: TextStyle(
                      fontSize: 19.0,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
