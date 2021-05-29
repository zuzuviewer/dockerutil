#!/bin/bash

function lss() {
    local log_path=$(echo $(get_log_path "$2"))
    ls $log_path
}

function lls() {
   local log_path=$(echo $(get_log_path "$2"))
   ls -l $log_path
}

function clean() {
    echo "start clean container '$2' logs"
    local log_path=$(echo $(get_log_path "$2"))
    cat /dev/null > $log_path
    echo "clean container '$2' logs done"
}

function delete() {
    local log_path=$(echo $(get_log_path "$2"))
    rm -rf $log_path
}

function touchs() {
    local log_path=$(echo $(get_log_path "$2"))
    touch $log_path
}

function get_log_path() {
    local result=$(docker container inspect "$1")

    if [ $? -ne 0 ];then
      echo ${result}
      exit 1
    fi
    local path=$(echo "$result" | grep "LogPath" | sed 's/"LogPath": "//g' | sed 's/",//g')
    echo "${path}"
}

function usage() {
    echo "Usage $0 Action [Options] [container name or container id]
    Actions:
      ls     the same as linux command 'ls',display the container log file;for example 'ls nginx'
      ll     the same as linux command 'll' and 'ls -l',display the container log file with detail information;for example 'll nginx'
      clean  clean the container log file content;for example 'clean nginx'
      delete delete the container log file with -rf;for example 'delete nginx'
      touch  the same as linux command 'touch' work on the container log file;for example 'touch nginx'
      
    Options:
      -h --help view help information"
}

function main(){
    local args=$(getopt -o h -l help -n "$0" -- "$@")
    if [ $? -ne 0 ];then
      >&2 echo "Error get options"
      exit 1
    fi
    local action=$1
    eval set -- "${args}"
    while true
    do
      case "$1" in
        -h|--help)
          shift
          usage
          exit 0
          ;;
        --)
          shift
          break
          ;;
      esac
    done
    if [ $# -le 1 ];then
      echo "must provide action and container name or container id"
      exit 2
    fi
    case $action in
      ls)
        lss "$@"
        ;;
      ll)
        lls "$@"
        ;;
      clean)
        clean "$@"
        ;;
      delete)
        delete "$@"
        ;;
      touch)
        touchs "$@"
        ;;
      *)
        echo $"Usage: $0 {ls|ll|clean|delete|touch NAME|ID"
        exit 2
    esac
}

main "$@"