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

# deployer is run with user `deployr`, uid = 1000
RUN groupadd --gid ${gid} ${group}  \
    && adduser --home "$DEPLOYER_HOME" --uid ${uid} --gid ${group} --shell /bin/bash ${user}

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 777 /usr/local/bin/entrypoint.sh

COPY bin $DEPLOYER_HOME/bin

RUN echo "export PATH=$PATH:$DEPLOYER_HOME/bin:$DEPLOYER_HOME/.local/bin" >> $DEPLOYER_HOME/.bashrc
RUN chown -R ${uid}:${gid} $DEPLOYER_HOME

USER ${user}

RUN cd /tmp \
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py --user 

# Install nodejs
RUN cd /tmp \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && . ~/.nvm/nvm.sh \
    && nvm install --lts \
    && npm install serverless@$SERVERLESS_VERSION -g

# INSTALL AWS-SSM-ENV
RUN wget -O $DEPLOYER_HOME/bin/aws-ssm-env.zip \
    https://github.com/piotrb/aws-ssm-env/releases/download/v1.2.0/aws-ssm-env-v1.2.0-linux-amd64.zip && \
    unzip -d $DEPLOYER_HOME/bin $DEPLOYER_HOME/bin/aws-ssm-env.zip && \
    chmod 755 $DEPLOYER_HOME/bin/aws-ssm-env && \
    rm $DEPLOYER_HOME/bin/aws-ssm-env.zip

# INSTALL SIGIL
RUN curl -L "https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_$(uname -sm|tr \  _).tgz" \
    | tar -zxC $DEPLOYER_HOME/bin

RUN rm /tmp/*

RUN python3 --version
# RUN pip --version
# RUN nodejs --version
# RUN npm --version
RUN aws --version
# RUN sls --version

USER root
RUN chown -R ${user}:${group} $DEPLOYER_HOME
USER ${user}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["/bin/bash"]