FROM ubuntu:18.04
MAINTAINER SRE support <sre.support@samsung.com>
USER root
RUN apt-get -y update
RUN apt-get -y install ruby ruby-dev build-essential git curl
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
RUN ln -s ~/.tfenv/bin/* /usr/local/bin
RUN tfenv install 0.12.9
RUN tfenv install 0.11.14
RUN tfenv use 0.12.9
RUN mkdir -p ~/.terraform.d/plugin-cache
RUN echo 'plugin_cache_dir = "/root/.terraform.d/plugin-cache"' >> ~/.terraformrc
RUN mkdir ~/init
RUN echo 'provider "aws" { version = ">= 1.15.0" }' > ~/init/provider.tf
WORKDIR "/root/init"
RUN terraform init
WORKDIR "/root"
RUN gem install bundler --version 2.0.2 --no-rdoc --no-ri
RUN gem install test-kitchen --version 2.3.3 --no-rdoc --no-ri
RUN gem install kitchen-terraform --version 5.1.1 --no-rdoc --no-ri
RUN gem install awspec --version 1.18.1 --no-rdoc --no-ri
RUN gem install kitchen-verifier-awspec --version 0.2.0 --no-rdoc --no-ri
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
