FROM mcr.microsoft.com/dotnet/sdk:7.0

LABEL maintainer="Edwin Hagen"

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install --no-install-recommends git procps lsb-release \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Trusted && \
    pwsh -Command Install-Module -Name Az -Scope AllUsers -Repository PSGallery && \
    pwsh -Command Install-Module -Name Az.ResourceGraph -Scope AllUsers -Repository PSGallery && \
    pwsh -Command Install-Module -Name Pester -Scope AllUsers -Repository PSGallery && \
    pwsh -Command Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted

CMD [ "pwsh" ]