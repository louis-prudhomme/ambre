# About... 

- [About...](#about)
  - [... `transmission` \<=\> `nextcloud` sync \& Incron](#-transmission--nextcloud-sync--incron)
    - [Note](#note)
  - [... the Nextcloud `autoconfig.php` file](#-the-nextcloud-autoconfigphp-file)
    - [Note](#note-1)
  - [... Nextcloud image \& healthcheck](#-nextcloud-image--healthcheck)
    - [Note](#note-2)

## ... `transmission` <=> `nextcloud` sync & Incron

Nextcloud does not automatically index files when they are added directly in its filesystem. This is an issue, as it is exactly what we want to happen with `transmission` ; when a torrent download is complete, move it into the `complete/` folder within `nextcloud` filesystem, so it can be access from Nextcloud interface.

Fortunately, the `occ` command can be used to force Nextcloud to scan its filesystem. We simply need to issue it to the `nextcloud` container (or from within it) ; from there, several solutions can be envisioned to summon it when a torrent completes:
- use a cron with a small interval (several minutes) to summon it periodically
- use incron to summon it when a file is added to the filesystem
- use `transmission` `onCompletion` property to execute a script ; however, we'd then have to bridge the gap between `nextcloud` and `transmission`, which are two separate containers 

I've chosen to go with the second solution, as it avoids re-scanning the entire filesystem when not needed as well as shaving off additional complexity of issuing a command from a container to another.

### Note

`incron` cannot be easily installed on Alpine, which is the base for all [LinuxServer.io]() images. For the moment, my server being Debian/Ubuntu-based, I'll install it globally. However I plan on building upon the `nextcloud` `Dockerfile` and adding a layer in which I'd pull & build `incron` source files in order to embed it inside.

## ... the Nextcloud `autoconfig.php` file

According to Nextcloud's [documentation](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/automatic_configuration.html) it is possible to configure the installation process through files instead of going through their web UI wizard. 

Their documentation is accurate, save for one point: your `autoconfig.php` file **must** bear a `"install" => true` key, or the installation **will not** be triggered, as per [their code](https://github.com/nextcloud/server/blob/06a572ff55b193f51930571c5bb686787f709c67/core/Controller/SetupController.php#L67). Otherwise, upon accessing the web UI for the first time, you will be met with the setup wizard.

### Note

I have intentionally chosen to use the SQLite database, as I am likely to:
- have one user (me)
- not to sync any device with Nextcloud (for the time being)

This avoids having to bloat the already sizeable `docker-compose.yml` any further by shaving off the need for a MariaDB container ; however, you might want to consider this option as well if your use case differs.

## ... Nextcloud image & healthcheck

The `nextcloud` image needs installation before use ; this is usually done through manual configuration when first accessing the web UI, but [can](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/automatic_configuration.html) be automated away through use of configuration files. That being said, the installation must still be triggered by accessing the web UI (although it will not ask for any input when using configuration files). 

The installation process sets the database up and creates the admin user along with their personal folder. However, as stated in [this](https://github.com/nextcloud/server/pull/18130#issuecomment-604697773) pull request, it could be a security threat to allow the creation of a Nextcloud user if corresponding user folder already exists ; as such, the installation **will crash** if a folder already exists for the admin user.

This has the side effect of preventing us from running our `transmission` image before Nextcloud is installed. Indeed:
1. `nextcloud` starts (but is not installed)
1. `transmission` starts (and creates the folders it needs)
1. upon accessing nextcloud web UI, installation will start 
1. => installation crashes because `transmission` has created folders

Possible solutions:
- delay `transmission` start while `nextcloud` installation is not complete
- use mocked paths for `transmission` first start, install `nextcloud` manually and restart everything with real paths

I chose the first solution, under the form of a docker `HEALTHCHECK`. The healthcheck consists in a `curl` to the `nextcloud` login page, which has two benefits:
- as `curl` accesses the web UI, it triggers installation
- as, during installation, `nextcloud` returns `5xx` HTTP codes, `curl` will help us wait for its end

See [this issue discussion](https://github.com/linuxserver/docker-nextcloud/issues/280) for some more context.

### Note

To check whether your container sets itself up and running correctly, you can use the following commands:
- `watch -c -n 1 "docker-compose logs nextcloud | tail -n 50"` => see how your nextcloud install progresses
- `watch -c -n 1 "docker inspect --format '{{json .State.Health }}' nextcloud | jq"` => see the health status of your container, as well as `HEALTHCHECK` logs
