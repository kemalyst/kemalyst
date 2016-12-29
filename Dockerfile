FROM drujensen/crystal:0.20.3

ADD . /app/user
WORKDIR /app/user

RUN crystal deps

CMD ["crystal", "spec"]
