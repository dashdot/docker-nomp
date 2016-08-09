FROM node:0.10.46
MAINTAINER Holger Schinzel <holger@dash.org>

RUN apt-get update && apt-get install vim -y

RUN useradd --user-group --create-home --shell /bin/false app &&\
  npm install --global npm@3.10.5

ENV HOME=/home/app

COPY package.json $HOME/unomp/
RUN chown -R app:app $HOME/*

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER app
WORKDIR $HOME/unomp
RUN npm update

USER root
COPY . $HOME/unomp
RUN chown -R app:app $HOME/*
USER app

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "init.js"]