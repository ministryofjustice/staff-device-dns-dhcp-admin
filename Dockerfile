FROM ruby:2.7.1-alpine3.12
ARG BUNDLE_INSTALL_CMD

# required for certain linting tools that read files, such as erb-lint
ENV LANG='C.UTF-8'

ARG RACK_ENV=development 
ARG DB_HOST=db
ARG DB_USER=root
ARG DB_PASS=root
ARG SECRET_KEY_BASE="fakekeybase"

WORKDIR /usr/src/app

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache nodejs yarn mysql-dev bash

COPY Gemfile Gemfile.lock .ruby-version ./
ARG BUNDLE_INSTALL_FLAGS
RUN bundle config set no-cache 'true' && \ 
  bundle install ${BUNDLE_INSTALL_FLAGS}

COPY package.json yarn.lock ./
RUN yarn && yarn cache clean

RUN apk del .build-deps

COPY . .

ARG RUN_PRECOMPILATION=true
RUN if [ ${RUN_PRECOMPILATION} = 'true' ]; then \
  ASSET_PRECOMPILATION_ONLY=true RAILS_ENV=production bundle exec rails assets:precompile; \
  fi
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]  
