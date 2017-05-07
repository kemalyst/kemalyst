FROM drujensen/crystal:0.22.0-1

ADD . /app/user
WORKDIR /app/user

RUN crystal deps

CMD ["crystal", "spec"]
