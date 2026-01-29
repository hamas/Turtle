import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadHistoryProvider = FutureProvider<List<TaskRecord>>((ref) async {
  return await FileDownloader().database.allRecords();
});

class DownloadNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    FileDownloader().updates.listen((update) async {
      if (update is TaskProgressUpdate) {
        state = {...state, update.task.taskId: update.progress};
      } else if (update is TaskStatusUpdate) {
        if (update.status == TaskStatus.complete) {
          final task = update.task;
          if (task is DownloadTask) {
            try {
              await FileDownloader().moveToSharedStorage(
                task,
                SharedStorage.downloads,
                directory: 'Turtle Downloads',
              );
            } catch (e) {
              debugPrint('Error moving to shared storage: $e');
            }
          }

          await FileDownloader().database.deleteRecordWithId(task.taskId);
        }

        if (update.status.isFinalState) {
          final newState = Map<String, double>.from(state);
          newState.remove(update.task.taskId);
          state = newState;
          // Invalidate history to refresh UI
          ref.invalidate(downloadHistoryProvider);
        }
      }
    });

    FileDownloader().trackTasks();
    return {};
  }

  void trackTask(Task task) {
    state = {...state, task.taskId: 0.0};
  }

  Future<void> onTaskStatusUpdate(TaskStatusUpdate update) async {
    if (update.status == TaskStatus.complete) {
      // Database record deletion is handled by DownloadService for internal tasks presumably,
      // or we can just ensure UI state is cleared.
      // FileDownloader().database.deleteRecordWithId(task.taskId);
      // Manual tasks might not be in DB?
      // If we want history, we should insert into DB manually if FileDownloader didn't do it.
      // For now, let's just clear progress state.
    }

    if (update.status.isFinalState) {
      final newState = Map<String, double>.from(state);
      newState.remove(update.task.taskId);
      state = newState;
      ref.invalidate(downloadHistoryProvider);
    }
  }
}

final downloadTasksProvider =
    NotifierProvider<DownloadNotifier, Map<String, double>>(
      DownloadNotifier.new,
    );
