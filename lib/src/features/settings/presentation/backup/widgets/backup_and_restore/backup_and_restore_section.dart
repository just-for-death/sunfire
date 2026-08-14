import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../utils/misc/file_picker_utils.dart';
import '../../../../../../utils/misc/toast/toast.dart';
import '../../../../../../utils/misc/user_facing_error.dart';
import '../../../../../../widgets/section_title.dart';
import '../../../../../../widgets/settings/adaptive_list_tile.dart';
import '../../../../domain/settings/settings.dart';
import '../../data/backup_settings_repository.dart';
import 'widgets/backup_missing_dialog.dart';
import 'widgets/create_backup_dialog.dart';
import 'widgets/restore_status_progress.dart';

class BackupAndRestoreSection extends HookConsumerWidget {
  const BackupAndRestoreSection({super.key});

  Future<PlatformFile?> getBackupFile(
      BuildContext context, Toast? toast) async {
    final asyncPickedFile =
        await AsyncValue.guard(() => FilePickerUtils.pickFile(
              context: context,
              extensions: ['gz', 'tachibk'],
            ));
    if (!context.mounted) {
      return null;
    }
    if (asyncPickedFile.hasError || asyncPickedFile.value == null) {
      toast?.showError(userFacingError(context, asyncPickedFile.error));
      return null;
    }
    return asyncPickedFile.value;
  }

  Future<String?> backupFilePicker(WidgetRef ref, BuildContext context) async {
    Toast? toast = ref.read(toastProvider);

    final pickedFile = await getBackupFile(context, toast);
    if (pickedFile == null) return null;

    final asyncBackupFile = await AsyncValue.guard(
        () => FilePickerUtils.convertToMultipartFile(pickedFile, "backup"));

    if (context.mounted &&
        (asyncBackupFile.hasError || asyncBackupFile.value == null)) {
      asyncBackupFile.showToastOnError(toast);
      return null;
    }

    final backupFile = asyncBackupFile.value!;
    if (context.mounted) toast?.show(context.l10n.validating);

    final validateResult = await AsyncValue.guard(() =>
        ref.read(backupSettingsRepositoryProvider).validateBackup(backupFile));

    if (context.mounted && validateResult.hasError) {
      validateResult.showToastOnError(toast);
      return null;
    }

    String? backupId;
    bool restoreBackup = true;
    if (validateResult.valueOrNull.isNotBlank && context.mounted) {
      restoreBackup = (await context.showAdaptiveAppDialog<bool>(
        builder: (context) =>
            BackupMissingDialog(backupMissing: validateResult.valueOrNull!),
      ))
          .ifNull();
    }

    if (restoreBackup) {
      if (!context.mounted) return backupId;
      final restoreErrorMessage = context.l10n.errorSomethingWentWrong;
      // A MultipartFile can only be finalized once, and validate above already
      // consumed `backupFile`, so restore needs a freshly-read one.
      final asyncRestoreFile = await AsyncValue.guard(
          () => FilePickerUtils.convertToMultipartFile(pickedFile, "backup"));
      if (asyncRestoreFile.hasError || asyncRestoreFile.value == null) {
        asyncRestoreFile.showToastOnError(toast);
        return null;
      }
      final backupResponse = (await AsyncValue.guard(() => ref
          .read(backupSettingsRepositoryProvider)
          .restoreBackup(asyncRestoreFile.value!)));

      if (backupResponse.hasError) {
        toast?.showError(restoreErrorMessage);
      } else {
        if (backupResponse.hasValue) {
          backupId = backupResponse.value;
        }
        if (context.mounted) {
          toast?.show(context.l10n.restoring, instantShow: true);
        }
      }
    }
    return backupId;
  }

  @override
  Widget build(context, ref) {
    final restoreId = useState<String?>(null);
    final toast = ref.watch(toastProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: context.l10n.backupAndRestore),
        AdaptiveListTile(
          title: Text(context.l10n.createBackupTitle),
          subtitle: Text(context.l10n.createBackupDescription),
          leading: const Icon(Icons.backup_rounded),
          onTap: () {
            context.showAdaptiveAppDialog(builder: (context) => const CreateBackupDialog(),
            );
          },
        ),
        AdaptiveListTile(
          title: Text(context.l10n.restoreBackupTitle),
          subtitle: Text(context.l10n.restoreBackupDescription),
          leading: const Icon(Icons.restore_rounded),
          trailing: restoreId.value != null
              ? RestoreStatusProgress(
                  restoreRequestId: restoreId.value!,
                  onCompleted: (state) {
                    if (state == RestoreState.FAILURE) {
                      toast?.showError(context.l10n.errorBackupRestore,
                          withMicrotask: true);
                    } else {
                      toast?.show(
                        context.l10n.restored,
                        withMicrotask: true,
                        instantShow: true,
                      );
                    }
                    restoreId.value = null;
                  },
                )
              : null,
          onTap: () async =>
              restoreId.value = await backupFilePicker(ref, context),
        ),
        const Gap(8),
      ],
    );
  }
}
