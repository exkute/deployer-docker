FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && apt upgrade -y && \
    apt install --no-install-recommends -y \
        curl \
        gpg \
        openssh-client \
        gpg-agent \
        ca-certificates \
        git \
        jq \
        git-crypt \
        sudo && \
    sed -i 's/^%sudo.*/%sudo ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers && \    
    export CLOUD_SDK_REPO="cloud-sdk-stretch main" && \
    export APT_GOOGLE_CLOUD_SDK_FILE="/etc/apt/sources.list.d/google-cloud-sdk.list" && \
    export APT_KUBERNETES_FILE="/etc/apt/sources.list.d/kubernetes.list" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO" | tee -a "$APT_GOOGLE_CLOUD_SDK_FILE" && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a "$APT_KUBERNETES_FILE" && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \    
    apt update -y && apt-get install -y --no-install-recommends google-cloud-sdk kubectl=1.11.2-00  && \
    curl -s -L "https://github.com/kubernetes-sigs/kustomize/releases/download/v1.0.6/kustomize_1.0.6_linux_amd64" > /usr/bin/kustomize && \
    curl -L -o kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.5.4/kustomize_v3.5.4_linux_amd64.tar.gz" && \
    tar xvzf kustomize.tar.gz && mv kustomize /usr/bin/kustomize354 && \
    chmod +x /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize354 && \
    gcloud version && kubectl version --client && /usr/bin/kustomize version && /usr/bin/kustomize354 version && \
    addgroup deployer && \
    adduser deployer --disabled-password --gecos '' --ingroup 'deployer' && \
    adduser deployer sudo && \
    mkdir -p /home/deployer/.ssh && \
    rm -rf /var/lib/apt/lists/*

COPY ssh_config /home/deployer/.ssh/config
RUN chown -R deployer:deployer /home/deployer/.ssh && \
    chmod 600 /home/deployer/.ssh/config

USER deployer
WORKDIR /home/deployer
CMD ["/usr/bin/kustomize"]
