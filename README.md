# Server's Stuff
This repo is a collection of configuration files/scripts for my server. This down here is a general explanation of how everything works. Every app's folder has a README.md with more specific information.

- [Server's Stuff](#server-s-stuff)
  * [How does it work](#how-does-it-work)
  * [Installation](#installation)
    + [Docker](#docker)
    + [Letsencrypt](#letsencrypt)
      - [Important parameters:](#important-parameters)
    + [NGINX reverse proxy](#nginx-reverse-proxy)
    + [Applications](#applications)
    + [Websites and Web-apps](#websites-and-web-apps)
    + [DNS settings](#dns-settings)
    + [Final steps](#final-steps)
  * [Troubleshooting](#troubleshooting)
  * [Extra: Startpage](#extra-startpage)
  * [Extra: Other apps](#extra-other-apps)
  * [Extra: NGINX Proxy Manager](#extra-nginx-proxy-manager)

## How does it work
First of all, read a tiny little bit about [docker](https://www.docker.com/why-docker) and [docker-compose](https://docs.docker.com/compose/) if you don' t know what they are. 

TL:DR -> Docker is a software to create containers, where we'll put our apps, Compose is a tool for defining and running multi-container Docker applications.

If you´re on a public server you probably want to piont them to a domain like mycoolapp.mycooldomain.com. The software used to do this is called a reverse proxy and there many of them, nginx, trafik, caddy etc. Linuxserver's [swag docker](https://github.com/linuxserver/docker-swag) is the main one used here; it gives us:
* free certificates: you get the green lock on your browser, and your web traffic is encrypted 
* reverse proxy: you can host multiple apps on your domain and reach them with subdomain/subfolders

For every application you want to add, you need two files: a *docker-compose.yml* to install and configure it and a *.conf* for the Nginx reverse proxy.

## Installation

_Important:_ the instructions are for servers with domains, so go and get one or skip the Letsencrypt part.

### Docker
Install [Docker](https://hub.docker.com/search?q=&type=edition&offering=community) and [Compose](https://docs.docker.com/compose/install/) for your OS. Follow their instruction carefully to configure it the first time.

### Letsencrypt
Create a new *docker-compose.yml* file under a Letsencrypt folder and paste the content from [here](https://github.com/linuxserver/docker-swag#usage) in it.
You need to fill it with your information. You can also check how [mine](https://github.com/LivingWithHippos/server-stuff/tree/master/docker/letsencrypt) is (more or less).

#### Important parameters:

`      - TZ=Europe/London`

Set your timezone here

`      - URL=yourdomain.url`

Set your main domain here

`      - SUBDOMAINS=www,`

Set your sub-domains here. These are the ones you want to provide https for, and they need to be the same used in the various Ngix *.conf* files. For example, if I want to install [portainer](https://www.portainer.io/) and my *portainer.subdomain.conf* contains the line `    server_name portainer.*;` I will need to set it as `      - SUBDOMAINS=www,portainer`. They can be easily switched to anything you want, like `    server_name coffee.*;` and `      - SUBDOMAINS=www,coffee`, making it reachable under `coffee.mycooldomain.com`. Extra subdomains are not a problem. If you want to put your applications under a subfolder of your main domain, like `mycooldomain.com/coffee`, you don't need to add them under `SUBDOMAINS`. Subfolders are harder to set up so I´d avoid them where possible.

`      --e EMAIL=`

You'll get some mails about certificate expiration, as they last 2/3 months. They'll be renewed automatically, so don't worry.

`      - /path/to/appdata/config:/config`

This one is important: you'll add and remove from here the Ngix *.conf* files. I used `.config:/config` as a path, this means I'll get the config folder in the same directory as this *docker-compose.yml*.

If you don't need/don't know about the optional stuff, you can remove it.

I added to the default linuxserver.io compose file a network. Since Letsencrypt's container needs to be connected to the other containers, we have two ways to do this:

* put everything in the same *docker-compose.yml* file, a single network will be created and connect all of them
* manually choose a network and set it in every *docker-compose.yml* file

I'm using a single compose file because I didn't know yet about this when I first built the server, but I'm moving towards option 2.

Network creation under Letsencrypt/Swag compose file:

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

Or

`    server_name portainer.mydomain.com;`

if you have multiple domains on your server.

This will tell Nginx which subdomain should route the container stuff, can be changed without issues (remember to add it to SUBDOMAINS)

`                set $upstream_app portainer;`

This will tell Nginx which container needs to be connected (its name is the one used in the compose file)

`        set $upstream_port 9000;`

This will tell Nginx the port where the traffic needs to be routed inside the container

You can add many external apps by copying a sample *.conf* file and editing these three parameters.

### Applications

You can get a list of Linuxserver's applications [here](https://fleet.linuxserver.io/?key=10:linuxserver) or check their [repositories](https://github.com/linuxserver) on Github. Check the docker-compose section (like [this](https://github.com/linuxserver/docker-calibre-web#docker-compose)), copy and paste it as explained before and we're almost ready.

Check the [other apps](#other-apps) section for info on other applications' collections.

### Websites and Web-apps

Websites and Web-apps

You may want to host a site using this setup, or maybe a web-app is not available as Docker container but as an Html + CSS + javascript build.
They can be easily added to ngix/letsencrypt:

* add to your SUBDOMAINS the subdomain as before
* drop the web-app under a folder in *letsencrypt/config/www*
* navigate to *letsencrypt/config/ngix/site-confs*
* create a *.conf* file with your app name (the *default* file here has some examples) 


This is the *my-mind.conf* file for [my-mynd:](https://github.com/ondras/my-mind)

```
server {
       listen 443 ssl http2;
       listen [::]:443 ssl http2;

       root /config/www/my-mind;
       index index.html index.htm index.php;

       server_name my-mind.*;

       include /config/nginx/ssl.conf;

       client_max_body_size 0;

       location / {
               auth_basic "Restricted";
               auth_basic_user_file /config/nginx/.htpasswd;
               include /config/nginx/proxy.conf;
               try_files $uri $uri/ /index.html /index.php?$args =404;
       }
}
```
How to configure it:

`       root /config/www/my-mind;`

Point this to the folder of your web-app containing the entry file (*index.html*, *index.htm*, *index.php* or whatever).

`       server_name my-mind.*;`

As before, this is where you'll browse to access the app.

```
               auth_basic "Restricted";
               auth_basic_user_file /config/nginx/.htpasswd;
```
This is optional. It adds a password to access the app. Since many websites/web-apps do not have a login option, this can be used to restrict access.
If you decide to use this, you need to create the credentials, see [here](https://github.com/linuxserver/docker-letsencrypt#security-and-password-protection).
You have to run the command
`docker exec -it letsencrypt htpasswd -c /config/nginx/.htpasswd <username>`
and you'll be asked for a new password.
You'll also need to restart the Letsencrypt's container (but complete the configuration first).

More details on:
* https://blog.linuxserver.io/2019/04/25/letsencrypt-nginx-starter-guide/#simplehtmlwebpagehosting

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
- [ ] every app's *docker-compose.yml* configured
- [ ] ngix *.conf* configured under the `site-confs` folder and files dropped under `config/www` for evey website/webapp
- [ ] dns record ready

Run again `docker-compose up -d` for Letsencrypt *docker-compose.yml* and then for every other compose file (if any). You can now check every subdomain/subfolder.

## Troubleshooting

* You can check the status of your containers with `docker ps` and their logs with `docker logs container_name`
* You can restart your containers with `docker restart container_name`
* Nginx logs are under our *letsencrypt/config/log/nginx/* directory
* if you changed the DNS records, you may need to wait some time for them to propagate

## Extra: Startpage

When you start having more and more apps installed on your server, you may want to have a home to select the right one. There are specialized apps, such as [Heimdall](https://github.com/linuxserver/Heimdall), or you can get a static page. On [reddit](https://reddit.com/r/startpages/), there are many of them with all the code included.

![https://github.com/dbuxy218/Prismatic-Night](https://i.redd.it/3r9b1mtgh4751.png)

## Extra: Other apps

Using the images provided by [linuxserver.io](https://www.linuxserver.io/) it's pretty easy to set up all the web-apps and services you want on your server.
External Docker images can be added almost as smoothly and usually require little configuration if any. You can check on github if the project has a `docker-compose.yml` file or go directly on the [docker hub](https://hub.docker.com/). Be careful of unofficial images on the hub, use the official ones where possible.
[Awesome selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) is a curated list of app you can self-host. The easiest way to integrate them with your docker is by looking up on your favorite search engine "docker-compose appname"


## Extra: NGINX Proxy Manager
[NGINX Proxy Manager](https://github.com/jc21/nginx-proxy-manager) is a graphical tool to manage NGINX. You can avoid the swag/letsencrypt container using this. It's easy to use but you won´t learn anything about reverse proxies so you should start with swag first.
