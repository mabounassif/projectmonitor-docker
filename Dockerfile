FROM phusion/passenger-ruby20
MAINTAINER Mahmoud Nassif, <contact@mahmoud.ca>

RUN apt-get update && apt-get install -y \
    git \
    libxml2-dev \
    build-essential \
    make \
    gcc \
    postgresql \
    postgresql-contrib

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without development test
RUN gem install whenever
RUN gem install foreman

COPY . /usr/src/app
COPY config/postgresql/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf

USER postgres
RUN mkdir -p ~/pgsql/data
RUN /usr/lib/postgresql/9.3/bin/initdb -D ~/pgsql/data

USER root
RUN service postgresql start &&\
  bundle exec rake setup &&\
  RAILS_ENV=production bundle exec rake db:create &&\
  RAILS_ENV=production bundle exec rake db:migrate

RUN wheneverize .
RUN whenever > /usr/src/app/crontab.conf
RUN crontab /usr/src/app/crontab.conf
RUN cron

EXPOSE 3000
CMD service postgresql start && PORT=3000 RAILS_ENV=production foreman start
