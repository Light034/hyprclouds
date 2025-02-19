#include <iostream>
#include <fstream>
#include <sstream>
#include <unordered_map>
#include <vector>
#include <string>
#include <cstdlib>
#include <json/json.h>
#include "wayfire-information-client-protocol.h"

class WayfireAppMonitor {
public:
    WayfireAppMonitor() {
        display = wl_display_connect(nullptr);
        if (!display) {
            std::cerr << "Failed to connect to Wayland display." << std::endl;
            exit(1);
        }

        registry = wl_display_get_registry(display);
        if (!registry) {
            std::cerr << "Failed to get Wayland registry." << std::endl;
            exit(1);
        }

        wl_registry_add_listener(registry, &registry_listener, this);
        wl_display_roundtrip(display);

        if (!wf_info_manager) {
            std::cerr << "Wayfire info protocol not available. Is wf-info plugin enabled?" << std::endl;
            exit(1);
        }

        wf_info_base_add_listener(wf_info_manager, &info_listener, this);
        loadInstalledApps();
    }

    ~WayfireAppMonitor() {
        wl_display_disconnect(display);
    }

    void run() {
        while (true) {
            if (wl_display_dispatch(display) == -1) {
                std::cerr << "Wayland connection error. Exiting." << std::endl;
                break;
            }
        }
    }

private:
    wl_display *display;
    wl_registry *registry;
    wf_info_base *wf_info_manager;
    std::unordered_map<std::string, std::pair<std::string, std::string>> installed_apps;

    static void registry_add(void *data, wl_registry *registry, uint32_t id, const char *interface, uint32_t version) {
        WayfireAppMonitor *monitor = static_cast<WayfireAppMonitor *>(data);
        if (strcmp(interface, wf_info_base_interface.name) == 0) {
            monitor->wf_info_manager = static_cast<wf_info_base *>(wl_registry_bind(registry, id, &wf_info_base_interface, 1));
        }
    }

    static void registry_remove(void *data, wl_registry *registry, uint32_t id) {}

    static void receive_view_info(void *data, wf_info_base *wf_info_base, uint32_t view_id, int client_pid,
                                  int ws_x, int ws_y, const char *app_id, const char *title, const char *role,
                                  int x, int y, int width, int height, int xwayland, int focused,
                                  const char *output_name, uint32_t output_id) {
        WayfireAppMonitor *monitor = static_cast<WayfireAppMonitor *>(data);

        if (strcmp(role, "TOPLEVEL") != 0 || strcmp(app_id, "nil") == 0) {
            return;
        }

        Json::Value json_app;
        json_app["name"] = app_id;
        auto match = monitor->installed_apps.find(app_id);
        json_app["icon"] = (match != monitor->installed_apps.end()) ? match->second.first : "";
        json_app["desktop"] = (match != monitor->installed_apps.end()) ? match->second.second : "";
        json_app["title"] = title;
        json_app["focused"] = focused ? true : false;
        json_app["output"] = output_name;

        Json::StreamWriterBuilder writer;
        std::string output = Json::writeString(writer, json_app);
        std::cout << output << std::endl;
    }

    void loadInstalledApps() {
        std::ifstream file("/home/$USER/.cache/installed_apps.json");
        if (!file.is_open()) {
            std::cerr << "Failed to open installed_apps.json" << std::endl;
            return;
        }

        Json::Value root;
        file >> root;
        for (const auto &app : root) {
            std::string name = app["name"].asString();
            std::string icon = app["icon"].asString();
            std::string desktop = app["desktop"].asString();
            installed_apps[name] = {icon, desktop};
        }
    }

    static const struct wl_registry_listener registry_listener;
    static const struct wf_info_base_listener info_listener;
};

const struct wl_registry_listener WayfireAppMonitor::registry_listener = {
    .global = WayfireAppMonitor::registry_add,
    .global_remove = WayfireAppMonitor::registry_remove,
};

const struct wf_info_base_listener WayfireAppMonitor::info_listener = {
    .view_info = WayfireAppMonitor::receive_view_info,
};

int main() {
    WayfireAppMonitor monitor;
    monitor.run();
    return 0;
}
