//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_start_flutter/auto_start_flutter_plugin.h>
#include <mmkv_linux/mmkv_linux_plugin.h>
#include <sentry_flutter/sentry_flutter_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) auto_start_flutter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AutoStartFlutterPlugin");
  auto_start_flutter_plugin_register_with_registrar(auto_start_flutter_registrar);
  g_autoptr(FlPluginRegistrar) mmkv_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "MmkvLinuxPlugin");
  mmkv_linux_plugin_register_with_registrar(mmkv_linux_registrar);
  g_autoptr(FlPluginRegistrar) sentry_flutter_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SentryFlutterPlugin");
  sentry_flutter_plugin_register_with_registrar(sentry_flutter_registrar);
}
