#! /bin/bash

toHelp() {
    echo "hello, world"
}

toRunPulseAudio() {
    if [ $# -eq 1 ]; then
        echo "start to init pulseaudio server"
        docker images | grep "pulseaudio-server_pulseaudio" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            startResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml up -d >/dev/null 2>&1) && echo "pulseaudio server start successfully.." || echo "pulseaudio server start failed, the reason is $startResult.."
        else
            buildResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml build >/dev/null 2>&1) && startResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml up -d >/dev/null 2>&1) && echo "pulseaudio server build and start successfully.. Please execute the command './command.sh -r applicationName' to start application container" || echo "pulseaudio server build and start failed.. the reason is $buildResult.."
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

toRunSoftwareContainer() {
    docker images | grep "deepin-wine-$1" 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        docker ps -a | grep "deepin-wine-$1" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            docker ps | grep "deepin-wine-$1" 2>&1 >/dev/null
            if [ $? -eq 0 ]; then
                startResult=$(docker exec deepin-wine-$1 /bin/bash -c "/home/run.sh" >/dev/null 2>&1) && echo "restart $1 application successfully" || echo "restart $1 application failed, the reason is $startResult"
            else
                startResult=$(docker start deepin-wine-$1 >/dev/null 2>&1) && echo "start $1 container successfully.." || echo "start $1 container failed, reason is: $startResult.."
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
            runResult=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/Documents/$appName:/home -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE -e PULSE_SERVER=tcp:$docker0IP:4713 --name deepin-wine-$1 deepin-wine-$1-image >/dev/null 2>&1) && echo "$1 container run successfully.." || echo "$1 container run failed.. the reason is $runResult"
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
        buildResult=$(docker build -t deepin-wine-$1-image $2/wine/$appName/ >/dev/null 2>&1) && runResult=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/Documents/$appName:/home/files -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE -e PULSE_SERVER=tcp:$docker0IP:4713 --name deepin-wine-$1 deepin-wine-$1-image >/dev/null 2>&1) && echo "$1 container build and run successfully.." || echo "$1 container build and run failed.. the reason is $buildResult, $runResult"
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
            echo "start to stop $1 application"
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

# todo: judge
toStopSoftwareContainer() {
    result=$(docker stop deepin-wine-$1 >/dev/null 2>&1) && echo "close $1 container successfully.." || echo "close $1 container failed, reason is: $result.."
}

# todu: jedge
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

toUninstall() {
    if [ $# -eq 1 ]; then
        echo "start to uninstall.."
        docker images | grep "deepin-wine" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            docker ps | grep "deepin-wine" 2>&1 >/dev/null
            if [ $? -eq 0 ]; then
                wineContainers=$(docker ps | grep "deepin-wine" | awk '{print $1}')
                stopWineResult=$(docker stop $wineContainers >/dev/null 2>&1) && echo "stop wine containers successfully.." || {
                    echo "stop wine containers failed.. the reason $stopWineResult.."
                    exit
                }
            fi
            docker ps -a | grep "deepin-wine" 2>&1 >/dev/null
            if [ $? -eq 0 ]; then
                wineContainer=$(docker ps -a | grep "deepin-wine" | awk '{print $1}')
                removeWineContainer=$(docker rm $wineContainer >/dev/null 2>&1) && echo "remove wine containers successfully.." || {
                    echo "remove wine containers failed.. the reason $removeWineContainer"
                    exit
                }
            fi
            wineImages=$(docker images | grep "deepin-wine" | awk '{print $3}')
            stopWineResult=$(docker rmi $wineImages >/dev/null 2>&1) && echo "remove wine images successfully.. start to stop and remove pulseaudio server container.." || {
                echo "remove wine containers failed.. the reason is $stopWineResult.."
                exit
            }
        fi
        docker images | grep "pulseaudio-server_pulseaudio" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            pulseaudioImages=$(docker images | grep "pulseaudio-server_pulseaudio" | awk '{print $3}')
            stopPulseAudioResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml down >/dev/null 2>&1 && docker rmi $pulseaudioImages >/dev/null 2>&1) && echo "stop pulseaudio server successfully.." || {
                echo "stop and remove pulseaudio server failed.. the reason is $stopPulseAudioResult.."
                exit
            }
        fi
        echo "uninstall deepin-wine-docker successfully!"
    else
        toHelp
    fi
}

# todu: judge
toUpgrade() {
    if [ $# -eq 1 ]; then
        echo "start to upgrade.."
        docker ps | grep "deepin-wine" 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
            wineContainers=$(docker ps | grep "deepin-wine" | awk '{print $1}')
            wineImages=$(docker images | grep "deepin-wine" | awk '{print $3}')
            removeWineResult=$(docker stop $wineContainers && docker rm $wineContainers && docker rmi $wineImages >/dev/null 2>&1) && echo "stop and remove wine containers successfully.. start to stop and rebuild pulseaudio server container.." || {
                echo "stop and remove wine containers failed.. the reason is $removeWineResult.."
                exit
            }
        fi
        upgradePulseAudioResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml down && docker-compose -f $1/pulseaudio-server/docker-compose.yml build >/dev/null 2>&1) && echo "rebuild the pulseaudio server container successfully.." || {
            echo "rebuild pulseaudio failed.. the reason is $upgradePulseAudioResult"
            exit
        }
        echo "please execute the command './command.sh -i' to init the pulseaudio-server and execute the command './command.sh -r applicationName', then will be upgrade the application container"
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
-d)
    toUninstall $command_folder
    ;;
-u)
    toUpgrade $command_folder
    ;;
-h) ;&
*)
    toHelp
    ;;
esac
