#! /bin/bash

toHelp() {
    echo "hello, world"
}

toRunPulseAudio() {
    if [ $# -eq 1 ]; then
        echo "start to init pulseaudio server"
        docker ps | grep "deepin-wine" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            docker images | grep "pulseaudio-server_pulseaudio" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                startResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml up -d 2>&1 >/dev/null) && echo "pulseaudio server start successfully.. Please execute the command './command.sh -r applicationName' to start application container" || echo "pulseaudio server start failed, the reason is $startResult.."
            else
                buildResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml build 2>&1 >/dev/null) && startResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml up -d 2>&1 >/dev/null) && echo "pulseaudio server build and start successfully.. Please execute the command './command.sh -r applicationName' to start application container" || echo "pulseaudio server build and start failed.. the reason is $buildResult, and $startResult.."
            fi
        else
            echo "application exist! please execute the command './command.sh -d' to uninstall or execute the command './command.sh -',then execute command './command.sh -i' to init pulseaudio server"
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
    docker ps | grep "pulseaudio_server" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker images | grep "deepin-wine-$1" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            docker ps -a | grep "deepin-wine-$1" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                docker ps | grep "deepin-wine-$1" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    startResult=$(docker exec deepin-wine-$1 /bin/bash -c "/home/run.sh" 2>&1 >/dev/null) && echo "restart $1 application successfully" || echo "restart $1 application failed, the reason is $startResult"
                else
                    startResult=$(docker start deepin-wine-$1 2>&1 >/dev/null) && echo "start $1 container successfully.." || echo "start $1 container failed, reason is: $startResult.."
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
                    appName='Thunder'
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
                docker0IP=$(ip addr | grep 'docker0' | grep 'inet' | cut -c 10- | cut -c -10)
                runResult=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/Documents/$appName:/home/files -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE -e PULSE_SERVER=tcp:$docker0IP:4713 --name deepin-wine-$1 deepin-wine-$1-image 2>&1 >/dev/null) && echo "$1 container run successfully.. enjoy!" || echo "$1 container run failed.. the reason is $runResult"
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
            docker0IP=$(ip addr | grep 'docker0' | grep 'inet' | cut -c 10- | cut -c -10)
            buildResult=$(docker build -t deepin-wine-$1-image $2/wine/$appName/ 2>&1 >/dev/null) && runResult=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/Documents/$appName:/home/files -e DISPLAY=unix$DISPLAY -e GDK_SCALE -e GDK_DPI_SCALE -e PULSE_SERVER=tcp:$docker0IP:4713 --name deepin-wine-$1 deepin-wine-$1-image 2>&1 >/dev/null) && echo "$1 container build and run successfully.. enjoy!" || echo "$1 container build and run failed.. the reason is $buildResult, $runResult"
        fi
    else
        echo "pulseaudio server not running, please execute the command './command.sh -i' to init pulseaudio server"
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

toStopSoftwareContainer() {
    docker ps -a | grep "deepin-wine-$1" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        result=$(docker stop deepin-wine-$1 2>&1 >/dev/null) || echo "close $1 container failed, reason is: $result.."
    fi
    echo "close $1 container successfully.."
}

toClosePulseAudio() {
    if [ $# -eq 1 ]; then
        echo "start to close pulseaudio.."
        docker ps | grep "deepin-wine" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            stopAppResult=$(docker stop $(docker ps | grep "deepin-wine" | awk '{print $1 }') 2>&1 >/dev/null) && echo "stop application successfully.. now start to stop pulseaudio-server.." || {
                echo "stop application failed, the reason is $stopAppResult.."
                exit
            }
        fi
        docker ps | grep "pulseaudio_server" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            stopResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml down 2>&1 >/dev/null) || echo "stop pulseaudio server failed, the reason is $stopResult.."
        fi
        echo "stop pulseaudio server successfully.."
    else
        toHelp
    fi
}

