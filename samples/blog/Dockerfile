# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Dru Jensen

# Update the repository sources list
RUN apt-get update

# Add Crystal repository to sources
RUN curl http://dist.crystal-lang.org/apt/setup.sh | sudo bash
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
RUN echo "deb http://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list

# Install Dependencies
RUN apt-get update && apt-get install -y \ 
  build-essential \
  libyaml-0-2 \
  libpq-dev \
  libssl-dev \
  git \
  crystal

RUN mkdir -p /webapps/demo
ADD . /webapps/demo
WORKDIR /webapps/demo

RUN shards update

EXPOSE 3000
CMD ["crystal", "src/app.cr"]
