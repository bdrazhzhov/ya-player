#include <webkit2/webkit2.h>
#include <flutter_linux/flutter_linux.h>

class AuthManager
{
  FlBinaryMessenger* _binaryMessenger = nullptr;
  FlMethodChannel* _channel = nullptr;
  bool _isWindowOpened = false;

  static gboolean
  _onResourceLoadStarted(WebKitWebView *webView, WebKitWebResource *resource,
                        WebKitURIRequest *request, gpointer userData);
  static void _onWindowClose(GtkWidget* self, gpointer userData);
  static void _handleMethodCall(FlMethodChannel* channel,
                                FlMethodCall* methodCall, gpointer userData);
  void _openAuthWindow();

public:
  AuthManager(FlPluginRegistry* registry);
};
