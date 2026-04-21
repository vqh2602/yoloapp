import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yoloapp/app/config/configurations.dart';
import 'package:yoloapp/core/models/yolo_capture_mode.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_controller.dart';
import 'package:yoloapp/features/yolo_lab/widgets/camera_workspace.dart';
import 'package:yoloapp/features/yolo_lab/widgets/image_workspace.dart';
import 'package:yoloapp/features/yolo_lab/widgets/model_source_card.dart';
import 'package:yoloapp/features/yolo_lab/widgets/result_list_panel.dart';
import 'package:yoloapp/shared/theme/app_theme.dart';
import 'package:yoloapp/shared/widgets/section_card.dart';

/// Landing page of the demo app.
class YoloLabPage extends GetView<YoloLabController> {
  const YoloLabPage({super.key});

  static const String routeName = '/yolo_lab';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Env.config.appName),
      ),
      body: Obx(() {
        final isWide = MediaQuery.sizeOf(context).width >= 1080;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF6F2E7),
                Color(0xFFE7F3F1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionCard(
                    title: 'YOLO Workspace',
                    subtitle:
                        'Camera live dùng `YOLOView`, ảnh tĩnh dùng `YOLO.predict`, và model có thể đổi từ official ID hoặc tệp cục bộ.',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        Env.config.flavorName.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Env.config.supportNote),
                        const SizedBox(height: 8),
                        Text(
                          Env.config.docsNote,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<YoloCaptureMode>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: YoloCaptureMode.camera,
                              label: Text('Camera'),
                              icon: Icon(Icons.videocam_outlined),
                            ),
                            ButtonSegment(
                              value: YoloCaptureMode.image,
                              label: Text('Ảnh'),
                              icon: Icon(Icons.photo_library_outlined),
                            ),
                          ],
                          selected: <YoloCaptureMode>{controller.captureMode.value},
                          onSelectionChanged: (selection) {
                            controller.changeCaptureMode(selection.first);
                          },
                        ),
                        if (controller.errorMessage.value != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          controller.statusMessage.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: const [
                              ModelSourceCard(),
                              SizedBox(height: 20),
                              _WorkspaceSwitcher(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          flex: 3,
                          child: ResultListPanel(),
                        ),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        ModelSourceCard(),
                        SizedBox(height: 20),
                        _WorkspaceSwitcher(),
                        SizedBox(height: 20),
                        ResultListPanel(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WorkspaceSwitcher extends GetView<YoloLabController> {
  const _WorkspaceSwitcher();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.captureMode.value == YoloCaptureMode.camera) {
        return const CameraWorkspace();
      }

      return const ImageWorkspace();
    });
  }
}
