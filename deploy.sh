#!/bin/bash

# 服务名称
SERVICE_NAME="goatcounter"
# 程序路径（根据实际路径修改）
APP_PATH="/app/goatcounter/goatcounter"
# 日志路径
LOG_FILE="/app/goatcounter/goatcounter.log"
# PID文件路径（用于进程管理）
PID_FILE="/var/run/${SERVICE_NAME}.pid"

ENV_FILE="/app/goatcounter/.env/env.txt"

# 环境变量配置
source $ENV_FILE

case "$1" in
    start)
        echo "Starting ${SERVICE_NAME}..."
        # 检查是否已运行
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Service is already running."
            exit 1
        fi
        # 启动命令
        nohup $APP_PATH serve > $LOG_FILE 2>&1 &
        echo $! > $PID_FILE
        echo "Service started with PID $(cat $PID_FILE)"
        ;;
    stop)
        echo "Stopping ${SERVICE_NAME}..."
        if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Service not running."
            exit 1
        fi
        kill $(cat "$PID_FILE")
        rm -f $PID_FILE
        echo "Service stopped"
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Service is running (PID: $(cat $PID_FILE))"
        else
            echo "Service is not running"
        fi
        ;;
    logs)
        tail -f $LOG_FILE
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac

exit 0