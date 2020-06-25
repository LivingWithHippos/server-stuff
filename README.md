# Server's Stuff
A collection of configuration files/scripts for my server.

- [Server's Stuff](#server-s-stuff)
  * [Linuxserver.io](#linuxserverio)
  * [How does it work](#how-does-it-work)
  * [Installation](#installation)
    + [Docker](#docker)
    + [Letsencrypt](#letsencrypt)
      - [Important parameters](#important-parameters)
    + [NGINX reverse proxy](#nginx-reverse-proxy)
    + [Applications](#applications)
    + [DNS settings](#dns-settings)
    + [Final steps](#final-steps)
  * [Troubleshooting](#troubleshooting)
  * [Other apps](#other-apps)
  
## Linuxserver.io
Using the images provided by [linuxserver.io](https://www.linuxserver.io/) it's pretty easy to set up all the web-apps and services you want on your server.
External Docker images can be added almost as smoothly and usually require little configuration if any.

## How does it work
First of all, read a tiny little bit about [docker](https://www.docker.com/why-docker) and [docker-compose](https://docs.docker.com/compose/) if you don' t know what they are. 

TL:DR -> Docker is a software to create containers, where we'll put our apps, Compose is a tool for defining and running multi-container Docker applications.

Linuxserver's [Letsencrypt docker](https://github.com/linuxserver/docker-letsencrypt) is the main one; it gives us:
* free certificates: you get the green lock on your browser, and your web traffic is encrypted 
* reverse proxy: you can host multiple apps on your domain and reach them with subdomain/subfolders

For every application you want to add, you need two files: a *docker-compose.yml* to install and configure it and a *.conf* for the Nginx reverse proxy.

## Installation

_Important:_ the instructions are for servers with domains, so go and get one or skip the Letsencrypt part.

### Docker
Install [Docker](https://hub.docker.com/search?q=&type=edition&offering=community) and [Compose](https://docs.docker.com/compose/install/) for your OS. Follow their instruction carefully to configure it the first time.

### Letsencrypt
Create a new *docker-compose.yml* file under a Letsencrypt folder and paste the content from [here](https://github.com/linuxserver/docker-letsencrypt/blob/master/README.md#docker-compose) in it.
You need to fill it with your information. You can also check how [mine](https://github.com/LivingWithHippos/server-stuff/tree/master/letsencrypt) is (more or less).

#### Important parameters:

`      - TZ=Europe/London`

Set your timezone here

`      - URL=yourdomain.url`

Set your main domain here

`      - SUBDOMAINS=www,`

Set your sub-domains here. These are the ones you want to provide https for, and they need to be the same used in the various Ngix *.conf* files. For example, if I want to install [portainer](https://www.portainer.io/) and my *portainer.subdomain.conf* contains the line `    server_name portainer.*;` I will need to set it as `      - SUBDOMAINS=www,portainer`. They can be easily switched to anything you want, like `    server_name coffee.*;` and `      - SUBDOMAINS=www,coffee`, making it reachable under `coffee.mycooldomain.com`. Extra subdomains are not a problem. If you want to put your applications under a subfolder of your main domain, like `mycooldomain.com/coffee`, you don't need to add them under `SUBDOMAINS`.

`      --e EMAIL=`

You'll get some mails about certificate expiration, as they last 2/3 months. They'll be renewed automatically, so don't worry.

`      - /path/to/appdata/config:/config`

This one is important: you'll add and remove from here the Ngix *.conf* files. I used `.config:/config` as a path, this means I'll get the config folder in the same directory as this *docker-compose.yml*.

If you don't need/don't know about the optional stuff, you can remove it.

I added to the default linuxserver.io compose file a network. Since Letsencrypt's container needs to be connected to the other containers, we have two ways to do this:

* put everything in the same *docker-compose.yml* file, a single network will be created and connect all of them
* manually choose a network and set it in every *docker-compose.yml* file

I'm using a single compose file because I didn't know yet about this when I first built the server, but on this repo, I'm using option 2 (__N.B. not tested yet__).

Network creation under Letsencrypt compose file:

```
---
version: "2.1"
services:
  letsencrypt:
    ...
    ...
    networks:
      - letsencrypt_default
    
networks:
  letsencrypt_default:
    driver: bridge
```

Network use in other compose files:

```
---
version: "2.1"
services: 
  portainer:
    ...
    ...
    networks:
      - letsencrypt_default
    
networks:
  letsencrypt_default:
    external: true 
```

Run `docker-compose up -d` once to generate all the necessary files and the certificates. If you browse to *mycooldomain.com* you should see a work-in-progress message and a green lock.

If it does not work, you can check out logs with `docker logs container_name` and get the docker container name with `docker ps`

### NGINX reverse proxy

If your Letsencrypt container runs correctly, you should now have a `config` folder. Navigate to `config/ngix/proxy-confs` and check the available samples. You can also find them in [this repo.](https://github.com/linuxserver/reverse-proxy-confs) To activate one of these, you can rename it, so it ends with *.conf* after you've modified it. 
If you use one of the configuration files already in this folder, they're pretty much ready to go, there should be two versions for every app: a *subdomain* and a *subfolder* one. They will result in `app.mycooldomain.com` or `mycooldomain.com/app`, and please use only one of them.

For a subdomain config file these are the essential parameters:

`    server_name portainer.*;`

This will tell Nginx which subdomain should route the container stuff, can be changed without issues (remember to add it to SUBDOMAINS)

`                set $upstream_app portainer;`

This will tell Nginx which container needs to be connected (its name is the one used in the compose file)

`        set $upstream_port 9000;`

This will tell Nginx the port where the traffic needs to be routed inside the container

You can add many external apps by copying a sample *.conf* file and editing these three parameters.

### Applications

You can get a list of Linuxserver's applications [here](https://fleet.linuxserver.io/?key=10:linuxserver) or check their [repositories](https://github.com/linuxserver) on Github. Check the docker-compose section (like [this](https://github.com/linuxserver/docker-calibre-web#docker-compose)), copy and paste it as explained before and we're almost ready.

Check the other apps section for info on other applications outside these.

### DNS settings

Your domain point to an IP address, for example, `mysupercooldomain.com` points to `64.98.145.30`. But if you're using subdomains, you also need to make sure that those point to your IP, too.
To do this, find your DNS provider settings page and add a wildcard redirect (every subdomain will be redirected to your IP) or a redirect for every single subdomain.

Your DNS provider page should look like this:

![](https://www.netcup-wiki.de/images/Zone-editieren3.png)

Check on the internet where to find it and how to change it, look [here](https://www.namecheap.com/support/knowledgebase/article.aspx/9646/2237/how-to-create-a-cname-record-for-your-domain) for Namecheap.

### Final steps

Run this checklist:

- [ ] Letsencrypt *docker-compose.yml* configured and executed correctly
- [ ] ngix *.conf* renamed/configured under the `proxy-confs` folder
- [ ] every app *docker-compose.yml* configured
- [ ] dns record ready

Run again `docker-compose up -d` for Letsencrypt *docker-compose.yml* and then for every other compose file (if any). You can now check every subdomain/subfolder.

## Troubleshooting

* You can check the status of your containers with `docker ps` and their logs with `docker logs container_name`
* Nginx logs are under our *letsencrypt/config/log/nginx/* directory
* if you changed the DNS records, you may need to wait some time for them to propagate



## Other apps
[Awesome selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) is a curated list of app you can self-host. The easiest way to integrate them with your docker is by looking up on your favorite search engine "docker-compose appname"
