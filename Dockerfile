# FastQC
FROM alpine:latest as fastqc
WORKDIR /build
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip && \
    unzip fastqc_v0.11.5.zip


# HMMER
FROM alpine:latest as hmmer
WORKDIR /build
RUN apk update && apk add build-base linux-headers
RUN wget http://eddylab.org/software/hmmer/hmmer-3.2.1.tar.gz && \
    tar -xf hmmer-3.2.1.tar.gz && \
    cd hmmer-3.2.1 && \
    ./configure --prefix /build/hmmer && \
    make && \
    make install


# Bowtie2
FROM alpine:latest as bowtie
WORKDIR /build
RUN wget https://github.com/BenLangmead/bowtie2/releases/download/v2.3.2/bowtie2-2.3.2-legacy-linux-x86_64.zip && \
    unzip bowtie2-2.3.2-legacy-linux-x86_64.zip && \
    mkdir bowtie2 && \
    cp bowtie2-2.3.2-legacy/bowtie2* bowtie2

# SPAdes
FROM alpine:latest as spades
WORKDIR /build
RUN wget https://github.com/ablab/spades/releases/download/v3.11.0/SPAdes-3.11.0-Linux.tar.gz && \
    tar -xvf SPAdes-3.11.0-Linux.tar.gz && \
    mv SPAdes-3.11.0-Linux.tar.gz spades

# Skewer
FROM alpine:latest as skewer
WORKDIR /build
RUN apk update && apk add build-base linux-headers
RUN wget https://github.com/relipmoc/skewer/archive/0.2.2.tar.gz && \
    tar -xf 0.2.2.tar.gz && \
    cd skewer-0.2.2 && \
    make

# Build
FROM python:3.6-jessie
COPY --from=fastqc /build/FastQC /opt/fastqc
COPY --from=hmmer /build/hmmer /opt/hmmer
COPY --from=bowtie /build/bowtie2/* /usr/local/bin/
COPY --from=spades /build/spades /opt/
COPY --from=skewer /build/skewer-0.2.2/skewer /usr/local/bin
RUN chmod ugo+x /opt/fastqc/fastqc && \
    ln -fs /opt/spades/bin/spades.py /usr/local/bin/spades.py && \
    ln -fs /opt/fastqc/fastqc /usr/local/bin/fastqc && \
    for file in `ls /opt/hmmer/bin`; do ln -fs /opt/hmmer/bin/${file} /usr/local/bin/${file}; done
CMD ["python3"]

