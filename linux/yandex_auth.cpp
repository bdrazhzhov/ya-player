#include <iostream>
#include <gtk/gtk.h>
#include <webkit/webkit.h>

struct AuthData {
    const char* authToken;
    guint64 expiresIn;
};

struct CallbackData {
    GMainLoop* loop;
    AuthData* authData;
};

static gboolean on_close_request(GtkWindow*, GMainLoop *loop)
{
    g_main_loop_quit(loop); // Завершение главного цикла
    return FALSE;           // Разрешает продолжить обработку сигнала (закрыть окно)
}

static gboolean
on_resource_load_started(WebKitWebView*, WebKitWebResource*, WebKitURIRequest *request, CallbackData* data)
{
    const gchar *uri = webkit_uri_request_get_uri(request);

    if (g_str_has_prefix(uri, "https://music.yandex.ru/#access_token=")) {
        gchar** strs = g_strsplit(uri, "#", 2);

        GHashTable* params = g_uri_parse_params(strs[1], -1, "&", GUriParamsFlags::G_URI_PARAMS_PARSE_RELAXED, nullptr);

        {
            const auto value = static_cast<const char*>(g_hash_table_lookup(params, "access_token"));
            data->authData->authToken = value;

        }

        {
            const auto value = static_cast<const char*>(g_hash_table_lookup(params, "expires_in"));
            g_ascii_string_to_unsigned(value, 10, 0, UINT64_MAX, &data->authData->expiresIn, nullptr);
        }

        g_main_loop_quit(data->loop);
    }

    return FALSE;
}

int main()
{
    AuthData authData = {};

    gtk_init();

    // Создание окна
    GtkWidget *window = gtk_window_new();
    gtk_window_set_title(GTK_WINDOW(window), "Login");
    gtk_window_set_default_size(GTK_WINDOW(window), 600, 800);

    // Главный цикл обработки событий
    GMainLoop* loop = g_main_loop_new(nullptr, FALSE);
    CallbackData data = { .loop = loop, .authData = &authData };

    // Создание WebKit виджета
    WebKitWebView *webview = WEBKIT_WEB_VIEW(webkit_web_view_new());
    g_signal_connect(webview, "resource-load-started", G_CALLBACK(on_resource_load_started), &data);

    // Загрузка веб-страницы
    webkit_web_view_load_uri(webview, "https://passport.yandex.ru/auth?origin=music_app&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken%26client_id%3D23cabbbdc6cd418abb4b39c32c41195d%26redirect_uri%3Dhttps%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm%3DFalse%26language%3Den");

    // Создание контейнера и добавление WebView
    gtk_window_set_child(GTK_WINDOW(window), GTK_WIDGET(webview));

    // Отображение окна
    gtk_window_present(GTK_WINDOW(window));

    // Подключение сигнала для закрытия окна
    g_signal_connect(window, "close-request", G_CALLBACK(on_close_request), loop);

    g_main_loop_run(loop);
    g_main_loop_unref(loop);

    std::cout << authData.authToken;

    return 0;
}
