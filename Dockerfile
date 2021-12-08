FROM ubuntu:focal
ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -yq && \
    apt-get upgrade -yq && \
    apt-get install -yq --no-install-suggests --no-install-recommends \
        ocaml \
        menhir \
        llvm-11 \
        llvm-11-dev \
        m4 \
        git \
        aspcud \
        ca-certificates \
        python2.7 \
        pkg-config \
        cmake \
        opam && \
    ln -s /usr/bin/lli-11 /usr/bin/lli && \
    ln -s /usr/bin/llc-11 /usr/bin/llc

RUN opam init --auto-setup --yes --disable-sandboxing

WORKDIR '/pocaml'
COPY ./pocaml.opam .
RUN opam install . --deps-only --yes

WORKDIR '/home/pocaml'

ENTRYPOINT ["opam", "config", "exec", "--"]

CMD ["bash"]
