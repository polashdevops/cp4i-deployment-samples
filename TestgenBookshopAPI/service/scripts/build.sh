#!/bin/bash

# build.sh [repository]
# Build the Bookshop images and push them to the specified repository.
# You must already be logged in to the repository.
# The default repository is the IBM Public Repository.

repository=${1:-icr.io/integration/bookshop-api}

tag=$(date +"%Y-%m-%d-%H%M")
branch=$(git branch --show-current)
if [[ "${branch}" != main ]]; then
  tag="${tag}-${branch}"
fi

# build images, retag as latest and push all to the specified repository

image=${repository}/books-service:${tag}
images="${image}"
docker build -t ${image} --build-arg SRC_DIR=books-microservice . || exit 1
docker tag ${repository}/books-service:${tag} ${repository}/books-service:latest || exit 1
image=${repository}/books-service:latest
images="${images} ${image}"

image=${repository}/customer-order-service:${tag}
images="${images} ${image}"
docker build -t ${image} --build-arg SRC_DIR=customer-microservice . || exit 1
docker tag ${repository}/customer-order-service:${tag} ${repository}/customer-order-service:latest || exit 1
image=${repository}/customer-order-service:latest
images="${images} ${image}"

image=${repository}/bookshop-services:${tag}
images="${images} ${image}"
docker build -t ${image} --build-arg SRC_DIR=services . || exit 1
docker tag ${repository}/bookshop-services:${tag} ${repository}/bookshop-services:latest || exit 1
image=${repository}/bookshop-services:latest
images="${images} ${image}"

image=${repository}/gateway-service:${tag}
images="${images} ${image}"
docker build -t ${image} --build-arg SRC_DIR=gateway-service . || exit 1
docker tag ${repository}/gateway-service:${tag} ${repository}/gateway-service:latest || exit 1
image=${repository}/gateway-service:latest
images="${images} ${image}"

# push to repository if not local
if [[ ${repository} == *.* ]]; then
  for image in ${images}; do
    docker push ${image}
  done
fi

echo ${tag}
