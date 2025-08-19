// This is an open source non-commercial project. Dear PVS-Studio, please check it.
// PVS-Studio Static Code Analyzer for C, C++, C#, and Java: http://www.viva64.com
//
// Created by boris on 06.08.2025.
//

#include "context-menu-manager.h"
#include <context-menu.h>
#include <iostream>

ContextMenuManager::ContextMenuManager(FlPluginRegistry* registry, GdkWindow* window)
    : _window(window)
{
  g_autoptr(FlPluginRegistrar) registrar =
                                   fl_plugin_registry_get_registrar_for_plugin(registry, "YaPlayerContextMenuManager");
  _binaryMessenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  _channel = fl_method_channel_new(_binaryMessenger, "YaPlayerContextMenuManager/events", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(_channel, ContextMenuManager::_handleMethodCall, this, nullptr);

  contextMenuInit(_window);
  registerItemClickHandler(_menuItemClicked, this);
}

void fillMenuItemStruct(FlValue* itemMap, MenuItem& menuItem)
{
  FlValue* id_v = fl_value_lookup_string(itemMap, "id");
  FlValue* label_v = fl_value_lookup_string(itemMap, "label");
  FlValue* icon_v = fl_value_lookup_string(itemMap, "icon");
  FlValue* enabled_v = fl_value_lookup_string(itemMap, "enabled");

  menuItem.id = id_v && fl_value_get_type(id_v) == FL_VALUE_TYPE_INT
                ? fl_value_get_int(id_v) : -1;
  menuItem.labelText = label_v && fl_value_get_type(label_v) == FL_VALUE_TYPE_STRING
                       ? fl_value_get_string(label_v) : "<unknown>";
  menuItem.iconNumber = icon_v && fl_value_get_type(icon_v) == FL_VALUE_TYPE_INT
                        ? fl_value_get_int(icon_v) : 0;
  menuItem.enabled = enabled_v && fl_value_get_type(enabled_v) == FL_VALUE_TYPE_BOOL
                     && fl_value_get_bool(enabled_v);

  FlValue* items_v = fl_value_lookup_string(itemMap, "items");
  const size_t itemsCount = fl_value_get_length(items_v);
  if(itemsCount == 0) return;

  for(size_t i = 0; i < itemsCount; i++)
  {
    FlValue* map_val = fl_value_get_list_value(items_v, i);
    if (fl_value_get_type(map_val) != FL_VALUE_TYPE_MAP) continue;

    MenuItem childItem;
    fillMenuItemStruct(map_val, childItem);
    menuItem.children.emplace_back(childItem);
  }
}

void ContextMenuManager::_handleMethodCall(FlMethodChannel* /*channel*/, FlMethodCall* method_call, gpointer user_data)
{
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  g_autoptr(FlMethodResponse) response;

  if(strcmp(method, "showMenu") == 0)
  {
    const int menuIndex = fl_value_get_int(args);
    showMenu(menuIndex);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }
  else if(strcmp(method, "createMenu") == 0)
  {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST)
    {
      std::vector<MenuItem> menuItems;

      const size_t count = fl_value_get_length(args);
      for (size_t i = 0; i < count; i++)
      {
        FlValue* map_val = fl_value_get_list_value(args, i);

        if (fl_value_get_type(map_val) == FL_VALUE_TYPE_MAP)
        {
          MenuItem menuItem;
          fillMenuItemStruct(map_val, menuItem);
          menuItems.emplace_back(menuItem);
        }
      }

      int menuIndex = createMenu(menuItems);

      g_autoptr(FlValue) result = fl_value_new_int(menuIndex);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("BAD_ARGS", "Expected list", nullptr));
    }
  }
  else if(strcmp(method, "destroyMenu") == 0)
  {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_INT)
    {
      int menuIndex = fl_value_get_int(args);
      destroyMenu(menuIndex);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("BAD_ARGS", "Expected integer menu index", nullptr));
    }
  }
  else if(strcmp(method, "updateStyles") == 0)
  {
    if(fl_value_get_type(args) == FL_VALUE_TYPE_MAP)
    {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
    else
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("BAD_ARGS", "Expected map with styles", nullptr));
    }
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

void ContextMenuManager::_menuItemClicked(int menuIndex, int itemIndex, void* userData)
{
  int values[2] = {menuIndex, itemIndex};
  FlValue* args = fl_value_new_int32_list(values, 2);

  ContextMenuManager* self = static_cast<ContextMenuManager*>(userData);
  fl_method_channel_invoke_method(self->_channel, "onMenuItemClicked", args, nullptr, nullptr, nullptr);
}
