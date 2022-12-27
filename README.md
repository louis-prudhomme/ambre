# Ambre

Docker-composed Transmission download center. The goal with this repository is to spin a team of containers in as few commands as possible, as reproducibly as possible.

It will be self-hosted and needs to be accessible from within a home network as well as from the wider web. To this end, it should also bear a SSL certificate.

Moreover, it must funnel its traffic through a VPN for security purposes ; network bridges will then be required.

To achieve this [architecture](.pics/2023-01-05-22-35-13.png), a multiple stage plan will be followed:
1. ~~spin the _core_ reliably (transmission, nextcloud & wireguard)~~ => **achieved 30jan23**
2. bridge local and external networks so the _core_ is accessible from within a home network
3. add a SWAG container to the team, to secure it behind a firewall as well as a SSL certificate
4. improvements:
   1. add a `mariadb` image to `nextcloud` to avoid using SQLite (see [this note](ABOUT.md#note-1))
   2. embed `incron` into the `nextcloud` image (see [this note](ABOUT.md#note))
   3. less `transcrypt`ion of essential files to 
   4. dissociate `nextcloud` admin user from the user used by `transmission`
      1. support for multiple users (both in `transmission` & `nextcloud`)

This journey will be documented as extensively as possible, including the steps which are not code or configuration. The code will be written as readably as possible.

## Setup (and scrap)

Two bash script files are provided in this repository. One will configure the repository to allow firing it, the other is meant to scrap everything **including the data folders** (which helps you test the configuration rapidly).

To run `setup.bash`, you must give it the name of a `.conf` file, which will get copied to where the wireguard container can find it.

## Incron

[Incron](https://github.com/ar-/incron) is used to monitor completed torrents and force the Nextcloud container to re-scan the files of your user. 

It is a bit folkloric, but alternatives would be more complex and, frankly, using incron is quite simple (see [About Incron](ABOUT.md#-nextcloud-image--healthcheck)).

1. install incron using `add-apt-repository "ppa:altair-ibn-la-ahad/incron" && apt update && apt install incron`
2. allow your user to use incron with `echo "${USER}" >> /etc/incron.allow`
3. finally, enter `incrontab -e` and enter and paste `<path to transmission complete folder> IN_MODIFY <path to repository>/transmission/postcompletion.bash`

Once done, your Nextcloud instance should re-scan your user's folder for each new completed torrent.

## Transcrypt

Like other repositories, Ambre uses [Transcrypt](https://github.com/elasticdog/transcrypt) to cipher sensitive data.

If you seek what's behind the cipher to reproduce this experiment at home, here are the basics:

<details> 
    <summary>env.template</summary>

    ```conf
    # global
    COMPOSE_PROJECT_NAME=ambre
    data_path=/Whatever/suits/you/best
    timezone=Europe/Paris
    # wireguard
    wireguard_ext_port=51820
    # transmission
    transmission_usr=Jane
    transmission_pwd=ExtremelyRobustPassword
    transmission_peerport=51413
    transmission_ui_port=9091
    # nextcloud
    nextcloud_port=80
    nextcloud_usr=John
    ```
</details>

<details> 
    <summary>autoconfig.php</summary>

    ```php
    <?php
    $AUTOCONFIG = [
        "dbtype"        => "sqlite",
        "dbname"        => "nextcloud",
        "dbtableprefix" => "",
        "adminlogin"    => "root",
        "adminpass"     => 'SuperMightyPassword',
        "directory"     => "/data",
        "install"       => true,
    ];
    ```
</details>

Finally, the contents of `wireguard/` are Wireguard `.conf` files, without anything special.

## Acknowledgments

Big thanks to the [LinuxServer.io](https://github.com/linuxserver) community.

## ... Flood for Transmission

Why ? Because I like Flood.

Furthermore, it might of use for you to know how to install a different theme on your own transmission, starting from this repository. Here you go.