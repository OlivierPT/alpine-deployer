FROM amazonlinux:2

ARG user=deployer
ARG group=deployer
ARG uid=1000
ARG gid=1000
ARG DEPLOYER_HOME=/home/deployer

ENV SERVERLESS_VERSION="1.73.1"

RUN yum update -y && \
    yum install -y \
    shadow-utils \
    curl \
    python3 \
    build-base \
    jq \
    unzip \
    tar \
    gzip \
    wget

RUN yum update -y && \
    yum install -y shadow-utils git python3-pip && \
    curl -sL https://rpm.nodesource.com/setup_12.x | bash && \
    yum install -y nodejs zip unzip jq curl parallel

# Install AWS CLI2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install serverless
RUN npm install serverless@$SERVERLESS_VERSION -g

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 777 /usr/local/bin/entrypoint.sh

# deployer is run with user `deployr`, uid = 1000
RUN groupadd --gid ${gid} ${group}  \
    && adduser --home "$DEPLOYER_HOME" --uid ${uid} --gid ${group} --shell /bin/bash ${user}

COPY bin $DEPLOYER_HOME/bin
COPY npm/.npmrc $DEPLOYER_HOME/.npmrc

RUN chown -R ${uid}:${gid} $DEPLOYER_HOME

USER ${user}

# INSTALL AWS-SSM-ENV
RUN wget -O $DEPLOYER_HOME/bin/aws-ssm-env.zip \
    https://github.com/piotrb/aws-ssm-env/releases/download/v1.2.0/aws-ssm-env-v1.2.0-linux-amd64.zip && \
    unzip -d $DEPLOYER_HOME/bin $DEPLOYER_HOME/bin/aws-ssm-env.zip && \
    chmod 755 $DEPLOYER_HOME/bin/aws-ssm-env && \
    rm $DEPLOYER_HOME/bin/aws-ssm-env.zip

# INSTALL SIGIL
RUN curl -L "https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_$(uname -sm|tr \  _).tgz" \
    | tar -zxC $DEPLOYER_HOME/bin

RUN python3 --version
RUN pip3 --version
RUN node --version
RUN npm --version
RUN aws --version
RUN sls --version

USER ${user}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/bin/bash"]