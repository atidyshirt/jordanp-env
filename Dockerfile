# Docker file for jordanp-env image.
# @author Jordan Pyott

# Debian image as base (unstable for newest software).
FROM debian:sid-20211220

# Set image locale.
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV TZ=Pacific/Auckland
ENV TERM=xterm-256color

# Expose some ports to host by default.
EXPOSE 8080 8081 8082 8083 8084 8085

# Lazygit variables
ARG LG='lazygit'
ARG LG_GITHUB='https://github.com/jesseduffield/lazygit/releases/download/v0.31.4/lazygit_0.31.4_Linux_x86_64.tar.gz'
ARG LG_ARCHIVE='lazygit.tar.gz'

# Update repositories and install software:
RUN apt-get update && apt-get -y install ninja-build cmake g++ unzip curl fzf ripgrep tree git xclip \
    python3 python3-pip nodejs npm tzdata zip unzip zsh tmux neovim exa docker libcurl4-gnutls-dev

# Cooperate Neovim with Python 3.
RUN pip3 install pynvim pyright

# Cooperate NodeJS with Neovim.
RUN npm i -g neovim typescript-language-server typescript

# Install Packer.
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Create directory for Neovim configuration files.
RUN mkdir -p /root/.config/nvim

# Copy Neovim configuration files.
COPY ./config/ /root/.config/

# Install Neovim extensions.
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

RUN mkdir -p /root/TMP

# Install Lazygit from binary
RUN cd /root/TMP && curl -L -o $LG_ARCHIVE $LG_GITHUB
RUN cd /root/TMP && tar xzvf $LG_ARCHIVE && mv $LG /usr/bin/

# Delete TMP directory
RUN rm -rf /root/TMP

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

# Bash aliases
COPY ./home/ /root/

RUN chsh -s $(which zsh)

# Create directory for projects (there should be mounted from host).
RUN mkdir -p /home/ws

# Set default location after container startup.
WORKDIR /home/ws

# Avoid container exit.
CMD ["tail", "-f", "/dev/null"]
