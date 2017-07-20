FROM drujensen/crystal:0.23.1

ADD . /app/user
WORKDIR /app/user

RUN crystal deps

CMD ["crystal", "spec"]
