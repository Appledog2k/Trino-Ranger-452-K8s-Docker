FROM phusion/baseimage:jammy-1.0.4

ENV TZ=Asia/Ho_Chi_Minh
ENV RANGER_VERSION=2.4.0
ENV TAR_FILE=ranger-${RANGER_VERSION}-admin.tar.gz
ENV DOWNLOAD_URL=https://github.com/gympass/apache-ranger/releases/download/plugin-trino-452/${TAR_FILE}

COPY install.properties /root/ranger-admin/install.properties
COPY requirement.txt /root/ranger-admin/requirement.txt
COPY trino_service_setup.py /root/ranger-admin/trino_service_setup.py
COPY trino-service.json /root/ranger-admin/trino-service.json

# Set the timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages and set up Azul Zulu OpenJDK repository
RUN apt-get update && apt-get install -y \
    dos2unix \
    ca-certificates \
    curl \
    sudo \
    wget \
    bc \
    apt-transport-https \
    gnupg \
    python-is-python3 \
    python3-venv && \
    curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" > /etc/apt/sources.list.d/zulu.list && \
    apt-get update && apt-get install -y zulu11-jdk && \
    apt-get clean

ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME=/usr/lib/jvm/zulu11

WORKDIR /root

# Download and extract Ranger Admin
RUN wget -O /root/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.23.jar && \
    wget $DOWNLOAD_URL -O $TAR_FILE && \
    tar xvf ranger-${RANGER_VERSION}-admin.tar.gz && \
    cd /root/ranger-${RANGER_VERSION}-admin/ && \
    cp /root/ranger-admin/install.properties /root/ranger-${RANGER_VERSION}-admin/ && \
    find /root -type f -exec dos2unix {} \;

# Entry point
COPY entrypoint.sh /root/ranger-admin/entrypoint.sh

RUN chmod +x /root/ranger-admin/entrypoint.sh

EXPOSE 6080

ENTRYPOINT ["/root/ranger-admin/entrypoint.sh"]

