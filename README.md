## Troubleshooting 
`EACCES: permission denied, mkdir '/app/node_modules.cache` is an ongoing [Node and Docker issue](https://github.com/nodejs/docker-node/issues/740). In summary, best practice is to NEVER run node as root as "bad things can happen". It was necessary to also be cognizant of this at the `COPY` layer when copying over `package.json` as well as the app directory using [this syntax](https://docs.docker.com/engine/reference/builder/#copy).


## Docker

if running in development, add `-f Dockerfile.dev`, otherwise it will default to `Dockerfile` for production.
```bash
docker image build -f Dockerfile.dev -t frontend-dev .
docker image build -t frontend-prod .
```

```bash
docker container run -it --rm -p 3000:3000 frontend-dev
docker container run -it --rm -p 3000:3000 frontend-prod
```

## **docker-compose**

after setting up configurations with `docker-compose.yaml`, execute command to build image
```bash
docker-compose --verbose -f docker-compose-dev.yaml build --no-cache
```

spin up container for `client` services:
```bash
docker-compose up client
```
which generates container: 
```bash
$ docker container  ps
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                       NAMES
IMAGE_ID   frontend_client   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   frontend

```

ssh onto container to address vulnerabilities returned after image build, where `client` is the name of the service given in `docker-compose.yaml`:

```bash
docker-compose exec client ash
```


after `npm install`, make note of the security vulnerabilities and audit issues:
```bash
added 1845 packages, and audited 1846 packages in 2m

139 packages are looking for funding
  run `npm fund` for details

84 moderate severity vulnerabilities

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

## Test
run NPM test 

```bash
docker container run -it frontend_client yarn test
```