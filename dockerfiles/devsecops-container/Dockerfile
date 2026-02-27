
FROM jenkins/agent:latest

USER root

# Install tools
RUN apt update && apt install -y \
    git \
    python3 \
    python3-pip \
    nodejs npm \
    gnupg \
    ca-certificates \
    maven \
    curl wget unzip \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Snyk CLI
RUN curl -fsSL https://static.snyk.io/cli/latest/snyk-linux -o /usr/local/bin/snyk \
    && chmod +x /usr/local/bin/snyk

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
    | gpg --dearmor \
    | tee /usr/share/keyrings/trivy.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
       > /etc/apt/sources.list.d/trivy.list \
    && apt-get update \
    && apt-get install -y trivy \
    && rm -rf /var/lib/apt/lists/*

# Install Semgrep
RUN python3 -m pip install semgrep --break-system-packages

