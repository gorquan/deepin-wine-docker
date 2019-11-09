#! /bin/bash

toHelp() {
    echo "hello, world"
}

toRunPulseAudio() {
    if [ $# -eq 1 ]; then
        docker images | grep "pulseaudio-server_pulseaudio" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            startResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml up -d >/dev/null 2>&1) && echo "pulseaudio server start successfully.." || echo "pulseaudio server start failed, the reason is $startResult.."
        else
            buildResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml build >/dev/null 2>&1) && startResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml up -d >/dev/null 2>&1) && echo "pulseaudio server build and start successfully.. Please " || echo "pulseaudio server build and start failed.."
        fi
    else
        toHelp
    fi
}

toStartSoftware() {
    if [ $# -eq 2 ]; then
        case $1 in
        wechat) ;&
        tim) ;&
        thunder) ;&
        qqmusic)
            # if you need to launch another app, add the app name here.
            echo "start to start $1 application"
            toRunSoftwareContainer $1 $2
            ;;
        *)
            echo "unsupport your application"
            ;;
        esac
    else
        toHelp
    fi
}

# TODO:  1. 重启应用后退出终端 2.测试微信和TIM
toRunSoftwareContainer() {
    docker images | grep "deepin-wine-$1" 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        docker ps -a | grep "deepin-wine-$1" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            docker ps | grep "deepin-wine-$1" 2>&1 >/dev/null
            if [ $? -eq 0 ]; then
                startResult=$(docker exec deepin-wine-$1 /bin/bash -c "/home/run.sh" >/dev/null 2>&1) && echo "restart $1 application successfully" || echo "restart $1 application failed"
            else
                startResult=$(docker start deepin-wine-$1 >/dev/null 2>&1) && echo "start $1 container successfully.." || echo "start $1 container failed, reason is: $startResult.."
            fi
        else
            runResult=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/Documents/$appName:/home -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE -e PULSE_SERVER=tcp:$docker0IP:4713 --name deepin-wine-$1 deepin-wine-$1-image >/dev/null 2>&1) && echo "$1 container run successfully.." || echo "$1 container run failed.."
        fi
    else
        case $1 in
        wechat)
            appName='Wechat'
            ;;
        tim)
            appName='TIM'
            ;;
        thunder)
            appName='thunder'
            ;;
        qqmusic)
            appName='QQMusic'
            ;;
            # if you need to launch another app, add the app name here.
        *)
            echo "unsupport your application"
            ;;
        esac
        if [ ! -d "$HOME/Documents/$appName" ]; then
            mkdir -p $HOME/Documents/$appName
        fi
        docker0IP=$(ifconfig docker0 | grep "netmask" | awk '{print $2}')
        buildResult=$(docker build -t deepin-wine-$1-image $2/wine/$appName/ >/dev/null 2>&1) && runResult=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/Documents/$appName:/home/files -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE -e PULSE_SERVER=tcp:$docker0IP:4713 --name deepin-wine-$1 deepin-wine-$1-image >/dev/null 2>&1) && echo "$1 container build and run successfully.." || echo "$1 container build and run failed.."
    fi
}

toStopSoftware() {
    if [ $# -eq 1 ]; then
        case $1 in
        wechat) ;&
        tim) ;&
        thunder) ;&
        qqmusic)
            # if you need to stop another app, add the app name here.
            echo "start to close $1 application"
            toStopSoftwareContainer $1
            ;;
        *)
            echo "unsupport your application"
            ;;
        esac
    else
        toHelp
    fi
}

toStopSoftwareContainer() {
    result=$(docker stop deepin-wine-$1 >/dev/null 2>&1) && echo "close $1 container successfully.." || echo "close $1 container failed, reason is: $result.."
}

toClosePulseAudio() {
    if [ $# -eq 1 ]; then
        docker ps | grep "deepin-wine" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            stopAppResult=$(docker stop $(docker ps | grep "deepin-wine" | awk '{print $1 }') >/dev/null 2>&1) && echo "stop application successfully.. now start to stop pulseaudio-server.." || {
                echo "stop application failed, the reason is $stopAppResult.."
                exit
            }
        fi
        stopResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml down >/dev/null 2>&1) && echo "stop pulseaudio server successfully.." || echo "stop pulseaudio server failed, the reason is $stopResult.."
    else
        toHelp
    fi
}

# todo fix
# type docker >/dev/null 2>&1 || {
#     echo "docker command not found, please install docker.Abotring."
#     exit
# }

# todo fix
# type docker-compsose >/dev/null 2>&1 || {
#     echo "docker command not found, please install docker.Abotring."
#     exit
# }

# todo ifconfig

xhostState=$(xhost +local:) && echo "start xhost successfully.." || echo "start xhost failed.. the reason is $xhost.."

command_folder=$(
    cd "$(dirname "$0")"
    pwd
)

case $1 in
-i)
    toRunPulseAudio $command_folder
    ;;
-r)
    toStartSoftware $2 $command_folder
    ;;
-s)
    toStopSoftware $2
    ;;
-c)
    toClosePulseAudio $command_folder
    ;;
-h) ;&
*)
    toHelp
    ;;
esac
