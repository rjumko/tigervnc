# Dockerfile для сборки TigerVNC Viewer
FROM debian:bullseye-slim AS builder

# Установка переменных окружения
ENV TIGERVNC_VERSION=1.13.1

# Установка зависимостей для сборки
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    wget \
    ca-certificates \
    # Основные зависимости TigerVNC
    zlib1g-dev \
    libpixman-1-dev \
    libfltk1.3-dev \
    libjpeg62-turbo-dev \
    libgnutls28-dev \
    libnettle-dev \
    libhogweed-dev \
    # PAM библиотеки (исправляют ошибку)
    libpam0g-dev \
    # Дополнительные зависимости для полной сборки
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxdamage-dev \
    libxinerama-dev \
    libxtst-dev \
    libxcomposite-dev \
    libfontenc-dev \
    libxkbfile-dev \
    # Gettext для NLS
    gettext \
    libgettextpo-dev
    # Systemd (опционально)
    # libsystemd-dev \
    # && rm -rf /var/lib/apt/lists/*
    
# Клонирование и сборка TigerVNC
WORKDIR /tmp
RUN git clone https://github.com/TigerVNC/tigervnc.git \
    && cd tigervnc \
    && git checkout v${TIGERVNC_VERSION}

WORKDIR /tmp/build
RUN cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/tigervnc \
    ../tigervnc

RUN make -j$(nproc) && make install

# Финальный образ
FROM debian:bullseye-slim

# Установка runtime зависимостей
RUN apt-get update && apt-get install -y \
    libfltk1.3 \
    libgnutls30 \
    libjpeg62-turbo \
    libpixman-1-0 \
    zlib1g \
    libnettle8 \
    libhogweed6 \
    libpam0g \
    libx11-6 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxcursor1 \
    libxdamage1 \
    libxinerama1 \
    libxtst6 \
    libxcomposite1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Копируем собранные бинарники
COPY --from=builder /opt/tigervnc /opt/tigervnc

# Добавляем в PATH
ENV PATH="/opt/tigervnc/bin:${PATH}"

# Проверяем что все работает
CMD ["vncviewer", "--version"]