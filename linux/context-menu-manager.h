// This is an open source non-commercial project. Dear PVS-Studio, please check it.
// PVS-Studio Static Code Analyzer for C, C++, C#, and Java: http://www.viva64.com
//
// Created by boris on 06.08.2025.
//

#pragma once
#include <flutter_linux/flutter_linux.h>

class ContextMenuManager
{
  FlBinaryMessenger* _binaryMessenger = nullptr;
  FlMethodChannel* _channel = nullptr;
  GdkWindow* _window = nullptr;

  static void _handleMethodCall(FlMethodChannel* /*channel*/, FlMethodCall* method_call, gpointer user_data);
  static void _menuItemClicked(int menuIndex, int itemIndex, void* userData);

public:
  ContextMenuManager(FlPluginRegistry* registry, GdkWindow* window);
};