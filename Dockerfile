FROM ruby:3.3.6-alpine3.19

ARG UID=1001
ARG GROUP=app
ARG USER=app
ARG HOME=/home/$USER
ARG APPDIR=$HOME/staff-device-dns-dhcp-admin
ARG CERTDIR=$HOME/cert

ARG RACK_ENV=development
ARG DB_HOST=admin-db
ARG DB_USER=root
ARG DB_PASS=root
ARG SECRET_KEY_BASE="fakekeybase"
ARG DB_NAME=root
ARG BUNDLE_WITHOUT=""
ARG BUNDLE_INSTALL_FLAGS=""
ARG RUN_PRECOMPILATION=true
ARG BUILD_DEV

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

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache nodejs yarn mysql-dev mysql-client bash make bind shadow

RUN if [ "${BUILD_DEV}" = "true" ] ; then \
    apk add --no-cache alpine-sdk ruby-dev; \
  fi

RUN groupadd -g $UID -o $GROUP && \
  useradd -m -u $UID -g $UID -o -s /bin/false $USER && \
  mkdir -p $APPDIR && \
  mkdir -p $CERTDIR && \
  chown -R $USER:$GROUP $HOME

USER $USER
WORKDIR $APPDIR

COPY --chown=$USER:$GROUP Gemfile Gemfile.lock .ruby-version ./
RUN bundle config set no-cache 'true' && \
  bundle install ${BUNDLE_INSTALL_FLAGS}

COPY --chown=$USER:$GROUP  package.json yarn.lock ./
RUN yarn && yarn cache clean

COPY --chown=$USER:$GROUP . $APPDIR

RUN curl -o $CERTDIR/eu-west-2-bundle.pem https://truststore.pki.rds.amazonaws.com/eu-west-2/eu-west-2-bundle.pem

USER root
RUN chown -R $USER:$GROUP $CERTDIR &&\
  chown -R $USER:$GROUP /var/bind &&\
  apk del .build-deps
USER $USER

RUN if [ ${RUN_PRECOMPILATION} = 'true' ]; then \
  ASSET_PRECOMPILATION_ONLY=true RAILS_ENV=production bundle exec rails assets:precompile; \
  fi

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
