#!/bin/zsh

# based on `zellij setup --generate-auto-start zsh`
# https://zellij.dev/documentation/integration.html#autostart-on-shell-creation

if [[ -z "$ZELLIJ" ]]; then
    if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
        ZJ_SESSIONS=$(zellij list-sessions)
        NO_SESSIONS=$(echo "${ZJ_SESSIONS}" | wc -l)
        
        if [ -f /tmp/lima/zellij_session_name ]; then
            if [ ! -s /tmp/lima/zellij_session_name ]; then
                # create a new session, even if one already exists
                rm /tmp/lima/zellij_session_name
                zellij
            else
                # use the provided session name
                SESSION_NAME=$(cut -d ' ' -f 1 /tmp/lima/zellij_session_name)
                rm /tmp/lima/zellij_session_name
                if [[ " ${ZJ_SESSIONS//$'\n'/ } " =~ " $SESSION_NAME " ]]; then
                    zellij attach $SESSION_NAME
                else
                    zellij -s $SESSION_NAME
                fi
            fi
        else
            # List current sessions, attach to a running session, or create a new one
            if [ "${NO_SESSIONS}" -ge 2 ]; then
                zellij attach \
                "$(echo "${ZJ_SESSIONS}" | sk)"
            else
               zellij attach -c
            fi
        fi
        
    else
        zellij
    fi

    if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
        exit
    fi
fi
