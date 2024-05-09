import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community.dart';
import 'package:reddit/theme/pallet.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _linkController = TextEditingController();

  File? bannerFile;

  List<Community> userCommunities = [];
  Community? selectedCommunity;

  void sharePost({required String type}) {
    final postMethod = ref.read(postControllerProvider.notifier);

    if (type == "image" &&
        _titleController.text.isNotEmpty &&
        bannerFile != null) {
      final shared = postMethod.shareImagePost(
          context: context,
          selectedComunity: selectedCommunity ?? userCommunities[0],
          title: _titleController.text,
          bannerFile: bannerFile);
      return shared;
    } else if (type == "link" &&
        _linkController.text.isNotEmpty &&
        _titleController.text.isNotEmpty) {
      final shared = postMethod.shareLinkPost(
          context: context,
          selectedComunity: selectedCommunity ?? userCommunities[0],
          title: _titleController.text,
          link: _linkController.text.trim());
      return shared;
    } else if (type == "text" && _titleController.text.isNotEmpty) {
      final shared = postMethod.shareTextPost(
        context: context,
        selectedComunity: selectedCommunity ?? userCommunities[0],
        title: _titleController.text,
        description: _bodyController.text.trim(),
      );
      return shared;
    }
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _linkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type.toLowerCase() == "image";
    final isTypeText = widget.type.toLowerCase() == "text";
    final isTypeLink = widget.type.toLowerCase() == "link";
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ${widget.type}"),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => sharePost(type: widget.type),
            child: const Text(
              'Share',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Add ${widget.type} title",
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(18),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        strokeCap: StrokeCap.round,
                        dashPattern: const [10, 4],
                        color: currentTheme.textTheme.bodyLarge!.color!,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bannerFile != null
                              ? Image.file(bannerFile!)
                              : const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  if (isTypeText)
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        hintText: "Body Text",
                        filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLines: 5,
                    ),
                  if (isTypeLink)
                    TextField(
                      keyboardType: TextInputType.url,
                      controller: _linkController,
                      decoration: const InputDecoration(
                        hintText: "link",
                        filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Select Community"),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          userCommunities = data;

                          if (data.isEmpty) {
                            return const SizedBox();
                          }

                          return DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                              });
                            },
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}
