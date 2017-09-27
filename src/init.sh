#!/bin/bash
#
# Init script
#
###########################################################

export DOCKER_LOG=/var/log/docker.log
if [ "$DEBUG" = true ]; then
  export DEBUG_LOG=$DOCKER_LOG
else
  export DEBUG_LOG=/dev/null
fi

# Initialize CCache if it will be used
if [ "$USE_CCACHE" = 1 ]; then
  ccache -M 20G 2>&1 >&$DEBUG_LOG
fi

# Initialize Git user information
git config --global user.name $USER_NAME
git config --global user.email $USER_MAIL