toUninstall() {
    if [ $# -eq 1 ]; then
        echo "start to uninstall.."
        docker images | grep "deepin-wine" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            docker ps | grep "deepin-wine" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                wineContainers=$(docker ps | grep "deepin-wine" | awk '{print $1}')
                stopWineResult=$(docker stop $wineContainers 2>&1 >/dev/null) && echo "stop wine containers successfully.." || {
                    echo "stop wine containers failed.. the reason $stopWineResult.."
                    exit
                }
            fi
            docker ps -a | grep "deepin-wine" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                wineContainer=$(docker ps -a | grep "deepin-wine" | awk '{print $1}')
                removeWineResult=$(docker rm $wineContainer 2>&1 >/dev/null) && echo "remove wine containers successfully.." || {
                    echo "remove wine containers failed.. the reason $removeWineResult"
                    exit
                }
            fi
            wineImages=$(docker images | grep "deepin-wine" | awk '{print $3}')
            stopWineResult=$(docker rmi $wineImages 2>&1 >/dev/null) && echo "remove wine images successfully.. start to stop and remove pulseaudio server container.." || {
                echo "remove wine containers failed.. the reason is $stopWineResult.."
                exit
            }
        fi
        docker images | grep "pulseaudio-server_pulseaudio" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            pulseaudioImages=$(docker images | grep "pulseaudio-server_pulseaudio" | awk '{print $3}')
            docker ps | grep "pulseaudio_server" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                stopPulseAudioResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml down 2>&1 >/dev/null) && echo "stop pulseaudio server successfully.." || {
                    echo "stop pulseaudio pulseaudio server failed.. the reason is $stopPulseAudioResult"
                    exit
                }
            fi
            removePulseAudioResult=$(docker rmi $pulseaudioImages 2>&1 >/dev/null) && echo "remove pulseaudio server successfully.." || {
                echo "remove pulseaudio server failed.. the reason is $removePulseAudioResult.."
                exit
            }
        fi
        echo "uninstall deepin-wine-docker successfully!"
    else
        toHelp
    fi
}

toUpgrade() {
    if [ $# -eq 1 ]; then
        echo "start to upgrade.."
        docker images | grep "deepin-wine" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            docker ps | grep "deepin-wine" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                runContainers=$(docker ps | grep "deepin-wine" | awk '{print $1}')
                stopWineResult=$(docker stop $runContainers 2>&1 >/dev/null) && echo "stop wine containers successfully.." || {
                    echo "stop wine containers failed.. the reason is $stopWineResult.."
                    exit
                }
            fi
            docker ps -a | grep "deepin-wine" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                wineContainer=$(docker ps -a | grep "deepin-wine" | awk '{print $1}')
                removeWineResult=$(docker rm $wineContainer 2>&1 >/dev/null) && echo "remove wine containers successfully.." || {
                    echo "remove wine containers failed.. the reason is $removeWineResult.."
                    exit
                }
            fi
            wineImages=$(docker images | grep "deepin-wine" | awk '{print $3}')
            removeImageResult=$(docker rmi $wineImages 2>&1 >/dev/null) && echo "remove application containers successfully.." || {
                echo "remove applications failed.. the reason is $removeImageResult.."
                exit
            }

        fi
        docker ps | grep "pulseaudio_server" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            stopPulseAudioResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml down 2>&1 >/dev/null) && echo "stop pulseaudio server successfully" || {
                echo "stop pulseaudio server failed, the reason is $stopPulseAudioResult"
                exit
            }
        fi
        upgradePulseAudioResult=$(docker-compose -f $1/pulseaudio-server/docker-compose.yml build 2>&1 >/dev/null) && echo "rebuild the pulseaudio server container successfully.." || {
            echo "rebuild pulseaudio failed.. the reason is $upgradePulseAudioResult"
            exit
        }
        echo "please execute the command './command.sh -i' to init the pulseaudio-server and execute the command './command.sh -r applicationName', then will be upgrade the application container"
    else
        toHelp
    fi
}

type docker 2>&1 >/dev/null || {
    echo "docker command not found, please install docker.Abotring."
    exit
}

type docker-compose 2>&1 >/dev/null || {
    echo "docker-compose command not found, please install docker.Abotring."
    exit
}

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
