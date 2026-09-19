import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/shared/adaptive/LoadingIndicator.dart';
import 'package:notes/shared/components/Components.dart';
import 'package:notes/shared/cubit/AppCubit.dart';
import 'package:notes/shared/utils/Constants.dart';
import 'package:notes/shared/utils/Extensions.dart';
import 'package:notes/shared/utils/Helpers.dart';
import '../styles/AppColors.dart';

class ShowImageAndSave extends StatefulWidget {

  final dynamic id;
  final String image;
  final AppCubit appCubit;

  const ShowImageAndSave({super.key, required this.id,
    required this.image, required this.appCubit});

  @override
  State<ShowImageAndSave> createState() => _ShowImageAndSaveState();
}

class _ShowImageAndSaveState extends State<ShowImageAndSave> {

  final GlobalKey _globalKey = GlobalKey();
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {

    final themeData = Theme.of(context);
    final bool isDarkTheme = (themeData.brightness == Brightness.dark);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if(didPop) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SlideInRight(
          duration: const Duration(seconds: 1),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {

              setState(() {
                _isVisible = !_isVisible;
              });

              if (!_isVisible) {
                // Hide both Status Bar and Navigation Bar
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              } else {
                // Restore both System UIs
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              }
            },
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: InteractiveViewer(
                    child: Image.file(
                      File(widget.image),
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame == null) {
                          return SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: MediaQuery.sizeOf(context).height,
                            child: Center(child: LoadingIndicator(os: getOs())),
                          );
                        }
                        return child;
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          child: Center(
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              size: 30.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: _isVisible,
                  child: FadeIn(
                    duration: Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 36.0
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Tooltip(
                            message: 'Back',
                            enableFeedback: true,
                            child: Material(
                              elevation: 2.0,
                              color: isDarkTheme ?
                              Colors.grey.shade800.withValues(alpha: 0.85) :
                              Colors.grey.shade300.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(
                                50.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(
                                  50.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 28.0,
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Material(
                            elevation: 2.0,
                            color: isDarkTheme ?
                            Colors.grey.shade800.withValues(alpha: 0.85) :
                            Colors.grey.shade300.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(
                              50.0,
                            ),
                            child: PopupMenuButton(
                              elevation: 8.0,
                              iconSize: 28.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsetsGeometry.all(12.0),
                              iconColor: isDarkTheme ? Colors.white : Colors.black,
                              clipBehavior: Clip.antiAlias,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'save',
                                  child: Row(
                                    children: [
                                      Icon(
                                        EvaIcons.downloadOutline,
                                        color:
                                        isDarkTheme ? AppColors.anotherDarkPrimaryColor :
                                        AppColors.lightPrimaryColor,
                                        size: 26.0,
                                      ),
                                      8.0.hrSpace,
                                      const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.close_rounded,
                                        color: AppColors.redColor,
                                        size: 26.0,
                                      ),
                                      8.0.hrSpace,
                                      const Text(
                                        'Remove',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'save') {
                                  showLoading(context, isDarkTheme);
                                  await saveImage(_globalKey, context).then((value) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      backgroundColor:
                                      isDarkTheme ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor,
                                      content: const Text(
                                        'Image has been saved to your gallery',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ));
                                  });
                                } else if (value == 'remove') {
                                  widget.appCubit.deleteImageNoteFromDataBase(id: widget.id);
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ],
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
  }
}
