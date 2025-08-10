#pragma once
#include <string>
#include <vector>
#include <gtk/gtk.h>

typedef void (*HandlerPtr)(int menuIndex, int itemIndex, void* userData);
struct MenuItem
{
    int id;
    std::string labelText;
    uint32_t iconNumber;
    bool enabled;
    std::vector<MenuItem> children;
};

void initIconsFont();
void contextMenuInit(GdkWindow* window);
int createMenu(const std::vector<MenuItem>& items);
void destroyMenu(int index);
void showMenu(int index);
void registerItemClickHandler(HandlerPtr handler, void* userData);
