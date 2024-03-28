FROM --platform=linux/amd64 ubuntu:latest
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install neovim
RUN wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && tar -C /opt -xzf nvim-linux64.tar.gz
ENV PATH="$PATH:/opt/nvim-linux64/bin"

COPY config /root/.config/nvim
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim /root/.local/share/nvim/site/pack/packer/start/packer.nvim
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

VOLUME ["/root/.config/nvim", "/root/.local/share/nvim"]

WORKDIR /root/.local/share/nvim/site/pack/packer/opt/illustrate.nvim
# CMD ["make run_tests"]
CMD ["nvim"]
