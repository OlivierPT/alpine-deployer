FROM alpine:edge

ARG user=deployer
ARG group=deployer
ARG uid=1000
ARG gid=1000
ARG DEPLOYER_HOME=/home/deployer

ENV SERVERLESS_VERSION="1.73.1"

RUN apk add --update \
    curl \
    python \
    python3 \
    python-dev \
    py-pip \
    build-base \
    jq \
    nodejs \
    npm \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

RUN pip install --upgrade pip

# deployer is run with user `deployr`, uid = 1000
RUN mkdir -p $DEPLOYER_HOME \
    && chown ${uid}:${gid} $DEPLOYER_HOME \
    && addgroup -g ${gid} ${group} \
    && adduser -h "$DEPLOYER_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user}

RUN npm install serverless@$SERVERLESS_VERSION -g
RUN pip install awscli --upgrade

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 777 /usr/local/bin/entrypoint.sh

COPY bin $DEPLOYER_HOME/bin

COPY npm/.npmrc $DEPLOYER_HOME/

# INSTALL AWS-SSM-ENV
RUN wget -O $DEPLOYER_HOME/bin/aws-ssm-env.zip \
    https://github.com/piotrb/aws-ssm-env/releases/download/v1.2.0/aws-ssm-env-v1.2.0-linux-amd64.zip && \
    unzip -d $DEPLOYER_HOME/bin $DEPLOYER_HOME/bin/aws-ssm-env.zip && \
    chmod 755 $DEPLOYER_HOME/bin/aws-ssm-env && \
    rm $DEPLOYER_HOME/bin/aws-ssm-env.zip

# INSTALL SIGIL
RUN curl -L "https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_$(uname -sm|tr \  _).tgz" \
    | tar -zxC $DEPLOYER_HOME/bin

RUN echo "export PATH=$PATH:$DEPLOYER_HOME/bin" >> $DEPLOYER_HOME/.profile
RUN chown -R ${uid}:${gid} $DEPLOYER_HOME

USER ${user}

RUN python --version
RUN pip --version
RUN node --version
RUN npm --version
RUN aws --version
RUN sls --version

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/bin/sh"]