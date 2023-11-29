#!/bin/zsh

alias remove_ansi="sed -e 's/\x1b\[[0-9;]*m//g'"

if [[ -z "$ZELLIJ" && $(zellij setup --check) ]]; then
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
                if [[ "$(echo "${ZJ_SESSIONS//$'\n'/ }" | remove_ansi)" =~ ".*$SESSION_NAME.*" ]]; then
                    zellij attach $SESSION_NAME
                else
                    zellij -s $SESSION_NAME
                fi
            fi
        else
            # List current sessions, attach to a running session, or create a new one
            if [ "${NO_SESSIONS}" -ge 2 ]; then
                zellij attach \
                "$(echo "${ZJ_SESSIONS}" | sk --ansi | cut -d ' ' -f 1)"
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
