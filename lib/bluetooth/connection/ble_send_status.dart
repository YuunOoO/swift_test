enum BleSendStatus { success, failure }

extension BleSendStatusExtension on BleSendStatus {
  bool get isSuccessful {
    switch (this) {
      case BleSendStatus.success:
        return true;
      case BleSendStatus.failure:
        return false;
    }
  }
}
