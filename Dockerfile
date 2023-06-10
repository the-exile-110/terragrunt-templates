FROM hashicorp/terraform:1.4.6

# apk
RUN apk add --update --no-cache git openssl bash zsh bat exa curl gcompat zip jq yq

# aws-cli v2
ENV AWS_CLI_VERSION=2.0.30
RUN curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip -o awscliv2.zip && \
    unzip awscliv2.zip && ./aws/install

# kubectl
ENV KUBECTL_VERSION=v1.23.6
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

# eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin/eksctl

# helm
RUN curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

# zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -p git -p z -p command-not-found -p colorize -p kubectl \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# terragrunt
ARG TERRAGRUNT_VERSION=v0.46.3
ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt
RUN chmod +x /usr/local/bin/terragrunt

WORKDIR /apps

ENTRYPOINT []