#!/bin/bash

# curl -sL https://raw.githubusercontent.com/atidyshirt/jordanp-env/master/setup.sh | bash -

# add environment variables and script .bashrc
echo "# Dockerize your Shell" >> ~/.zshrc
echo "DOCKER_MACHINE_NAME=dshell" >> ~/.zshrc
echo "DOCKER_IMAGE_NAME=dshell_image" >> ~/.zshrc
echo "DOCKERFILE_PATH=~/.docker-env" >> ~/.zshrc

mkdir -p ~/.docker-env
GIT_URL=https://raw.githubusercontent.com/atidyshirt/jordanp-env/master

# TODO: check for a dockerfile before possibly writing over it!
curl -sL $GIT_URL"/Dockerfile" -o ~/.docker-env/Dockerfile
curl -sL $GIT_URL"/.zshrc" -o ~/.docker-env/.zshrc

#!/bin/bash

export PS1='osx $ '

# this is to help find commands executed by ssh (non-interactive)
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# determine if connected over ssh
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SESSION_TYPE=remote/ssh
else
  case $(ps -o comm= -p $PPID) in
         sshd|*/sshd) SESSION_TYPE=remote/ssh;;
  esac
fi

# only run these commands if logged in locally
if [ "$SESSION_TYPE" != "remote/ssh" ]; then
  docker-machine ls | grep "^$DOCKER_MACHINE_NAME" > /dev/null
  if [ $? -ne 0 ]; then
    echo "$DOCKER_MACHINE_NAME docker-machine not found. Attempting to create one."
    docker-machine create --driver virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 4 $DOCKER_MACHINE_NAME
  fi
  if [ "$(docker-machine status $DOCKER_MACHINE_NAME)" = "Stopped" ]; then
    echo "$DOCKER_MACHINE_NAME docker-machine is stopped. Attempting to start it."
    docker-machine start $DOCKER_MACHINE_NAME
    sleep 3
  fi
  eval "$(docker-machine env $DOCKER_MACHINE_NAME)"
  if [ -z "$(docker images -q $DOCKER_IMAGE_NAME)" ]; then
    if [ ! -d $DOCKERFILE_PATH ]; then
      mkdir $DOCKERFILE_PATH
      GIT_URL=https://raw.githubusercontent.com/atidyshirt/jordanp-env/master
      curl -sL $GIT_URL"/Dockerfile" -o ~/.docker-env/Dockerfile
    fi
    (cd $DOCKERFILE_PATH && docker build --build-arg USERNAME=$USER --build-arg HOMEDIR=$HOME -t $DOCKER_IMAGE_NAME .)
  fi
  MYIP=`ifconfig vboxnet0 | grep 'inet ' | awk '{print $2}'`
  start_dshell="docker run -it --rm -v $HOME:$HOME/.host -v /var/run/docker.sock:/var/run/docker.sock -e HOSTIP=$MYIP $DOCKER_IMAGE_NAME"
  alias dshell=$start_dshell
  alias dbuild="(cd $DOCKERFILE_PATH && docker build --build-arg USERNAME=$USER --build-arg HOMEDIR=$HOME -t $DOCKER_IMAGE_NAME .)"
  alias dmrestart='docker-machine restart $DOCKER_MACHINE_NAME && sleep 3 && eval "$(docker-machine env $DOCKER_MACHINE_NAME)"'
  $start_dshell
fi
