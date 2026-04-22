import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_controller.dart';
import 'package:yoloapp/shared/widgets/section_card.dart';

/// Không gian làm việc suy luận hình ảnh đơn lẻ.
class ImageWorkspace extends GetView<YoloLabController> {
  const ImageWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Ảnh Tĩnh',
      subtitle:
          'Ảnh được chọn từ thư viện hoặc camera, sau đó chạy `YOLO.predict` bằng model hiện tại.',
      child: Obx(() {
        final preview = controller.annotatedImageBytes.value ??
            controller.selectedImageBytes.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('Ảnh đang dùng: ${controller.activeModelSummary}')),
                Chip(label: Text('Trạng thái: ${controller.modelLoadStateLabel}')),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: controller.pickImageFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Chọn ảnh'),
                ),
                FilledButton.tonalIcon(
                  onPressed: controller.captureImageWithCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Chụp ảnh'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.isRunningImageInference.value
                      ? null
                      : controller.runImageInference,
                  icon: const Icon(Icons.auto_fix_high_outlined),
                  label: const Text('Chạy lại'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ảnh hiện tại: ${controller.activeImageLabel}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: preview == null
                      ? const Center(
                          child: Text('Chưa có ảnh để hiển thị'),
                        )
                      : Image.memory(
                          preview,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            if (controller.isRunningImageInference.value) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ] else if (controller.isModelPreparing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        );
      }),
    );
  }
}
