FROM ruby:2.0
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

COPY . /usr/src/app
COPY config/postgresql/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf

USER postgres
RUN mkdir -p ~/pgsql/data
RUN /usr/lib/postgresql/9.4/bin/initdb -D ~/pgsql/data

USER root
RUN service postgresql start &&\
  rake setup &&\
  RAILS_ENV=production rake db:create &&\
  RAILS_ENV=production rake db:migrate

EXPOSE 3000
CMD service postgresql start && rails server -e production -p 3000 &> projectmonitor.log && rake start_workers
