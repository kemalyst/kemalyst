FROM drujensen/crystal:0.20.1

ADD . /app/user
WORKDIR /app/user

RUN crystal deps

CMD ["crystal", "spec"]
