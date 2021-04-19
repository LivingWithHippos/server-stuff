#!/bin/sh

# point this to the base folder with the folders of the various docker-compose.yml
DOCKER_BASE_PATH="$PWD"

UPDATED=0
SKIPPED=0

docker_update_menu () {

echo "Do you want to update $1"

select ync in "Yes" "No" "Cancel"; do
    case $ync in
        Yes ) UPDATED=$((UPDATED+1)); cd "$DOCKER_BASE_PATH/$2"; docker-compose pull && docker-compose up -d; break;;
        No ) SKIPPED=$((SKIPPED+1)); break;;
        Cancel ) print_log; exit;;
    esac
done

}

docker_update_build_menu () {

echo "Do you want to update $1"

select ync in "Yes" "No" "Cancel"; do
    case $ync in
        Yes ) UPDATED=$((UPDATED+1)); cd "$DOCKER_BASE_PATH/$2"; docker-compose build --no-cache && docker-compose up -d; break;;
        No ) SKIPPED=$((SKIPPED+1)); break;;
        Cancel ) print_log; exit;;
    esac
done

}

print_log () {
    echo "$UPDATED container/s updated, $SKIPPED container/s skipped."
    echo "End of the docker update script."
}

# Will update the docker compose inside $PWD/caddy
docker_update_menu "caddy" "caddy"

# Will update the docker compose inside $PWD/weblate/docker-compose
docker_update_menu "Weblate" "weblate/docker-compose"

# will build the image before updating the container
docker_update_build_menu "Simplytranslate" "simplytranslate"

print_log
