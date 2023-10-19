import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/Colors.dart';

class DeletedNotesScreen extends StatelessWidget {
  const DeletedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    final bool isDarkTheme = theme.brightness == Brightness.dark;

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context , state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessRestoreFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkFloatColor : lightPrimaryColor,
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
                backgroundColor: isDarkTheme ? darkFloatColor : lightPrimaryColor,
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

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: isDarkTheme ? darkFloatColor : lightPrimaryColor,
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
                backgroundColor: isDarkTheme ? darkFloatColor : lightPrimaryColor,
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

        return WillPopScope(
          onWillPop: () async {
            if(cubit.isSelected) {
              cubit.cancelAll(isDeleted: true);
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                Navigator.pop(context);
              },
              title: 'Recycle Bin',
              actions: [
                if(cubit.isSelected && cubit.selectNotesDeleted.values.any((element) => element == true))
                IconButton(
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
                if(cubit.isSelected && cubit.selectNotesDeleted.values.any((element) => element == true))
                IconButton(
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
                const SizedBox(
                  width: 8.0,
                ),
              ],
            ),
            body: ConditionalBuilder(
              condition: cubit.notesDeleted.isNotEmpty,
              builder: (context) => ListView.separated(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context , index) => buildItemNoteDeleted(cubit.notesDeleted[index], cubit.selectNotesDeleted,
                    isDarkTheme, context),
                separatorBuilder: (context , index) => const SizedBox(
                  height: 8.0,
                ),
                itemCount: cubit.notesDeleted.length,
              ),
              fallback: (context) => const Center(
                child: Text(
                  'No notes in recycle bin',
                  style: TextStyle(
                    fontSize: 18.0,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
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
