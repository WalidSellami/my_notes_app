import 'package:animate_do/animate_do.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/AppColors.dart';
import 'package:notes/shared/utils/Extensions.dart';

class DeletedNotesScreen extends StatefulWidget {
  const DeletedNotesScreen({super.key});

  @override
  State<DeletedNotesScreen> createState() => _DeletedNotesScreenState();
}

class _DeletedNotesScreenState extends State<DeletedNotesScreen> {

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);

    final bool isDarkTheme = (theme.brightness == Brightness.dark);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context , state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessRestoreFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.deletedNotes.isEmpty) {
              cubit.cancelAll(isDeleted: true);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
                context: context,
                title: 'Note Restored',
                isDarkTheme: isDarkTheme,
            ));
        }

        if(state is SuccessRestoreAllNotesFromRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              context: context,
              title: 'All Notes Restored',
              isDarkTheme: isDarkTheme,
            ));

        }

        if(state is SuccessDeleteFromDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.deletedNotes.isEmpty) {
              cubit.cancelAll(isDeleted: true);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              context: context,
              title: 'Note Deleted',
              isDarkTheme: isDarkTheme,
            ));

        }

        if(state is SuccessDeleteAllNotesFromDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          ScaffoldMessenger.of(context).showSnackBar(
            snackBar(
              context: context,
              title: 'All Selected Notes Deleted',
              isDarkTheme: isDarkTheme,
            ));
        }
      },
      builder: (context , state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          canPop: (cubit.isSelected) ? false : true,
          onPopInvokedWithResult: (v, _) {
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
                if(cubit.isSelected && cubit.selectDeletedNotes.
                values.any((element) => (element == true))) ...[
                  ZoomIn(
                    duration: const Duration(milliseconds: 500),
                    child: IconButton(
                      onPressed: () {
                        AppCubit.get(context).restoreAllNotesFromRecycleBin(
                            selectNotesDel: cubit.selectDeletedNotes, context: context);
                      },
                      icon: Icon(
                        Icons.replay_circle_filled_rounded,
                        color: isDarkTheme ? AppColors.anotherDarkPrimaryColor :
                        AppColors.lightPrimaryColor,
                        size: 30.0,
                      ),
                      tooltip: 'Restore',
                    ),
                  ),
                  ZoomIn(
                    duration: const Duration(milliseconds: 500),
                    child: IconButton(
                      onPressed: () {
                        AppCubit.get(context).deleteAllNotesFromDataBase(selectNotesDel: cubit.selectDeletedNotes);
                      },
                      icon: Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.redColor,
                        size: 30.0,
                      ),
                      tooltip: 'Delete',
                    ),
                  ),
                ],
                8.0.hrSpace,
              ],
            ),
            body: ConditionalBuilder(
              condition: cubit.deletedNotes.isNotEmpty,
              builder: (context) => ImplicitlyAnimatedList<Map<String, dynamic>>(
                items: cubit.deletedNotes,
                areItemsTheSame: (oldItem, newItem) => oldItem['id'] == newItem['id'],
                itemBuilder: (context, animation, noteDeleted, index) {
                  return SizeFadeTransition(
                    sizeFraction: 0.7,
                    curve: Curves.easeInOut,
                    animation: animation,
                    child: buildItemDeletedNote(noteDeleted, cubit.selectDeletedNotes,
                        isDarkTheme, context),
                  );
                },
                separatorBuilder: (context, index) => 0.0.vrSpace,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.antiAlias,
              ),
              fallback: (context) => Center(
                child: FadeInLeft(
                  duration: const Duration(milliseconds: 600),
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
