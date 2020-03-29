package cn.gbshop.flutter_upgrade

import androidx.core.content.FileProvider
/**
 * Providing a custom {@code FileProvider} prevents manifest {@code <provider>} name collisions.
 *
 * <p>See https://developer.android.com/guide/topics/manifest/provider-element.html for details.
 *
 * 参考image_picker, 修复issues
 * https://github.com/mofada/flutter_update_app/issues/3
 */
class UpgradeFileProvider : FileProvider()