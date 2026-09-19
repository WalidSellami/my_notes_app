import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/cubit/AppStates.dart';
import 'package:notes/shared/styles/AppColors.dart';
import 'package:notes/shared/utils/Extensions.dart';
import 'package:notes/shared/utils/Helpers.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

  final ScrollController scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    titleController.addListener(() {setState(() {});});
    contentController.addListener(() {setState(() {});});

    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(!mounted) return;
        FocusScope.of(context).requestFocus(focusNode1);
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    titleController.removeListener(() {setState(() {});});
    contentController.dispose();
    contentController.removeListener(() {setState(() {});});
    scrollController.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);

    final bool isDarkTheme = (themeData.brightness == Brightness.dark);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {

        var cubit = AppCubit.get(context);

        if(state is SuccessGetImageAppState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 700)).then((value) {
                scrollToBottom(scrollController);
              });
            });
          }

        if(state is ErrorGetImageAppState) {

          if(state.error == 'error-size') {

            cubit.clearAllImages();
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBar(
                      context: context,
                      title: 'Image is bigger than 10MB',
                      isDarkTheme: isDarkTheme,
                      duration: 1000,
                      bgColor: AppColors.redColor
                  ));
              }
            });

          } else {

            cubit.clearAllImages();
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    snackBar(
                      context: context,
                      title: 'Error, please try again!',
                      isDarkTheme: isDarkTheme,
                      duration: 1000,
                      bgColor: AppColors.redColor,
                    ));
              }
            });
          }

        }

      },
      builder: (context, state) {

        var cubit = AppCubit.get(context);

        return PopScope(
          onPopInvokedWithResult: (v, _) async {
            addNote(cubit, context);
          },
          child: Scaffold(
            appBar: defaultAppBar(
              onPress: () {
                focusNode1.unfocus();
                focusNode2.unfocus();
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
                        EvaIcons.image,
                        color: isDarkTheme ? AppColors.anotherDarkPrimaryColor :
                        AppColors.lightPrimaryColor,
                        size: 30.0,
                      ),
                    enableFeedback: true,
                    tooltip: 'Add Image',
                  ),
                ),
                8.0.hrSpace,
              ]
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              clipBehavior: Clip.antiAlias,
              physics: const BouncingScrollPhysics(),
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      defaultTextFormField(
                          controller: titleController,
                          focusNode: focusNode1,
                          hintText: 'Title',
                          onPress: () {FocusScope.of(context).requestFocus(focusNode2);},
                      ),
                      20.0.vrSpace,
                      defaultTextFormField(
                        controller: contentController,
                        focusNode: focusNode2,
                        hintText: 'Content',
                        isTitle: false,
                      ),
                     40.0.vrSpace,
                     Column(
                       children: [
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
                           12.0.vrSpace,
                           AnimatedSwitcher(
                             duration: const Duration(milliseconds: 500),
                             switchInCurve: Curves.easeInOut,
                             switchOutCurve: Curves.easeInOut,
                             transitionBuilder: (Widget child, Animation<double> animation) {
                               return FadeTransition(
                                 opacity: animation,
                                 child: SlideTransition(
                                   position: Tween<Offset>(
                                     begin: const Offset(0.0, 0.1), // from bottom slightly
                                     end: Offset.zero,
                                   ).animate(CurvedAnimation(
                                     parent: animation,
                                     curve: Curves.easeOutCubic,
                                   )),
                                   child: ScaleTransition(
                                     scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                         CurvedAnimation(
                                       parent: animation,
                                       curve: Curves.easeOut,
                                     )),
                                     child: child,
                                   ),
                                 ),
                               );
                             },
                             child: GridView.builder(
                               key: ValueKey<int>(cubit.imagePaths.length),
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
                           ),
                         ],
                       ],
                     ),
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
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          date: DateFormat('dd MMM yyyy • HH:mm').format(DateTime.timestamp()).toString(),
          dateTime: DateTime.timestamp().toString(),
          context: context,
      );
    }
  }

}
