# Server's Stuff
A collection of configuration files/scripts for my server.

## Linuxserver.io
Using the images provided by [linuxserver.io](https://www.linuxserver.io/) it's pretty easy to set up all the web-apps and services you want on your server.
External Docker images can be added almost as smoothly and usually require little configuration, if any.

## How does it work
First of all, read a tiny little bit about [docker](https://www.docker.com/why-docker) and [docker-compose](https://docs.docker.com/compose/) if you don' t know what they are. 

TL:DR -> Docker is a software to create containers, where we'll put our apps, Compose is a tool for defining and running multi-container Docker applications.

Linuxserver's [Letsencrypt docker](https://github.com/linuxserver/docker-letsencrypt) is the main one, it gives us:
* free certificates: you get the green lock on your browser, and your web traffic is encrypted 
* reverse proxy: you can host multiple apps on your domain and reach them with subdomain/subfolders

For every application you want to add you need two files: a *docker-compose.yml* to install and configure it and a *.conf* for the ngix reverse proxy.

## Installation

_Important:_ the instructions are for servers with domains, so go and get one or skip the letsencrypt part.

### Docker
Install [Docker](https://hub.docker.com/search?q=&type=edition&offering=community) and [Compose](https://docs.docker.com/compose/install/) for your OS. Follow carefully the instruction to configure it the first time.
### Letsencrypt
Create a new *docker-compose.yml* file under a letsencrypt folder and paste the content from [here](https://github.com/linuxserver/docker-letsencrypt/blob/master/README.md#docker-compose) in it.
It needs to be modified with your informations. You can also check how [mine](https://github.com/LivingWithHippos/server-stuff/tree/master/letsencrypt) is (more or less).

#### Important parameters:

`      - TZ=Europe/London`

Set your timezone here

`      - URL=yourdomain.url`

Set your main domain here

`      - SUBDOMAINS=www,`

Set your sub-domains here. These are the ones you want to provide https for, they need to be the same used in the various ngix *.conf* files. For example if I want to install [portainer](https://www.portainer.io/) and my *portainer.subdomain.conf* contains the line `    server_name portainer.*;` I will need to set it as `      - SUBDOMAINS=www,portainer`. They can be easily switched to anything you want, like `    server_name coffee.*;` and `      - SUBDOMAINS=www,coffee`, making it reachable under `coffee.mycooldomain.com`. Extra subdomains are not a problem.

`      --e EMAIL=`

You'll get some mails about certificate expiration, as they last 2/3 months. They'll be renewed automatically so don't worry.

`      - /path/to/appdata/config:/config`

This one is important, you'll add and remove from here the ngix *.conf* files. I used `.config:/config` as a path, this means I'll get the config folder in the same directory as this *docker-compose.yml*.

If you don't need/don't know about the optional stuff you can remove it.

I added to the default linuxserver.io compose file a network. Since Letsencrypt's container needs to be connected to the other containers we have two ways to do this:

* put everything in the same *docker-compose.yml* file, a single network will be created and connect all of them
* manually choose a network and set it in every *docker-compose.yml* file

I'm using a single compose file because I didn't know yet about this when I first built the server, but on this repo I'm using option 2 (N.B. not tested yet).



## Other apps
[Awesome selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) is a curated list of app you can self-host. The easiest way to integrate them with your docker is by looking up on your favorite search engine "docker-compose appname"
