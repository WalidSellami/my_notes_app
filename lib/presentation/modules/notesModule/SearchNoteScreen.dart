import 'package:animate_do/animate_do.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/AppColors.dart';
import 'package:notes/shared/utils/Extensions.dart';
import 'package:notes/shared/utils/Helpers.dart';

class SearchNoteScreen extends StatefulWidget {
  const SearchNoteScreen({super.key});

  @override
  State<SearchNoteScreen> createState() => _SearchNoteScreenState();
}

class _SearchNoteScreenState extends State<SearchNoteScreen> {

  var searchController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        FocusScope.of(context).requestFocus(focusNode);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    focusNode.dispose();
    searchController.removeListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDarkTheme = (theme.brightness == Brightness.dark);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        var cubit = AppCubit.get(context);

        if (state is SuccessUpdateIntoDataBaseAppState ||
            state is SuccessMoveToRecycleBinAppState ||
            state is SuccessPinNoteAppState ||
            state is SuccessMoveAllSelectedNotesToRecycleBinAppState) {
          Navigator.pop(context);
          cubit.clearSearch();
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);

        return PopScope(
          canPop: (cubit.isSelected) ? false : true,
          onPopInvokedWithResult: (v, _) {
            if (cubit.isSelected) {
              cubit.cancelAll();
            }
          },
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                if (cubit.isSelected) {
                  cubit.cancelAll();
                } else {
                  Navigator.pop(context);
                  cubit.clearSearch();
                }
              }
            },
            child: Scaffold(
              appBar: defaultAppBar(
                onPress: () {
                  Navigator.pop(context);
                  focusNode.unfocus();
                  cubit.clearSearch();
                  if (cubit.isSelected) {
                    cubit.cancelAll();
                  }
                },
                title: 'Search Note',
                actions: [
                  if (cubit.isSelected &&
                      cubit.selectNotes.values
                          .any((element) => element == true))
                    FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        onPressed: () {
                          cubit.moveAllSelectedNotesToRecycleBin(
                              selectNotes: cubit.selectNotes);
                        },
                        icon: Icon(
                          Icons.delete_sweep_outlined,
                          color: AppColors.redColor,
                          size: 30.0,
                        ),
                        tooltip: 'Move To Bin',
                      ),
                    ),
                  8.0.hrSpace,
                ],
              ),
              body: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: searchController,
                        focusNode: focusNode,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: getTextDirection(searchController.text),
                        decoration: InputDecoration(
                          hintText: 'Title note ...',
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w100,
                            letterSpacing: 0.6,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                            borderSide: BorderSide(
                              width: 2.0,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          prefixIcon: const Icon(
                            EvaIcons.searchOutline,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear',
                                  enableFeedback: true,
                                  onPressed: () {
                                    searchController.text = '';
                                    cubit.clearSearch();
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            cubit.searchNote(value);
                          } else {
                            cubit.clearSearch();
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (value.isNotEmpty) {
                            cubit.searchNote(value);
                          } else {
                            cubit.clearSearch();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ConditionalBuilder(
                        condition: cubit.searchNotes.isNotEmpty,
                        builder: (context) => ListView.separated(
                          clipBehavior: Clip.antiAlias,
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, index) => buildItemNote(
                              cubit.searchNotes[index],
                              cubit.selectNotes,
                              isDarkTheme,
                              context),
                          separatorBuilder: (context, index) => 8.0.vrSpace,
                          itemCount: cubit.searchNotes.length,
                        ),
                        fallback: (context) => (!cubit.isSearch)
                            ? Center(
                                child: FadeIn(
                                  duration: const Duration(milliseconds: 300),
                                  child: const Text(
                                    'No notes ...',
                                    style: TextStyle(
                                      fontSize: 19.0,
                                      letterSpacing: 0.6,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: FadeIn(
                                  duration: const Duration(milliseconds: 300),
                                  child: const Text(
                                    'No notes found ...',
                                    style: TextStyle(
                                      fontSize: 19.0,
                                      letterSpacing: 0.6,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
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
