#compdef actuator
#autoload

function _actuator {
    local line

    _arguments -C \
        "1: :(serve develop restart pull_all develop_specific)" \
        "*::arg:->args"

    case $line[1] in
        serve)
            _actuator_process_keys
            ;;
        develop)
            _actuator_process_keys
            ;;
        restart)
            _actuator_process_keys
            ;;
        develop_specific)
            _actuator_projects
            ;;
    esac
}

function _actuator_process_keys {
    _arguments "1: :($(actuator info process_keys | tr '\n' ' '))"
}

function _actuator_projects {
    _arguments "1: :($(actuator info projects | tr '\n' ' '))"
}

compdef _actuator actuator
