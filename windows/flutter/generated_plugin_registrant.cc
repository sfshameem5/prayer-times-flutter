//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_start_flutter/auto_start_flutter_plugin.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <mmkv_win32/mmkv_win32_plugin.h>
#include <sentry_flutter/sentry_flutter_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AutoStartFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AutoStartFlutterPlugin"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  MmkvWin32PluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MmkvWin32Plugin"));
  SentryFlutterPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SentryFlutterPlugin"));
}
