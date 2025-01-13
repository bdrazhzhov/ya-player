#include "auth-manager.h"
#include <stdexcept>

struct ResourceLoadData
{
  GtkWidget* window;
  AuthManager* authManager;
};

AuthManager::AuthManager(FlPluginRegistry* registry)
{
  g_autoptr(FlPluginRegistrar) yaPlayerWindowRegistrar =
                                   fl_plugin_registry_get_registrar_for_plugin(
                                       registry, "YaPlayerAuthManager");
  _binaryMessenger = fl_plugin_registrar_get_messenger(yaPlayerWindowRegistrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  _channel = fl_method_channel_new(_binaryMessenger, "YaPlayerAuthManager/events", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(_channel, _handleMethodCall, this, nullptr);
}

gboolean AuthManager::_onResourceLoadStarted(WebKitWebView *webView, WebKitWebResource *resource,
                                             WebKitURIRequest *request, gpointer userData)
{
  const gchar *uri = webkit_uri_request_get_uri(request);

  if (g_str_has_prefix(uri, "https://music.yandex.ru/#access_token="))
  {
    gchar** strs = g_strsplit(uri, "#", 2);

    GHashTable* params = g_uri_parse_params(strs[1], -1, "&", GUriParamsFlags::G_URI_PARAMS_PARSE_RELAXED, nullptr);

    const auto accessToken = static_cast<const char*>(g_hash_table_lookup(params, "access_token"));
    const auto expiresIn = static_cast<const char*>(g_hash_table_lookup(params, "expires_in"));
    const auto data = static_cast<ResourceLoadData*>(userData);

    gtk_window_close(GTK_WINDOW(data->window));

    FlValue* args = fl_value_new_map();
    fl_value_set_string(args, "accessToken", fl_value_new_string(accessToken));
    fl_value_set_string(args, "expiresIn", fl_value_new_string(expiresIn));
    fl_method_channel_invoke_method(data->authManager->_channel, "onAuthCompleted", args, nullptr, nullptr, nullptr);

    return TRUE;
  }

  return FALSE;
}

void AuthManager::_onWindowClose(GtkWidget* self, gpointer userData)
{
  auto* authManager = static_cast<AuthManager*>(userData);
  authManager->_isWindowOpened = false;
}

void AuthManager::_handleMethodCall(FlMethodChannel* /*channel*/, FlMethodCall* methodCall, gpointer userData)
{
  const auto authManager = static_cast<AuthManager*>(userData);
  g_autoptr(FlMethodResponse) response;

  const gchar* method = fl_method_call_get_name(methodCall);
//  FlValue* args = fl_method_call_get_args(methodCall);

  try {
    if(strcmp(method, "openAuthWindow") == 0)
    {
      authManager->_openAuthWindow();
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
    else
    {
      response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }
  }
  catch (const std::runtime_error& exception) {
    response = FL_METHOD_RESPONSE(fl_method_error_response_new("YaPlayerAuthError", exception.what(), nullptr));
    printf("[YaPlayerAuthManager]: Exception!\n");
  }

  fl_method_call_respond(methodCall, response, nullptr);
}

void AuthManager::_openAuthWindow()
{
  if(_isWindowOpened) return;

  WebKitWebContext* context = webkit_web_context_new();
  WebKitWebView* webview = WEBKIT_WEB_VIEW(webkit_web_view_new_with_context(context));
  WebKitSettings* settings = webkit_web_view_get_settings(webview);
  webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_NEVER);

  GtkWidget* window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_default_size(GTK_WINDOW(window), 600, 900);
  gtk_window_set_title(GTK_WINDOW(window), "Login");
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(webview));
  auto* data = new ResourceLoadData{window, this};
  g_signal_connect(webview, "resource-load-started", G_CALLBACK(AuthManager::_onResourceLoadStarted), data);
  g_signal_connect(window, "destroy", G_CALLBACK(AuthManager::_onWindowClose), this);
  gtk_widget_grab_focus(GTK_WIDGET(webview));
  gtk_widget_show_all(window);
  const char* url = "https://passport.yandex.ru/auth?origin=music_app"
                    "&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken"
                    "%26client_id%3D23cabbbdc6cd418abb4b39c32c41195d%26redirect_uri"
                    "%3Dhttps%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm"
                    "%3DFalse%26language%3Den";
  webkit_web_view_load_uri(webview, url);
  _isWindowOpened = true;
}
