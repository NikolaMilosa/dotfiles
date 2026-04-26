FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    texlive-xetex \
    texlive-latex-extra \
    texlive-fonts-extra \
    fonts-crosextra-carlito

RUN mktexlsr
