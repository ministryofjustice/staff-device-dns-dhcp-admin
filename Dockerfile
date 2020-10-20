FROM ruby:2.7.1-alpine3.12

ARG RACK_ENV=development
ARG DB_HOST=db
ARG DB_USER=root
ARG DB_PASS=root
ARG SECRET_KEY_BASE="fakekeybase"
ARG DB_NAME=root
ARG BUNDLE_WITHOUT=""
ARG BUNDLE_INSTALL_FLAGS=""

# required for certain linting tools that read files, such as erb-lint
ENV LANG='C.UTF-8' \
  RACK_ENV=${RACK_ENV} \
  DB_HOST=${DB_HOST} \
  DB_USER=${DB_USER} \
  DB_PASS=${DB_PASS} \
  SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  KEA_CONFIG_BUCKET='testbucket' \
  BIND_CONFIG_BUCKET='testbuckettwo' \
  AWS_DEFAULT_REGION='eu-west-2' \
  DB_NAME=${DB_NAME}

WORKDIR /usr/src/app

ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem /usr/src/cert/

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache nodejs yarn mysql-dev mysql-client bash make

COPY Gemfile Gemfile.lock .ruby-version ./
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

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
