import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/shared/components/Constants.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppCubit extends Cubit<AppStates> {

  AppCubit() : super(InitialAppState());

  static AppCubit get(context) => BlocProvider.of(context);


  Database? dataBase;
  List<dynamic> notes = [];
  List<dynamic> notesDeleted = [];

  var picker = ImagePicker();

  List<File> imagePaths = [];


  void createDataBase(context) async {

    openDatabase(
      'note.db',
      version: 2,
      onCreate: (dataBase , version) async {
        try {
          await dataBase.execute('PRAGMA foreign_keys = ON');
          await dataBase.execute('CREATE TABLE Notes (id INTEGER PRIMARY KEY, title TEXT, content TEXT, date TEXT, date_time TEXT, status TEXT)');
          await dataBase.execute('CREATE TABLE Images (id INTEGER PRIMARY KEY, image TEXT, id_note INTEGER, FOREIGN KEY(id_note) REFERENCES Notes(id) ON DELETE CASCADE)');
          if (kDebugMode) {
            print('DataBase created');
          }
        } catch(e) {
          if (kDebugMode) {
            print('Error when creating dataBase --> ${e.toString()}');
          }
        }
      },
      onOpen: (dataBase) {
        if (kDebugMode) {
          print('DataBase opened');
        }
        dataBase.execute('PRAGMA foreign_keys = ON');
        getFromDataBase(dataBase, context);
      }

    ).then((value) {
      dataBase = value;
      emit(SuccessCreateDataBaseAppState());

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in create database');
      }

      emit(ErrorCreateDataBaseAppState(error));

    });

  }


  void insertIntoDataBase({
    required String title,
    required String content,
    required dynamic date,
    required dynamic dateTime,
    required BuildContext context,
}) async {

    await dataBase?.transaction((txn) async {

      await txn.rawInsert('INSERT INTO Notes(title, content, date, date_time, status) VALUES(?, ?, ?, ?, ?)',
       [title, content, date, dateTime, 'New'])
          .then((value) {

       if(context.mounted) {
         getFromDataBase(dataBase, context);

         if(imagePaths.isNotEmpty) {
           for(var element in imagePaths) {
             addImageNoteInDataBase(id: value, imagePath: element.path);
           }
         }

       }

      }).catchError((error) {

        if (kDebugMode) {
          print('${error.toString()} --> in insert into database');
        }

        emit(ErrorInsertIntoDataBaseAppState(error));

      });

    });

  }


  Future<void> getImage(ImageSource source) async {

    try {

      final pickedFile = await picker.pickImage(source: source);

      if(pickedFile != null) {

        if(File(pickedFile.path).lengthSync() <= 10485760) {

          final appDir = await getApplicationDocumentsDirectory();
          final newPath = '${appDir.path}/${pickedFile.name}';
          final imageFile = await File(pickedFile.path).copy(newPath);
          imagePaths.add(imageFile);

          emit(SuccessGetImageAppState());

        } else {

          emit(ErrorGetImageAppState('error-size'));

        }

      }

    } catch(e) {

      emit(ErrorGetImageAppState(e.toString()));

    }

  }


  void clearImage(index) {
    imagePaths.removeAt(index);
    emit(SuccessClearAppState());
  }


  void clearAllImages() {
    imagePaths.clear();
    emit(SuccessClearAppState());
  }



  Future<void> addImageNoteInDataBase({
    required int id,
    required String imagePath,
  }) async {

    await dataBase?.transaction((txn) async {

      await txn.rawInsert('INSERT INTO Images(image, id_note) VALUES (?, ?)',
          [imagePath, id]).then((value) {

        emit(SuccessAddImageNoteIntoDataBaseAppState());

      }).catchError((error) {

        if (kDebugMode) {
          print('${error.toString()} --> in add image note into database');
        }

        emit(ErrorGetImageNoteFromDataBaseAppState());
      });
    });

  }



  List<dynamic> dataImg = [];

  void getImageNoteFromDataBase(id, dataBase) async {

    await dataBase?.rawQuery('SELECT * FROM Images WHERE id_note = ?',
        [id]).then((value) {

      dataImg = [];
      dataImg = value;

      emit(SuccessGetImageNoteFromDataBaseAppState());

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in get image note from database');
      }

      emit(ErrorGetImageNoteFromDataBaseAppState());
    });

  }


  void deleteImageNoteFromDataBase({
    required int id
  }) {

    dataBase?.rawDelete('DELETE FROM Images WHERE id = ?',
        [id]).then((value) {

      emit(SuccessDeleteImageNoteFromDataBaseAppState());
    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in remove image note from database');
      }
      emit(ErrorDeleteImageNoteFromDataBaseAppState());
    });
  }




  Map<int , dynamic> selectNotes = {};
  Map<int , dynamic> selectNotesDeleted = {};


  void getFromDataBase(dataBase, context) async {

    await dataBase?.rawQuery('SELECT * FROM Notes ORDER BY date_time DESC').then((value) {

      notes = [];
      notesDeleted = [];

      for (var element in value) {

        if((element['title'] == '' || element['title'].toString().trim().isEmpty)
            && (element['content'] == '' || element['content'].toString().trim().isEmpty)) {
          deleteFromDataBase(id: element['id'], isEmptyNote: true);
        }

        if(element['status'] == 'New') {

          notes.add(element);

          selectNotes.addAll({
            element['id']: false,
          });

        } else if(element['status'] == 'Deleted') {

          notesDeleted.add(element);

          selectNotesDeleted.addAll({
            element['id']: false,
          });

        }
      }

      if(imagePaths.isNotEmpty) clearAllImages();

      emit(SuccessGetFromDataBaseAppState());

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in get from database');
      }

      emit(ErrorGetFromDataBaseAppState(error));

    });


  }


  bool isSelected = false;

  void selectNote({
    required id,
    bool isDeleted = false,
}) {

    isSelected = true;

    if(!isDeleted) {
      selectNotes[id] = true;
    } else {
      selectNotesDeleted[id] = true;
    }

    emit(SuccessSelectNoteAppState());

  }


  void cancelSelectNote({
    required id,
    bool isDeleted = false,
}) {

    if(!isDeleted) {
      selectNotes[id] = false;
    } else {
      selectNotesDeleted[id] = false;
    }

    emit(SuccessCancelSelectNoteAppState());

  }


  void cancelAll({
    bool isDeleted = false,
}) {

    isSelected = false;

    if(!isDeleted) {

      for(var element in selectNotes.keys) {
        selectNotes[element] = false;
      }

    } else {

      for(var element in selectNotesDeleted.keys) {
        selectNotesDeleted[element] = false;
      }

    }


    emit(SuccessClearAppState());

  }



  void updateIntoDataBase({
    required int id,
    required String title,
    required String content,
    required dynamic date,
    required dynamic dateTime,
    required bool isEmptyNote,
}) async {
    
    await dataBase?.rawUpdate('UPDATE Notes SET title = ?, content = ?, date = ?, date_time = ? WHERE id = ?',
        [title, content, date, dateTime, id]).then((value) {

          if(imagePaths.isNotEmpty) {
            for(var element in imagePaths) {
              addImageNoteInDataBase(id: id, imagePath: element.path);
            }
          }

         emit(SuccessUpdateIntoDataBaseAppState(isEmptyNote));

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in update into database');
      }

      emit(ErrorUpdateIntoDataBaseAppState(error));

    });
    
    
  }



  void moveToRecycleBin({
    required int id,
    required BuildContext context,
  }) async {

    await dataBase?.rawUpdate('UPDATE Notes SET status = ? WHERE id = ?',
        ['Deleted', id]).then((value) {

     emit(SuccessMoveToRecycleBinAppState());

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in update into database');
      }

      emit(ErrorMoveToRecycleBinAppState(error));

    });

  }


  void moveAllSelectedNotesToRecycleBin({
    required Map selectNotes,
  }) async {

    for(var element in selectNotes.keys) {

      if(selectNotes[element] == true) {

        await dataBase?.rawUpdate('UPDATE Notes SET status = ? WHERE id = ?',
            ['Deleted', element]).then((value) {

          emit(SuccessMoveSelectedNoteToRecycleBinAppState());

        }).catchError((error) {

          if (kDebugMode) {
            print('${error.toString()} --> in move all selected notes to recycle bin');
          }

          emit(ErrorMoveSelectedNoteToRecycleBinAppState(error));

        });

      }

    }

    cancelAll();
    emit(SuccessMoveAllSelectedNotesToRecycleBinAppState());

  }



  void restoreFromRecycleBin({
    required int id,
    required BuildContext context,
  }) async {

    await dataBase?.rawUpdate('UPDATE Notes SET status = ? WHERE id = ?',
        ['New', id]).then((value) {

      emit(SuccessRestoreFromRecycleBinAppState());

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in restore note from recycle bin');
      }

      emit(ErrorRestoreFromRecycleBinAppState(error));

    });

  }


  void restoreAllNotesFromRecycleBin({
    required Map selectNotesDel,
    required BuildContext context,
  }) async {


    for(var element in selectNotesDel.keys) {

      if(selectNotesDel[element] == true) {

        await dataBase?.rawUpdate('UPDATE Notes SET status = ? WHERE id = ?',
            ['New', element]).then((value) {

          emit(SuccessRestoreNoteFromRecycleBinAppState());

        }).catchError((error) {

          if (kDebugMode) {
            print('${error.toString()} --> in restore all notes from recycle bin');
          }

          emit(ErrorRestoreNoteFromRecycleBinAppState(error));

        });

      }

    }

    cancelAll(isDeleted: true);
    emit(SuccessRestoreAllNotesFromRecycleBinAppState());

  }



  void deleteFromDataBase({
    required int id,
    bool isEmptyNote = false,
}) async {

    await dataBase?.rawDelete('DELETE FROM Notes WHERE id = ?',[id]).then((value) {

      emit(SuccessDeleteFromDataBaseAppState(isEmptyNote));

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in delete from database');
      }

      emit(ErrorDeleteFromDataBaseAppState(error));

    });

  }


  void deleteAllNotesFromDataBase({
    required Map selectNotesDel,
  }) {

    for(var element in selectNotesDel.keys) {

      if(selectNotesDel[element] == true) {

        dataBase?.rawDelete('DELETE FROM Notes WHERE id = ?',[element]).then((value) {

          emit(SuccessDeleteNoteFromDataBaseAppState());

        }).catchError((error) {

          if (kDebugMode) {
            print('${error.toString()} --> in delete note from database');
          }

          emit(ErrorDeleteNoteFromDataBaseAppState(error));

        });
      }
    }

    cancelAll(isDeleted: true);
    emit(SuccessDeleteAllNotesFromDataBaseAppState());

  }


  List<dynamic> searchNotes = [];
  bool isSearch = false;

  void searchNote(String title) {

    searchNotes = notes.where((
        element) => element['title'].toString().toLowerCase().contains(title.toLowerCase())).toList();
    isSearch = true;

    emit(SuccessSearchNoteAppState());

  }


  void clearSearch() {

    searchNotes.clear();
    isSearch = false;
    emit(SuccessClearAppState());

  }


  bool isArabicTitle = false;
  bool isArabicContent = false;

  void detectLangText(bool isTitle, String text) {

    if(isTitle) {
      if(englishRegex.hasMatch(text)) {
        isArabicTitle = false;
      } else if(arabicRegex.hasMatch(text)) {
        isArabicTitle = true;
      }

    } else {

      if(englishRegex.hasMatch(text)) {
        isArabicContent = false;
      } else if(arabicRegex.hasMatch(text)) {
        isArabicContent = true;
      }

    }

    emit(SuccessDetectLangTextAppState());
  }


  void clearDetectLang() {
    isArabicTitle = false;
    isArabicContent = false;

    emit(SuccessClearAppState());
  }

}