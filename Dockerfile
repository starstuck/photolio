FROM debian:wheezy
MAINTAINER szarsti <szarsti@gmail.com>
LABEL Vendor="Szarsti.net" Version="1.2.0"

ENV RUBY_VERSION 1.9.3
ENV RAILS_GEM_VERSION 2.3.18
ENV PHOTOLIO_VERSION 1.2.0-rc1
ENV RUBY_ENV production

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y build-essential curl ruby1.9.3 ruby-dev rake imagemagick libpq-dev \
    && apt-get clean

RUN echo "gem: --no-rdoc --no-ri" > /etc/gemrc \
    && gem install --version="${RAILS_GEM_VERSION}" rails \
    && gem install activerecord-postgresql-adapter

#RUN gem install -N
#    rails:"${RAILS_GEM_VERSION}" \
#    mini_magick:3.8.1 \
#    iconv:1.0.4 \
#    ftools \
#    activerecord-postgresql-adapter \
#    i18n-active_record \ # Required for ruby 2 compatibility

RUN curl -L "https://github.com/szarsti/photolio/archive/v${PHOTOLIO_VERSION}.tar.gz" | tar -xz -C /opt \
    && ln -s "/opt/photolio-${PHOTOLIO_VERSION}" /opt/photolio \

RUN cd /opt/photolio \
    && rake gems:install

EXPOSE 3000
VOLUME /opt/photolio/public/files

ENTRYPOINT ["/etc/dockerinit"]
CMD ["ruby", "/opt/photolio/script/server"]
