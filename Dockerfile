FROM alpine:3.8

ARG user=deployer
ARG group=deployer
ARG uid=1000
ARG gid=1000
ARG DEPLOYER_HOME=/home/deployer

ENV OPENSSH_VERSION="7.7_p1-r3"\
    GIT_VERSION="2.18.1-r0" \
    NODE_VERSION="8.11.4-r0" \
    NPM_VERSION="6.1.0" \
    SERVERLESS_VERSION="1.38.0" \
    PYTHON3_VERSION="3.6.6-r0" \
    PYTHON2_VERSION="2.7.15-r1"

RUN apk add --no-cache nodejs npm terraform

RUN apk add --update \
    curl \
    python \
    python-dev \
    py-pip \
    build-base \
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
RUN npm --version
RUN terraform --version
RUN aws --version
RUN sls --version

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/bin/sh"]