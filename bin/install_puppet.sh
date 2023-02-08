#!/bin/bash

err () {
  echo "$2" >&2
  exit "$1"
}

installed="$(puppet -V 2> /dev/null)"
if [[ "${installed%%.*}" != '6' ]] ; then
  [[ -n "$installed" ]] && yum -y erase 'puppet*'
  url='https://yum.puppet.com/puppet6-release-el-7.noarch.rpm'
  wget --spider -q "$url" &> /dev/null
  case "$?" in
    8)    err 2 "No Puppet 6 installer for CentOS 7 in $url"  ;;
    [^0]) err 3 "Broken link to installer repo $url"          ;;
  esac
  rpm -Uvh "$url"
  yum -y install puppet-agent
fi
