import 'package:animate_do/animate_do.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/presentation/modules/notesModule/AddNoteScreen.dart';
import 'package:notes/presentation/modules/notesModule/DeletedNotesScreen.dart';
import 'package:notes/presentation/modules/notesModule/SearchNoteScreen.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/utils/Extensions.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/AppColors.dart';
import 'package:notes/shared/utils/Helpers.dart';

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

    final bool isDarkTheme = (theme.brightness == Brightness.dark);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context , state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessUpdateIntoDataBaseAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          if(!state.isEmptyNote) {

            Future.delayed(Duration(milliseconds: 300)).then((value) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    snackBar(
                        context: context,
                        title: 'Note Edited',
                        isDarkTheme: isDarkTheme));
              }
            });
          }

        }


        if(state is SuccessMoveToRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            if(cubit.isSelected && cubit.notes.isEmpty) {
              cubit.cancelAll();
            }
          });

          Future.delayed(Duration(milliseconds: 300)).then((value) {
            if(context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(
                    context: context,
                    title: 'Note Moved To Recycle Bin',
                    isDarkTheme: isDarkTheme,
                    duration: 1000,
                  ));
            }
          });

        }


        if(state is SuccessMoveAllSelectedNotesToRecycleBinAppState) {

          cubit.getFromDataBase(cubit.dataBase, context);

          Future.delayed(Duration(milliseconds: 300)).then((value) {
            if(context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(
                    context: context,
                    title: 'All Selected Notes Moved To Recycle Bin',
                    isDarkTheme: isDarkTheme,
                    duration: 1000,
                  ));
            }
          });
        }



        // For Empty Note
        if(state is SuccessDeleteFromDataBaseAppState) {

          if(state.isEmptyNote) {

            cubit.getFromDataBase(cubit.dataBase, context);

            Future.delayed(Duration(milliseconds: 300)).then((value) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    snackBar(
                      context: context,
                      title: 'Note Empty Discarded',
                      isDarkTheme: isDarkTheme,
                      duration: 1000,
                    ));
              }
            });
          }
        }

      },
      builder: (context , state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          canPop: cubit.isSelected ? false : true,
          onPopInvokedWithResult: (v, _) {
            if(cubit.isSelected) {
              cubit.cancelAll();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: AnimatedTextKit(
                key: ValueKey(isDarkTheme),
                animatedTexts: [
                  ColorizeAnimatedText(
                    getGreeting(context),
                    textStyle: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: [
                      isDarkTheme ? AppColors.anotherDarkPrimaryColor :
                      AppColors.lightPrimaryColor,
                      isDarkTheme ? Colors.white : Colors.black,
                    ],
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              actions: [
                if(!cubit.isSelected) ... [
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(createThirdRoute(screen: const DeletedNotesScreen()));
                      },
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.redColor,
                      ),
                      tooltip: 'Recycle Bin',
                    ),
                  ),
                ],
                if(!cubit.isSelected && cubit.notes.length > 5) ... [
                  FadeIn(
                    duration: const Duration(milliseconds: 500),
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
                  ZoomIn(
                    duration: const Duration(milliseconds: 600),
                    child: IconButton(
                      onPressed: () {
                        cubit.moveAllSelectedNotesToRecycleBin(selectNotes: cubit.selectNotes);
                      },
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        color: AppColors.redColor,
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
                child: ImplicitlyAnimatedList<Map<String, dynamic>>(
                  items: cubit.notes,
                  areItemsTheSame: (oldItem, newItem) => oldItem['id'] == newItem['id'],
                  itemBuilder: (context, animation, note, index) {
                    return SizeFadeTransition(
                      sizeFraction: 0.7,
                      curve: Curves.easeInOut,
                      animation: animation,
                      child: buildItemNote(note, cubit.selectNotes, isDarkTheme, context),
                    );
                  },
                  separatorBuilder: (context, index) => 0.0.vrSpace,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.antiAlias,
                ),
              ),
              fallback: (context) => Center(
                child: FadeIn(
                  duration: const Duration(milliseconds: 600),
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
              child: ZoomIn(
                duration: const Duration(milliseconds: 600),
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
              ),
            ) : null,
          ),
        );
      },
    );
  }
}
