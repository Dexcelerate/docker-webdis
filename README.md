## Running Redis Servers
    3611 //webserver
    27170 //mongodb
    5432 //postgres
    7000 //local redis through nginx proxy
    7001 //webdis redis through nginx proxy


## Running Redis Servers

These will need to be configured to run as a cluster, but for now in testing/staging we will just run all 3 on the same machine with Docker:

```shell
docker run -d --restart=always --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 --net redis --name redis -p 127.0.0.1:6379:6379 redis
docker run -d --restart=always --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 --net redis --name redis0 -p 127.0.0.1:7000:6379 redis
docker run -d --restart=always --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 --net redis --name redis1 -p 127.0.0.1:7001:6379 redis
docker run -d --restart=always --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 --net redis --name redis2 -p 127.0.0.1:7002:6379 redis
```

## Running webdis API

First build the webdis docker image:

```shell
docker build --rm -t webdis https://github.com/freaker2k7/docker-webdis.git
```

Then run the container:

```shell
docker run -d -p 7379:7379 -p 3788:6379 --name webdis -e LOCAL_REDIS=true webdis
```


After it is running attach to redis-cli inside of it `docker exec -it webdis redis-cli` in order to run the following redis commands:

```redis-cli
ZADD BSC 1 web-server-0.jewbot.trade
```
```redis-cli
FUNCTION LOAD REPLACE "#!lua name=ratelimit\n redis.register_function('rate', function(b,c)local d=3;local e=1;local g=b[1]local h=redis.call('GET',g)if not h then redis.call('SETEX',g,e,1)else h=tonumber(h)if h<d then redis.call('SETEX',g,e,h+1)else if h==d then local i=redis.call('GET','S:'..g)redis.call('EXPIRE','S:'..g,-1)end;if h<8 then redis.call('SETEX',g,math.floor(e*1.6^h),h+1)end;return nil end end;local i=redis.call('GET','S:'..g)if not i or not redis.call('ZSCORE',c[1],i)then local j=math.fmod(redis.call('INCR','IPRR'),redis.call('ZCOUNT',c[1],'-inf','+inf'))i=redis.call('ZRANGE',c[1],j,j)redis.call('SETEX','S:'..g,1200,i[1])return i[1]end;return i end)"
```



[![Docker Pulls](https://img.shields.io/docker/pulls/anapsix/webdis)](https://hub.docker.com/r/anapsix/webdis/)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/anapsix/webdis/latest)
![linux/amd64](https://img.shields.io/badge/platform-linux%2Famd64-blue)
![linux/arm64](https://img.shields.io/badge/platform-linux%2Farm64-blue)

[Webdis](http://webd.is) (by Nicolas Favre-Félix) is a simple HTTP server which
forwards commands to Redis and sends the reply back using a format of your
choice. Accessing `/COMMAND/arg0/arg1/.../argN[.ext]` on Webdis executes the
command on Redis and returns the response; the reply format can be changed with
the optional extension (.json, .txt…).

Webdis implements ACL by IP/CIDR, by HTTP Auth or both with list of explicitly allowed or disallowed commands a client may use.

Documentation is available at author's site: [http://webd.is/#http](http://webd.is/#http).

## Build

Build as per usual

    docker build -t webdis .

Build a multi-arch image

    # you might need to create a multiarch builder
    docker buildx create --name multiarch --bootstrap --platform linux/arm64,linux/amd64

    # build using buildx, specifying all the platforms you want to build for
    docker buildx build --builder multiarch --platform linux/arm64,linux/amd64 -t webdis .

## Usage

Start all-in-one (includes Redis):

    docker run -d -p 7379:7379 -e LOCAL_REDIS=true anapsix/webdis

Link redis container manually and run:

    docker run -d --name r4w redis
    docker run -d -p 7379:7379 --link r4w:redis anapsix/webdis

Use external redis server:

    docker run -d -p 7379:7379 -e REDIS_HOST=redis-server-host anapsix/webdis

Use Docker Compose:

    docker-compose up

Try accessing it with curl:

* directly:

        curl http://127.0.0.1:7379/SET/hello/world
        curl http://127.0.0.1:7379/GET/hello

* or via haproxy:

        curl http://127.0.0.1:8080/SET/hello/world
        curl http://127.0.0.1:8080/GET/hello

## Known Issues

See https://github.com/nicolasff/webdis/issues
