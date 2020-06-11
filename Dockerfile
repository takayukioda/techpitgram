FROM ruby:2.5.1
# FROM ruby:2.6.6
# FROM ruby:2.7.1
MAINTAINER takayukioda
EXPOSE 3000

RUN apt-get update && \
	apt-get install -y \
		vim \
		sqlite3 \
		sudo

ENV NODE_VERSION=12.18
COPY --from=node:12.18-slim /usr/local/bin /usr/local/nodejs/bin
COPY --from=node:12.18-slim /usr/local/share /usr/local/nodejs/share
COPY --from=node:12.18-slim /usr/local/lib /usr/local/nodejs/lib
COPY --from=node:12.18-slim /usr/local/include /usr/local/nodejs/include
COPY --from=node:12.18-slim /opt/yarn-v1.22.4 /opt/yarn-v1.22.4
RUN ln -s /usr/local/nodejs/bin/* /usr/local/bin/.

ENV USER rubyist
RUN useradd -m ${USER} && \
	gpasswd -a ${USER} sudo && \
	echo "${USER}:password" | chpasswd

# Work directory created by docker cannot change the owner; create work directory and change owner in code
ENV WORKDIR /workspace
RUN mkdir -p ${WORKDIR} && \
	chown ${USER} ${WORKDIR}

USER ${USER}
WORKDIR ${WORKDIR}

ENV RAILS_ENV=development
ENTRYPOINT bundle install && \
	rails yarn:install && \
	rails db:migrate && \
	bash

