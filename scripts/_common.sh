#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

#=================================================
# PERSONAL HELPERS
#=================================================

start_mc_service() {
    ynh_systemd_action --service_name=$app --action=start
}

stop_mc_service() {
    ynh_systemd_action --service_name=$app --action=stop
}

is_mc_service_running() {
    systemctl is-active --quiet "$app"
}

stop_mc_service_if_running() {
    if is_mc_service_running; then
        stop_mc_service
    fi
}



#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
