FROM cloud9/workspace
MAINTAINER Sebastien Saunier <seb@lewagon.org>

RUN add-apt-repository ppa:git-core/ppa
RUN apt-get update
RUN apt-get install -y git zsh build-essential tklib zlib1g-dev libssl-dev libssl-dev nodejs libffi-dev libxml2 libxml2-dev libxslt1-dev
RUN apt-get clean

# As ubuntu user
WORKDIR /home/ubuntu
USER ubuntu

# Oh-my-zsh
RUN curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh > install.sh && sudo bash install.sh && rm install.sh
USER root
WORKDIR /home/ubuntu/.oh-my-zsh/custom/plugins
RUN git clone git://github.com/zsh-users/zsh-syntax-highlighting.git
RUN git clone git://github.com/zsh-users/zsh-history-substring-search.git
WORKDIR /home/ubuntu
RUN mv .zshrc .zshrc.original && curl -L https://raw.githubusercontent.com/lewagon/dotfiles/master/zshrc > .zshrc
USER ubuntu

# Rbenv & Ruby
RUN curl https://raw.githubusercontent.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
ENV PATH /home/ubuntu/.rbenv/bin:/home/ubuntu/.rbenv/shims:$PATH
RUN rbenv install 2.2.3 && rbenv global 2.2.3
RUN gem install bundler rails

# Postgresql 9.3 already installed
USER postgres
RUN service postgresql start && psql --command "CREATE ROLE ubuntu login createdb; UPDATE pg_database SET datistemplate = FALSE WHERE datname = 'template1';"
RUN service postgresql start && psql --command "DROP DATABASE template1;"
RUN service postgresql start && psql --command "CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UNICODE';"
RUN service postgresql start && psql --command "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template1';"

# Default workspace
USER root
RUN locale-gen en_US.UTF-8
ADD ./files/workspace /home/ubuntu/workspace

# User rights
RUN chmod -R g+w /home/ubuntu && chown -R ubuntu:ubuntu /home/ubuntu
RUN chmod -R g-w /home/ubuntu/lib && chown -R root:root /home/ubuntu/lib

# Pre-download rails dependencies
USER ubuntu
RUN rails new -T --database=postgresql to-be-removed
RUN rm -rf to-be-removed

# Zsh by default on bash startup
RUN echo "zsh" >> .bashrc