FROM debian:buster

RUN apt update -y && apt upgrade -y && \
    apt install --no-install-recommends -y \
        curl \
        gpg \
        gpg-agent \
        ca-certificates \
	    git-crypt && \
    export CLOUD_SDK_REPO="cloud-sdk-stretch main" && \
    export APT_GOOGLE_CLOUD_SDK_FILE="/etc/apt/sources.list.d/google-cloud-sdk.list" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO" | tee -a "$APT_GOOGLE_CLOUD_SDK_FILE" && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt update -y && apt-get install google-cloud-sdk kubectl -y --no-install-recommends && \
    curl -s -L "https://github.com/kubernetes-sigs/kustomize/releases/download/v1.0.2/kustomize_1.0.2_linux_amd64" > /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    gcloud version && kubectl version --client && /usr/bin/kustomize version && \
    addgroup deployer && \
    adduser deployer --disabled-password --gecos '' --ingroup deployer && \
    rm -rf /var/lib/apt/lists/*

USER deployer
WORKDIR /home/deployer
CMD ["/usr/bin/kustomize"]
