#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

#=================================================
# PERSONAL HELPERS
#=================================================

start_mc_service() {
    ynh_systemd_action --service_name=$app --action=start --log_path=systemd --line_match=".*INFO] Server started."
}

stop_mc_service() {
    ynh_systemd_action --service_name=$app --action=stop --log_path=systemd --line_match=".*Stopped minecraft_bedrock.service.*"
}



#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
