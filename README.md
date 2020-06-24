# Server's Stuff
A collection of configuration files/scripts for my server

## Linuxserver.io
Using the images provided by [linuxserver.io](https://www.linuxserver.io/) it's pretty easy to set up all the web-apps and services you want on your server.
External Docker images can be added almost as smoothly and usually require little configuration, if any.

### How does it work
First of all, read a tiny little bit about [docker](https://www.docker.com/why-docker) and [docker-compose](https://docs.docker.com/compose/) if you don' t know what they are. 

TL:DR -> Docker is a software to create containers, where we'll put our apps, Compose is a tool for defining and running multi-container Docker applications.

The [Letsencrypt docker](https://github.com/linuxserver/docker-letsencrypt) is the main one, it gives us:
* free certificates: you get the green lock on your browser, and your web traffic is encrypted 
* reverse proxy: you can host multiple apps on your domain and reach them with subdomain/subfolders

## Other apps
[Awesome selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) is a curated list of app you can self-host. The easiest way to integrate them with your docker is by looking up on your favorite search engine "docker-compose appname"
