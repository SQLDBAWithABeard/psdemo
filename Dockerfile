FROM microsoft/dotnet:2-runtime-jessie

WORKDIR /temp
COPY ./powershell_6.0.0-beta.9-1.debian.8_amd64.deb .
COPY ./get-database.ps1 .
COPY ./get-smocore.ps1 .
RUN apt-get update && apt-get install -y \
    libcurl3 \
    libgssapi-krb5-2 \
    liblttng-ust0 \
    libunwind8 \
    libssl1.0.0 \
    nano \
    && dpkg -i powershell_6.0.0-beta.9-1.debian.8_amd64.deb \
    && apt-get install -f \
    && apt-get clean \
    pwsh ./get-smocore.ps1 \
    && rm ./powershell_6.0.0-beta.9-1.debian.8_amd64.deb