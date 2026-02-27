FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    PATH="/usr/lib/jvm/java-17-openjdk-amd64/bin:${PATH}"

# Install all OS dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    unzip \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Python tools
RUN pip3 install --no-cache-dir yamllint

# Install all binary tools in a single layer to reduce layer count
RUN set -eux; \
    # kubeconform
    curl -fsSL https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz \
        | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/kubeconform; \
    \
    # kustomize
    curl -fsSL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash \
    && mv kustomize /usr/local/bin/; \
    \
    # gitleaks
    GITLEAKS_VERSION=$(curl -fsSL https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
        | grep '"tag_name"' | cut -d'"' -f4 | tr -d v) \
    && curl -fsSL "https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
        | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/gitleaks; \
    \
    # kube-linter
    curl -fsSL https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux \
        -o /usr/local/bin/kube-linter \
    && chmod +x /usr/local/bin/kube-linter

# Verify all tools in one layer
RUN yamllint --version \
    && kubeconform -v \
    && kustomize version \
    && gitleaks version \
    && kube-linter version \
    && java -version

RUN mkdir -p /home/jenkins && chmod 777 /home/jenkins

WORKDIR /workspace

CMD ["/bin/bash"]