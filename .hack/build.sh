#!/bin/bash
export BRANCH=$GITHUB_REF;
export SHA=$(git rev-parse --short=6 HEAD);
export BUILD_DATE=$(date --iso-8601=minutes)

if [ ! -z "${DOCKER_PASSWORD}" ]; then
  docker login -u adamveld12 -p ${DOCKER_PASSWORD}
fi

function build() {
  local buildDir=$1;
  local tag=${2:-"latest"};
  local df=${3:-"Dockerfile"};

  local imageName="gamenight/${buildDir}";

  if [ -z "$buildDir" ]; then
    echo "No build directory specified";
    exit 1;
  fi

  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\nBuilding '${imageName}'\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  docker build --build-arg "STEAM_USER=${STEAM_USER}" --build-arg "STEAM_PASS=${STEAM_PASS}" \
               --build-arg "VERSION=${tag}" \
               --label="org.opencontainers.image.created=${BUILD_DATE}" \
               --label="org.opencontainers.image.source=https://github.com/adamveld12/gamenight.git" \
               --label="org.opencontainers.image.url=https://github.com/adamveld12/gamenight" \
               --label="org.opencontainers.image.revision=${SHA}" \
               --label="org.gamenight.version=${tag}" \
               --label="org.gamenight.game-id=${buildDir}" \
               --label="org.opencontainers.image.licenses=MIT" \
               --label="org.opencontainers.image.authors=Adam Veldhousen <adam@vdhsn.com>" \
              -t "${imageName}:${tag}" \
              -f "${buildDir}/${df}" \
              ${buildDir};

  if [ "${GITHUB_REF}" = "refs/heads/master" ]; then
      docker push -a ${imageName};
  fi;
}

if ! [ -z "$1" ]; then
  build $1 $2 $3;
fi
