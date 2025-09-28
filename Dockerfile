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
    zlib1g-dev \
    libpixman-1-dev \
    libfltk1.3-dev \
    libjpeg62-turbo-dev \
    libgnutls28-dev \
    && rm -rf /var/lib/apt/lists/*

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
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Копируем собранные бинарники
COPY --from=builder /opt/tigervnc /opt/tigervnc

# Добавляем в PATH
ENV PATH="/opt/tigervnc/bin:${PATH}"

# Проверяем что все работает
CMD ["vncviewer", "--version"]