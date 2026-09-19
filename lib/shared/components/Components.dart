import 'dart:io';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/presentation/modules/notesModule/EditNoteScreen.dart';
import 'package:notes/shared/adaptive/LoadingIndicator.dart';
import 'package:notes/shared/utils/Constants.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/styles/AppColors.dart';
import 'package:notes/shared/utils/Extensions.dart';
import 'package:notes/shared/utils/Helpers.dart';
import 'package:notes/shared/widgets/ShowImageAndSave.dart';

dynamic navigateTo({required BuildContext context, required Widget screen}) =>
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );

dynamic navigateAndNotReturn(
        {required BuildContext context, required Widget screen}) =>
    Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
        (route) => false);

Route createRoute({required dynamic screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}

Route createSecondRoute({required dynamic screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}

Route createThirdRoute({required dynamic screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}

Widget buildItemNote(Map note, Map selectNote, bool isDarkTheme, context) =>
    FadeIn(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: () {
          if (!AppCubit.get(context).isSelected) {
            HapticFeedback.vibrate();
            AppCubit.get(context).getImageNoteFromDataBase(
                note['id'], AppCubit.get(context).dataBase);
            Navigator.of(context).push(createSecondRoute(
                screen: EditNoteScreen(
              note: note,
            )));
          } else {
            if (selectNote[note['id']]) {
              AppCubit.get(context)
                  .cancelSelectNote(id: note['id'], isDeleted: false);
            } else {
              HapticFeedback.vibrate();
              AppCubit.get(context)
                  .selectNote(id: note['id'], isDeleted: false);
            }
          }
        },
        onLongPress: () {
          if (!selectNote[note['id']] && !AppCubit.get(context).isSelected) {
            HapticFeedback.vibrate();
            AppCubit.get(context).selectNote(id: note['id']);
          }
        },
        child: Card(
          key: ValueKey<int>(note['id']),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: (note['status'] == 'Pinned') ?
            BorderSide(
              width: 1.5,
              color: isDarkTheme ? AppColors.anotherDarkPrimaryColor : AppColors.lightPrimaryColor,
            ) : BorderSide.none,
          ),
          elevation: 5.0,
          surfaceTintColor: isDarkTheme
              ? AppColors.lightPrimaryColor
              : Colors.white,
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
                    40.0.hrSpace,
                    if (!AppCubit.get(context).isSelected) ... [
                      if(note['status'] == 'Pinned') ... [
                        Tooltip(
                          message: 'Pin',
                          enableFeedback: true,
                          child: InkWell(
                            onTap: () {
                              AppCubit.get(context).pinNote(
                                  id: note['id'], context: context, pinNote: false);
                            },
                            borderRadius: BorderRadius.circular(
                              50.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.push_pin_rounded,
                                size: 28.0,
                                color: isDarkTheme ? AppColors.anotherDarkPrimaryColor :
                                AppColors.lightPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ] else ... [
                        Tooltip(
                          message: 'Pin',
                          enableFeedback: true,
                          child: InkWell(
                            onTap: () {
                              AppCubit.get(context).pinNote(
                                  id: note['id'], context: context, pinNote: true);
                            },
                            borderRadius: BorderRadius.circular(
                              50.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.push_pin_outlined,
                                size: 28.0,
                                color: isDarkTheme ? AppColors.anotherDarkPrimaryColor :
                                AppColors.lightPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                      12.0.hrSpace,
                      Tooltip(
                          message: 'Remove',
                          enableFeedback: true,
                          child: InkWell(
                            onTap: () {
                              AppCubit.get(context).moveToRecycleBin(
                                  id: note['id'], context: context);
                            },
                            borderRadius: BorderRadius.circular(
                              50.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 28.0,
                                color: AppColors.redColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                    if (selectNote[note['id']] &&
                        AppCubit.get(context).isSelected)
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          EvaIcons.checkmarkCircle2Outline,
                          size: 28.0,
                          color: isDarkTheme
                              ? AppColors.anotherDarkPrimaryColor
                              : AppColors.lightPrimaryColor,
                        ),
                      ),
                    if (!selectNote[note['id']] &&
                        AppCubit.get(context).isSelected)
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          EvaIcons.radioButtonOffOutline,
                          size: 28.0,
                          color: isDarkTheme
                              ? AppColors.anotherDarkPrimaryColor
                              : AppColors.lightPrimaryColor,
                        ),
                      ),
                  ],
                ),
                if (note['title'] != '') 6.0.vrSpace,
                Text(
                  '${note['date']}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),
                if (note['content'] != '') ...[
                  14.0.vrSpace,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      note['content'],
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
              ],
            ),
          ),
        ),
      ),
    );


Widget buildItemDeletedNote(Map note, Map selectDeletedNote, bool isDarkTheme, context) =>
    FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: () {
          if (AppCubit.get(context).isSelected) {
            if (selectDeletedNote[note['id']]) {
              AppCubit.get(context)
                  .cancelSelectNote(id: note['id'], isDeleted: true);
            } else {
              HapticFeedback.vibrate();
              AppCubit.get(context)
                  .selectNote(id: note['id'], isDeleted: true);
            }
          }
        },
        onLongPress: () {
          if (!selectDeletedNote[note['id']] &&
              !AppCubit.get(context).isSelected) {
            HapticFeedback.vibrate();
            AppCubit.get(context).selectNote(id: note['id'], isDeleted: true);
          }
        },
        child: Card(
          key: ValueKey<int>(note['id']),
          clipBehavior: Clip.antiAlias,
          elevation: 5.0,
          surfaceTintColor: isDarkTheme
              ? AppColors.lightPrimaryColor
              : Colors.white,
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
                    40.0.hrSpace,
                    Row(
                      children: [
                        if (!AppCubit.get(context).isSelected)
                          Tooltip(
                            message: 'Restore',
                            enableFeedback: true,
                            child: InkWell(
                              onTap: () {
                                AppCubit.get(context).restoreFromRecycleBin(
                                    id: note['id'], context: context);
                              },
                              borderRadius: BorderRadius.circular(
                                50.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.replay_circle_filled_rounded,
                                  size: 28.0,
                                  color: isDarkTheme
                                      ? AppColors.anotherDarkPrimaryColor
                                      : AppColors.lightPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        if (!AppCubit.get(context).isSelected) ...[
                          4.0.hrSpace,
                          Tooltip(
                              message: 'Delete',
                              enableFeedback: true,
                              child: InkWell(
                                onTap: () {
                                  AppCubit.get(context)
                                      .deleteFromDataBase(id: note['id']);
                                },
                                borderRadius: BorderRadius.circular(
                                  50.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.delete_forever_rounded,
                                    size: 28.0,
                                    color: AppColors.redColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        if (selectDeletedNote[note['id']] &&
                            AppCubit.get(context).isSelected)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              EvaIcons.checkmarkCircle2Outline,
                              size: 28.0,
                              color: isDarkTheme
                                  ? AppColors.anotherDarkPrimaryColor
                                  : AppColors.lightPrimaryColor,
                            ),
                          ),
                        if (!selectDeletedNote[note['id']] &&
                            AppCubit.get(context).isSelected)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              EvaIcons.radioButtonOffOutline,
                              size: 28.0,
                              color: isDarkTheme
                                  ? AppColors.anotherDarkPrimaryColor
                                  : AppColors.lightPrimaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (note['title'] != '') 6.0.vrSpace,
                Text(
                  '${note['date']}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme
                        ? Colors.grey.shade500
                        : Colors.grey.shade600,
                  ),
                ),
                if (note['content'] != '') ...[
                  14.0.vrSpace,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      note['content'],
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
              ],
            ),
          ),
        ),
      ),
    );


Widget buildItemImageNote(dynamic id, GlobalKey globalKey, dynamic image,
    AppCubit appCubit, isDarkTheme, context) =>
    GestureDetector(
      onTap: () async {
        Navigator.of(context).push(createSecondRoute(
          screen: ShowImageAndSave(
              id: id, image: image, appCubit: appCubit),
        ));
      },
      child: Container(
        height: 250.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            width: 1.0,
            strokeAlign: BorderSide.strokeAlignOutside,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Image.file(
            File(image),
            fit: BoxFit.cover,
            cacheHeight: (250 * (MediaQuery.of(context).devicePixelRatio).round()),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                return Center(child: LoadingIndicator(os: getOs()));
              }
              return FadeIn(
                  duration: const Duration(milliseconds: 300), child: child);
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 30.0,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );


SnackBar snackBar({
  required BuildContext context,
  required String title,
  required bool isDarkTheme,
  int duration = 850,
  Color? bgColor,
}) => SnackBar(
      elevation: 4.0,
      behavior: SnackBarBehavior.fixed,
      backgroundColor: (bgColor != null)
          ? bgColor
          : (isDarkTheme ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor),
      content: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: Duration(milliseconds: duration),
    );

dynamic defaultAppBar({
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
  void Function()? onPress,
  void Function(String)? onChanged,
  bool isTitle = true,
}) =>
    TextFormField(
      clipBehavior: Clip.antiAlias,
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      maxLength: isTitle ? 40 : null,
      keyboardType: (isTitle) ? TextInputType.text : TextInputType.multiline,
      textDirection: getTextDirection(controller.text),
      style: TextStyle(
        fontWeight: isTitle ? FontWeight.bold : FontWeight.w100,
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
      onChanged: (v) {
        if (v.isNotEmpty) {
          onChanged!(v);
        }
      },
      onEditingComplete: onPress,
    );


dynamic showLoading(BuildContext context, bool isDarkTheme) => showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
                padding: const EdgeInsets.all(26.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: (isDarkTheme) ? HexColor('1c2833') : Colors.white,
                ),
                clipBehavior: Clip.antiAlias,
                child: LoadingIndicator(os: getOs())),
          ),
        ),
      );
    });


dynamic showOptions(bool isDarkTheme, BuildContext context) {
  showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 12.0),
            child: FadeInUp(
              duration: Duration(milliseconds: 300),
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    leading: const Icon(Icons.camera_alt_rounded),
                    title: const Text(
                      'Open Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      AppCubit.get(context).getImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    leading: const Icon(Icons.photo_library_rounded),
                    title: const Text(
                      'Open Gallery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      AppCubit.get(context).getImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

Widget buildItemImagePicked(AppCubit cubit, File imagePicked, dynamic index,
        bool isDarkTheme, BuildContext context) =>
    GestureDetector(
      onTap: () async {
        showFullImage(imagePicked, isDarkTheme, context);
      },
      child: Stack(
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width / 1.2,
            height: 250.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.file(
                imagePicked,
                fit: BoxFit.cover,
                cacheHeight: 250 * (MediaQuery.of(context).devicePixelRatio).round(),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return Center(child: LoadingIndicator(os: getOs()));
                  }
                  return FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: child);
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 34.0,
                        color: Colors.white,
                      ),
                  );
                },
              ),
            ),
          ),
          ZoomIn(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
              ),
              child: Material(
                elevation: 4.0,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(20.0),
                color:
                    isDarkTheme ? Colors.blueGrey : Colors.blueGrey.shade100,
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
          ),
        ],
      ),
    );


dynamic showFullImage(File image, bool isDarkTheme, BuildContext context) {
  return Navigator.of(context).push(createSecondRoute(
    screen: Scaffold(
      body: SafeArea(
        child: SlideInRight(
          duration: const Duration(seconds: 1),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Image.file(
                image,
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      child: Center(child: LoadingIndicator(os: getOs())),
                    );
                  }
                  return FadeIn(
                      duration: Duration(milliseconds: 300),
                      child: child);
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(child: Icon(
                      Icons.error_outline_rounded,
                      color: isDarkTheme ? Colors.white : Colors.black,
                      size: 30.0,
                    )),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  ));
}
