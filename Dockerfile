ARG BASE_VERSION
FROM postgres:${BASE_VERSION}

RUN apk add --no-cache build-base git clang llvm lld

RUN git clone --depth=1 https://github.com/citusdata/pg_cron /tmp/pg_cron && \
    make -C /tmp/pg_cron \
      CLANG="$(command -v clang)" \
      LLVM_CONFIG="$(command -v llvm-config)" \
      LLVM_AR="$(command -v llvm-ar)" \
      LLVM_RANLIB="$(command -v llvm-ranlib)" \
      LLVM_LTO="$(command -v llvm-lto)" && \
    make -C /tmp/pg_cron install && \
    rm -rf /tmp/pg_cron

RUN echo "shared_preload_libraries = 'pg_cron'" >> /usr/local/share/postgresql/postgresql.conf.sample
