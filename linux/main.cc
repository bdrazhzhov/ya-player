#include "my_application.h"
#include <context-menu.h>

int main(int argc, char** argv) {
  initIconsFont();
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
