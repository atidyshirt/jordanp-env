FROM ubuntu

# these help to avoid warnings during some of the apt-get installs below
ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

# get up-to-date
RUN apt-get update \
  && apt-get -y upgrade

# install all the standard things
RUN apt-get install -y ubuntu-standard

# add git-core ppa so we can get the latest greatest git
RUN apt-get install -y software-properties-common \
  && add-apt-repository ppa:git-core/ppa \
  && apt-get update

# lets install this new git and a few other handy things
RUN apt-get install -y \
  git \
  build-essential \
  curl \
  sudo \
  neovim \
  zsh

# install docker
RUN apt-get install apt-transport-https ca-certificates \
  && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
  && echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y docker-engine

# install docker-compose
RUN curl -sL https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > docker-compose \
  && chmod +x docker-compose \
  && sudo mv docker-compose /usr/local/bin

# at least USERNAME must be passed in as a build-arg
ONBUILD ARG USERNAME
ONBUILD ARG HOMEDIR=/home/$USERNAME

# when you run this docker container, you need to mount this directory
ONBUILD ENV MOUNTDIR=$HOMEDIR/.host

# create the user and setup sudo
ONBUILD RUN mkdir /Users \
  && useradd -d $HOMEDIR -G root -ms /bin/bash $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# link to content on .host
ONBUILD RUN chmod 700 $HOMEDIR/.ssh \
  && ln -sf $MOUNTDIR/.ssh/id_rsa $HOMEDIR/.ssh/id_rsa \
  && ln -sf $MOUNTDIR/.ssh/known_hosts $HOMEDIR/.ssh/known_hosts \
  && ln -sf $MOUNTDIR/.config $HOMEDIR/.config \
  && chown -R $USERNAME: $HOMEDIR

RUN git clone $GIT_URL /etc/$USER
RUN echo "source /etc/bash-dockerize-my-shell.sh" >> /etc/.zshrc


# define how it is executed
ONBUILD USER $USERNAME
ONBUILD WORKDIR $HOMEDIR


CMD ["/bin/zsh"]
