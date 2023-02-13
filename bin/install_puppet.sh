#!/bin/bash

err () {
  echo "$2" >&2
  exit "$1"
}

case "$1" in
  5)    dir='eol-releases/' ;;
  6|7)  dir=''              ;;
  *)    err 1 'Supported Puppet versions: 5, 6 and 7' ;;
esac

installed="$(puppet -V 2> /dev/null)"
if [[ "${installed%%.*}" != "$1" ]] ; then
  [[ -n "$installed" ]] && yum -y erase 'puppet*'
  url="https://yum.puppet.com/${dir}puppet${1}-release-el-7.noarch.rpm"
  wget --spider -q "$url" &> /dev/null
  case "$?" in
    8)    err 2 "No Puppet $1 installer for CentOS 7 in $url" ;;
    [^0]) err 3 "Broken link to installer repo $url"          ;;
  esac
  rpm -Uvh "$url"
  yum -y install puppet-agent
fi
