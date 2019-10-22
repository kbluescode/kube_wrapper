FROM ruby:2.6-alpine
MAINTAINER Kevin Blues <kevin@thinkific.com>

RUN apk update && apk add --no-cache \
  bash \
  dumb-init \
  gcc \
  git \
  libc-dev \
  make
RUN gem install bundler -v '~> 1'
WORKDIR /root
COPY . /root
RUN bundle
CMD dumb-init tail -f /dev/null