import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/router/app_routes.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/image_picking.dart';
import 'package:kwentappflutter/core/utils/validators.dart';
import 'package:kwentappflutter/ui/post_editor/post_editor_state.dart';
import 'package:kwentappflutter/ui/post_editor/post_editor_viewmodel.dart';
import 'package:provider/provider.dart';

class PostEditorPage extends StatefulWidget {
  const PostEditorPage({super.key, this.postId});

  final String? postId;

  bool get isEditing => postId != null;

  @override
  State<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _images = <EditorImage>[];

  late final PostEditorViewModel _viewModel;
  var _autovalidate = AutovalidateMode.disabled;
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PostEditorViewModel>();
    _hydrate(notify: false);
    _viewModel.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onStateChanged() => _hydrate();

  void _hydrate({bool notify = true}) {
    if (_hydrated) return;

    final state = _viewModel.state;
    if (state is! PostEditorReady) return;

    _hydrated = true;

    final post = state.post;
    if (post == null) return;

    _titleController.text = post.title;
    _bodyController.text = post.body;
    _images.addAll(
      post.images.map((image) => ExistingImage(id: image.id, url: image.url)),
    );

    if (notify && mounted) setState(() {});
  }

  Future<void> _attach() async {
    final slots = Constants.maxImagesPerPost - _images.length;

    if (slots <= 0) {
      CommonSnackbar.show(
        context,
        Strings.imageLimit(Constants.maxImagesPerPost),
      );
      return;
    }

    final picked = await pickImages(slots: slots);
    if (!mounted) return;

    if (picked.images.isNotEmpty) {
      setState(() => _images.addAll(picked.images.map(NewImage.new)));
    }

    if (picked.skipped) {
      CommonSnackbar.show(context, Strings.someImagesSkipped);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    final outcome = await _viewModel.save(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      keptImageIds: _images.keptImageIds,
      newImages: _images.newImageBytes,
    );

    if (!mounted || outcome == null) return;

    switch (outcome) {
      case EditorFailed(:final message):
        CommonSnackbar.showError(context, message);
      case EditorSucceeded(:final postId):
        if (widget.isEditing) {
          _leave();
        } else {
          context.pushReplacement(AppRoutes.detailOf(postId));
        }
    }
  }

  Future<void> _delete() async {
    final confirmed = await CommonConfirmDialog.show(
      context,
      title: Strings.deletePost,
      message: Strings.deletePostMessage,
      confirmLabel: Strings.delete,
    );

    if (!confirmed || !mounted) return;

    final outcome = await _viewModel.delete();
    if (!mounted || outcome == null) return;

    switch (outcome) {
      case EditorFailed(:final message):
        CommonSnackbar.showError(context, message);
      case EditorSucceeded():
        _returnToFeed();
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.feed);
  }

  void _returnToFeed() {
    if (context.canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    context.go(AppRoutes.feed);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostEditorViewModel>().state;
    final isSaving = state is PostEditorReady && state.isSaving;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isSaving ? null : _leave,
          tooltip: Strings.closeEditor,
          icon: const Icon(Icons.close),
        ),
        title: Text(widget.isEditing ? Strings.editKwento : Strings.newKwento),
        actions: [
          if (state is PostEditorReady)
            TextButton(
              onPressed: state.isBusy ? null : _save,
              child: isSaving
                  ? const CommonLoader(size: 18)
                  : const Text(Strings.save),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: switch (state) {
        PostEditorLoading() => const CommonLoader(),
        PostEditorLoadError(:final message) => _LoadFailed(
          message: message,
          onRetry: _viewModel.load,
        ),
        PostEditorReady() => _form(state),
      },
    );
  }

  Widget _form(PostEditorReady state) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl * 2,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  controller: _titleController,
                  label: Strings.titleLabel,
                  enabled: !state.isBusy,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) =>
                      Validators.notEmpty(value, Strings.titleRequired),
                ),
                const SizedBox(height: AppSpacing.lg),
                CommonTextField(
                  controller: _bodyController,
                  label: Strings.storyLabel,
                  enabled: !state.isBusy,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 6,
                  maxLines: 12,
                  validator: (value) =>
                      Validators.notEmpty(value, Strings.storyRequired),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  Strings.imagesHeading(
                    _images.length,
                    Constants.maxImagesPerPost,
                  ),
                  style: theme.textTheme.labelLarge,
                ),
                ImagePickerRow(
                  images: _images,
                  enabled: !state.isBusy,
                  maxImages: Constants.maxImagesPerPost,
                  markNew: widget.isEditing,
                  showCounter: false,
                  onAdd: _attach,
                  onRemove: (index) => setState(() => _images.removeAt(index)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(Strings.maxImagesNote, style: theme.textTheme.bodySmall),
                if (widget.isEditing) ...[
                  const SizedBox(height: AppSpacing.xl),
                  TextButton(
                    onPressed: state.isBusy ? null : _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      padding: EdgeInsets.zero,
                    ),
                    child: state.isDeleting
                        ? const CommonLoader(size: 16)
                        : const Text(Strings.deletePost),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              Strings.kwentoLoadFailed,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text(Strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
