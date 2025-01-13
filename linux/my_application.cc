// This is a personal academic project. Dear PVS-Studio, please check it.
// PVS-Studio Static Code Analyzer for C, C++, C#, and Java: https://pvs-studio.com

#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include <fstream>
#include "window-manager.h"
#include "auth-manager.h"

static WindowManager* windowManager = nullptr;
static AuthManager* authManager = nullptr;

static gboolean onWindowDeleteCallback(GtkWidget* widget, GdkEvent* /*event*/, gpointer /*data*/)
{
  if (windowManager->getHideOnClose())
  {
    gtk_widget_hide(widget);
    return TRUE;
  }

  return FALSE;
}

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void on_button_clicked(GtkButton *button, gpointer user_data)
{
  if(windowManager == nullptr) return;
  windowManager->pushBackButton();
}

void set_cursor(GtkWidget* widget, GdkCursorType cursor_type)
{
  GdkWindow *window = gtk_widget_get_window(widget);
  if (!window) return;

  GdkCursor* cursor = gdk_cursor_new_for_display(gdk_window_get_display(window), cursor_type);
  gdk_window_set_cursor(window, cursor);
  g_object_unref(cursor);
}

gboolean on_button_enter(GtkWidget* widget, GdkEventCrossing* event, gpointer data)
{
  set_cursor(widget, GDK_HAND2);
  return FALSE;
}

gboolean on_button_leave(GtkWidget* widget, GdkEventCrossing* event, gpointer data)
{
  set_cursor(widget, GDK_ARROW);
  return FALSE;
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  GtkCssProvider *css_provider = gtk_css_provider_new();
  gtk_css_provider_load_from_data(css_provider,
                                  ".back-button {"
                                  "   margin: 0;"
                                  "   padding: 0 8px 0 8px;"
                                  "   border: none;"
                                  "   background: none;"
                                  "   font-size: 20px;"
                                  "}",
                                  -1, NULL);

  GdkScreen *screen = gdk_screen_get_default();
  gtk_style_context_add_provider_for_screen(
      screen,
      GTK_STYLE_PROVIDER(css_provider),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION
  );

  g_object_unref(css_provider);


  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  g_signal_connect(window, "delete-event", G_CALLBACK(onWindowDeleteCallback), nullptr);

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
//  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  GtkHeaderBar* header_bar = nullptr;
  GtkWidget* backButton = nullptr;
  GtkWidget* icon = nullptr;

  if (use_header_bar) {
    header_bar = GTK_HEADER_BAR(gtk_header_bar_new());

    icon = gtk_image_new_from_icon_name("YaPlayer", GTK_ICON_SIZE_LARGE_TOOLBAR);
    gtk_widget_set_margin_start(icon, 6);
    gtk_header_bar_pack_start(GTK_HEADER_BAR(header_bar), icon);
    gtk_widget_show(GTK_WIDGET(icon));

    backButton = gtk_button_new_with_label("🡨"); // back button
    GtkStyleContext* context = gtk_widget_get_style_context(backButton);
    gtk_style_context_add_class(context, "back-button");

    g_signal_connect(backButton, "clicked", G_CALLBACK(on_button_clicked), NULL);
    g_signal_connect(backButton, "enter-notify-event", G_CALLBACK(on_button_enter), NULL);
    g_signal_connect(backButton, "leave-notify-event", G_CALLBACK(on_button_leave), NULL);

    gtk_header_bar_pack_start(GTK_HEADER_BAR(header_bar), backButton);
    // gtk_widget_show(GTK_WIDGET(button));

    gtk_header_bar_set_title(header_bar, "YaPlayer");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
    gtk_widget_show(GTK_WIDGET(header_bar));

//    gtk_widget_set_visible(GTK_WIDGET(header_bar), FALSE);
  } else {
    gtk_window_set_title(window, "YaPlayer");
  }

  gtk_window_set_default_size(window, 1080, 720);
  gtk_widget_show(GTK_WIDGET(window));
  // gtk_widget_show_all(GTK_WIDGET(window));

  std::ifstream iconFile;
  iconFile.open("assets/app_icon.png");
  if(iconFile)
  {
    gtk_window_set_icon_from_file(GTK_WINDOW(window),"assets/app_icon.png", nullptr);
  }
  else
  {
    iconFile.open("data/flutter_assets/assets/app_icon.png");
    if(iconFile)
    {
      gtk_window_set_icon_from_file(GTK_WINDOW(window),"data/flutter_assets/assets/app_icon.png", nullptr);
    }
  }

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  windowManager = new WindowManager(FL_PLUGIN_REGISTRY(view),
    window, header_bar, backButton, icon);
  authManager = new AuthManager(FL_PLUGIN_REGISTRY(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
