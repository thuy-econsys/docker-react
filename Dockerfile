# Node setup is just for generating a build directory that NGINX will use, everything else in Build is dumped
FROM node:alpine as BuildImage

#Patch and mkdir, must run as root
RUN apk upgrade --available && \
  mkdir -p /opt/md715 && \
  chown -R node:node /opt/md715

USER node
WORKDIR /opt/md715

COPY --chown=node:node ./package.json .
RUN yarn install
COPY --chown=node:node . .

# optimizes JavaScript for production, creating a build directory
RUN yarn build

FROM nginx

# copy over build directory generated in Build
COPY --from=BuildImage /opt/md715/build /usr/share/nginx/html
# COPY --from=0 /opt/md715/build /usr/share/nginx/html