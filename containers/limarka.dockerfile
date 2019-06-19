FROM ruby-latex-pandoc

RUN gem install limarka

VOLUME ["/trabalho"]
WORKDIR /trabalho

CMD ["--help"]
ENTRYPOINT ["/usr/local/bundle/bin/limarka"]
