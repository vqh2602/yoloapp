import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yoloapp/core/utils/formatters.dart';
import 'package:yoloapp/core/models/yolo_capture_mode.dart';
import 'package:yoloapp/features/yolo_lab/yolo_lab_controller.dart';
import 'package:yoloapp/shared/widgets/section_card.dart';

/// Displays the latest inference results from the active mode.
class ResultListPanel extends GetView<YoloLabController> {
  const ResultListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Kết Quả',
      subtitle:
          'Danh sách dưới đây luôn bám theo mode hiện tại: camera live hoặc ảnh tĩnh.',
      child: Obx(() {
        final detections = controller.captureMode.value == YoloCaptureMode.camera
            ? controller.liveDetections
            : controller.imageDetections;

        if (detections.isEmpty) {
          return const Text('Chưa có kết quả nào. Hãy thử đổi model hoặc chọn ảnh.');
        }

        return Column(
          children: detections
              .map(
                (detection) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text('${detection.classIndex}'),
                  ),
                  title: Text(detection.className),
                  subtitle: Text(
                    'bbox: '
                    '${detection.boundingBox.left.toStringAsFixed(0)}, '
                    '${detection.boundingBox.top.toStringAsFixed(0)}, '
                    '${detection.boundingBox.width.toStringAsFixed(0)} x '
                    '${detection.boundingBox.height.toStringAsFixed(0)}',
                  ),
                  trailing: Text(
                    formatPercent(detection.confidence),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              )
              .toList(growable: false),
        );
      }),
    );
  }
}
