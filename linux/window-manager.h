#pragma once
#include <cmath>
#include <flutter_linux/flutter_linux.h>

class WindowManager
{
  FlBinaryMessenger* _binaryMessenger = nullptr;
  FlMethodChannel* _channel = nullptr;
  GtkWindow* _window = nullptr;
  GtkHeaderBar* _headerBar = nullptr;
  GtkWidget* _backButton = nullptr;
  GtkWidget* _icon = nullptr;
  GtkStyleContext* _styleContext = nullptr;

  static void _handleMethodCall(FlMethodChannel* /*channel*/, FlMethodCall* method_call, gpointer user_data) {
    const auto windowManager = static_cast<WindowManager*>(user_data);
    g_autoptr(FlMethodResponse) response;

    const gchar* method = fl_method_call_get_name(method_call);
    FlValue* args = fl_method_call_get_args(method_call);

    printf("[YaPlayerWindow]: Method name: %s, arguments type: %d\n",
      method, fl_value_get_type(args));

    try {
      if(strcmp(method, "setWindowTitle") == 0)
      {
        const gchar* title = fl_value_get_string(fl_value_get_list_value(args, 0));
        const gchar* subTitle = fl_value_get_string(fl_value_get_list_value(args, 1));
        windowManager->_setWindowTitle(title, subTitle);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      }
      else if(strcmp(method, "showBackButton") == 0)
      {
        const bool needToShow = fl_value_get_bool(args);
        windowManager->showBackButton(needToShow);

        response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      }
      else if(strcmp(method, "getBgColor") == 0)
      {
        FlValue* color = windowManager->_getBgColor();
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(color));
        fl_value_unref(color);
      }
      else if(strcmp(method, "getThemeColors") == 0)
      {
        FlValue* colors = windowManager->_getThemeColors();
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(colors));
        fl_value_unref(colors);
      }
      else if(strcmp(method, "showWindow") == 0)
      {
        windowManager->_showWindow();
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      }
      else
      {
        response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
      }
    }
    catch (const std::runtime_error& exception) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("YaPlayerWindowError", exception.what(), nullptr));
      printf("[YaPlayerWindow]: Exception!\n");
    }

    fl_method_call_respond(method_call, response, nullptr);
  }

  void _setWindowTitle(const char* title, const char* sunTitle) const
  {
    if(_headerBar != nullptr)
    {
      gtk_header_bar_set_title(_headerBar, title);
      gtk_header_bar_set_subtitle(_headerBar, sunTitle);
    }
    else if(_window != nullptr)
    {
      gtk_window_set_title(_window, title);
    }
  }

  [[nodiscard]] FlValue* _getBgColor() const
  {
    GdkRGBA* color = nullptr;
    gtk_style_context_get(_styleContext, gtk_style_context_get_state(_styleContext),
                          GTK_STYLE_PROPERTY_BACKGROUND_COLOR, &color, nullptr);

    const uint32_t colorInt = rgbToInt(color);

    gdk_rgba_free(color);

    return fl_value_new_int(colorInt);
  }

  void showBackButton(const bool show) const
  {
    if(_backButton == nullptr || _icon == nullptr) return;

    gtk_widget_set_visible(GTK_WIDGET(_backButton), show);
    gtk_widget_set_visible(GTK_WIDGET(_icon), !show);
  }

  [[nodiscard]] FlValue* _getThemeColors() const
  {
    GdkRGBA* color = nullptr;
    FlValue* result = fl_value_new_map();

    gtk_style_context_get(_styleContext, gtk_style_context_get_state(_styleContext),
                          GTK_STYLE_PROPERTY_BACKGROUND_COLOR, &color, nullptr);
    fl_value_set_string_take(result, "surface", fl_value_new_int(rgbToInt(color)));
    gdk_rgba_free(color);

    gtk_style_context_get(_styleContext, gtk_style_context_get_state(_styleContext),
                          GTK_STYLE_PROPERTY_COLOR, &color, nullptr);
    fl_value_set_string_take(result, "textColor", fl_value_new_int(rgbToInt(color)));
    gdk_rgba_free(color);

    // fl_value_set_string_take(result, "green", fl_value_new_float(color->green));
    // fl_value_set_string_take(result, "blue", fl_value_new_float(color->blue));
    // fl_value_set_string_take(result, "alpha", fl_value_new_float(color->alpha));

    return result;
  }

  static uint32_t rgbToInt(const GdkRGBA* rgba)
  {
    const uint32_t r = 0xFF & std::lrint(255 * rgba->red);
    const uint32_t g = 0xFF & std::lrint(255 * rgba->green);
    const uint32_t b = 0xFF & std::lrint(255 * rgba->blue);

    return  0xFF000000 | r << 16 | g << 8 | b;
  }

  void _showWindow() const
  {
    gtk_widget_show(GTK_WIDGET(_window));
  }

public:
  WindowManager(FlPluginRegistry* registry,
                GtkWindow* window,
                GtkHeaderBar* headerBar,
                GtkWidget* backButton,
                GtkWidget* icon) :
    _window(window), _headerBar(headerBar),
    _backButton(backButton), _icon(icon)
  {
    _styleContext = gtk_widget_get_style_context(GTK_WIDGET(_headerBar));
    g_autoptr(FlPluginRegistrar) yaPlayerWindowRegistrar =
                                     fl_plugin_registry_get_registrar_for_plugin(
                                         registry, "YaPlayerWindowManager");
    _binaryMessenger = fl_plugin_registrar_get_messenger(yaPlayerWindowRegistrar);
    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    _channel = fl_method_channel_new(_binaryMessenger, "YaPlayerWindowManager/events", FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(_channel, _handleMethodCall, this, nullptr);
  }

  void pushBackButton() const
  {
    FlValue* args = nullptr;
    fl_method_channel_invoke_method(_channel, "onBackButtonClicked", args, nullptr, nullptr, nullptr);
  }
};
