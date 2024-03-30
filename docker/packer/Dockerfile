FROM --platform=linux/amd64 ubuntu:latest
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
    wget \
    make \
    curl \
    git \
    unzip \
    luarocks \
    && rm -rf /var/lib/apt/lists/*

# Install neovim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && tar -C /opt -xzf nvim-linux64.tar.gz
ENV PATH="$PATH:/opt/nvim-linux64/bin"

RUN luarocks install uuid 
RUN luarocks install luafilesystem

RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim /root/.local/share/nvim/site/pack/packer/start/packer.nvim
COPY config /root/.config/nvim
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

VOLUME ["/root/.config/nvim", "/root/.local/share/nvim"]

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
