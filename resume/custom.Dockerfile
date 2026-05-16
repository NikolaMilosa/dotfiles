FROM debian:bookworm

RUN apt-get update && apt-get install -y \
      texlive-luatex \
      texlive-latex-recommended \
      texlive-latex-extra \
      texlive-fonts-recommended \
      texlive-fonts-extra \
      fontconfig \
    fonts-crosextra-carlito \
    make \
    inotify-tools

RUN mktexlsr
