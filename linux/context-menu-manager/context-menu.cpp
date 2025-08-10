#include "context-menu.h"

#include <filesystem>
#include <iostream>
#include <unordered_map>
#include <vector>
#include <fontconfig/fontconfig.h>

void createMenuItem(int rootMenuIndex, GtkWidget* parentMenuWidget, const MenuItem& menuItem);

struct Menu
{
    GtkWidget* menuWidget = nullptr;
    std::vector<GtkWidget*> items = {};
};

static GdkWindow* window = nullptr;
static std::unordered_map<int, Menu> menus = {};
static int menuIndex = -1;
static HandlerPtr itemClickHandler = nullptr;
static void* itemClickHandlerUserData = nullptr;

void initIconsFont()
{
    char buf[PATH_MAX];
    const ssize_t size = readlink("/proc/self/exe", buf, sizeof(buf)-1);

    if (size <= 0)
    {
        fprintf(stderr, "  - [ERROR] could not read path to the executable\n");
    }

    buf[size] = '\0';
    const std::filesystem::path p(buf);
    const auto path = p.parent_path();

    const auto fontPath = path.string() + "/data/flutter_assets/fonts/MaterialIcons-Regular.otf";
    const FcBool fontAddStatus = FcConfigAppFontAddFile(FcConfigGetCurrent(), reinterpret_cast<const FcChar8*>(fontPath.c_str()));
    if (fontAddStatus) {
        fprintf(stdout, "  - allocated font-config font from `%s`\n", fontPath.c_str());
    } else {
        fprintf(stderr, "  - [ERROR] could not load font from file `%s`\n", fontPath.c_str());
    }
}

void contextMenuInit(GdkWindow* win)
{
    window = win;

    const auto css =
        "menuitem {"
        "  font-size: 14px;"
        "  padding: 6px 10px 6px 6px;"
        // "  min-width: 250px;"
        // "}"
        // "menuitem image {"
        // "  margin-right: 8px;"
        "}";
    GtkCssProvider *provider = gtk_css_provider_new ();
    gtk_css_provider_load_from_data (provider, css, -1, nullptr);
    gtk_style_context_add_provider_for_screen (
        gdk_screen_get_default (),
        GTK_STYLE_PROVIDER(provider),
        GTK_STYLE_PROVIDER_PRIORITY_USER
    );
    g_object_unref(provider);
}

int createMenu(const std::vector<MenuItem>& items)
{
    GtkWidget* menuWidget = gtk_menu_new();
    g_object_ref_sink(menuWidget);

    gtk_menu_set_reserve_toggle_size(GTK_MENU(menuWidget), FALSE);
    gtk_widget_show_all(menuWidget);

    Menu menu = {.menuWidget = menuWidget};

    menuIndex += 1;
    menus.insert({menuIndex, menu});

    for(const MenuItem& item : items)
    {
        createMenuItem(menuIndex, menuWidget, item);
    }

    return  menuIndex;
}

void destroyMenu(const int index)
{
    std::cout << "Destroying menu: " << index << std::endl;
    GtkWidget* menu = menus[index].menuWidget;
    gtk_widget_destroy(menu);
    g_object_unref(menu);
}

static void onMenuItemClicked(GtkWidget* widget, gpointer data)
{
    gpointer menuIndexPtr = g_object_get_data(G_OBJECT(widget), "menuIndex");
    const long parentMenuIndex = reinterpret_cast<long>(menuIndexPtr);
    const auto itemIndex = reinterpret_cast<long>(data);
    // std::cout << "Menu index: " << menuIndex << ". Selected item: " << itemIndex << std::endl;
    itemClickHandler(parentMenuIndex, itemIndex, itemClickHandlerUserData);
}

void createMenuItem(const int rootMenuIndex, GtkWidget* parentMenuWidget, const MenuItem& menuItem)
{
    GtkWidget* item = gtk_menu_item_new();
    GtkWidget *hBox  = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 6);

    if(menuItem.iconNumber > 0)
    {
        gchar utf8_char[8] = {};
        g_unichar_to_utf8(menuItem.iconNumber, utf8_char);
        const gchar* markup = g_strdup_printf(
            R"(<span font_family="%s" size="16pt">%s</span>)",
            "MaterialIcons",
            utf8_char
        );

        GtkWidget* icon = gtk_label_new(nullptr);
        gtk_label_set_markup(GTK_LABEL(icon), markup);
        gtk_box_pack_start(GTK_BOX(hBox), icon, FALSE, FALSE, 0);
    }

    GtkWidget* label = gtk_label_new(menuItem.labelText.c_str());
    gtk_box_pack_start(GTK_BOX(hBox), label, FALSE, FALSE, 0);
    gtk_container_add(GTK_CONTAINER(item), hBox);

    gtk_menu_shell_append(GTK_MENU_SHELL(parentMenuWidget), item);

    gtk_widget_show_all(item);
    gtk_widget_set_sensitive(item, menuItem.enabled);

    if(!menuItem.children.empty())
    {
        GtkWidget* submenu = gtk_menu_new();
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(item), submenu);
        gtk_menu_set_reserve_toggle_size(GTK_MENU(submenu), FALSE);

        for(const MenuItem& child : menuItem.children)
        {
            createMenuItem(menuIndex, submenu, child);
        }

        gtk_widget_show_all(submenu);
    }
    else
    {
        g_object_set_data(G_OBJECT(item), "menuIndex", reinterpret_cast<gpointer>(rootMenuIndex));
        g_signal_connect(G_OBJECT(item), "activate",
            G_CALLBACK(onMenuItemClicked), reinterpret_cast<gpointer>(menuItem.id));
    }
}

void showMenu(const int index)
{
    GdkSeat   *seat    = gdk_display_get_default_seat(gdk_display_get_default());
    GdkDevice *pointer = gdk_seat_get_pointer(seat);

    int gx, gy;
    gdk_device_get_position(pointer, nullptr, &gx, &gy);

    const GdkRectangle rect = { gx, gy };

    GtkWidget* menu = menus[index].menuWidget;
    gtk_menu_popup_at_rect(GTK_MENU(menu), window, &rect,
        GDK_GRAVITY_NORTH_WEST, GDK_GRAVITY_NORTH_WEST, nullptr);
}

void registerItemClickHandler(const HandlerPtr handler, void* userData)
{
    itemClickHandler = handler;
    itemClickHandlerUserData = userData;
}
