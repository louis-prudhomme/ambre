<?php
// the first two lines are specified as per https://github.com/linuxserver/docker-nextcloud/blob/master/root/defaults/config.php
$CONFIG = [
    "memcache.local"        => "\OC\Memcache\APCu",
    "datadirectory"         => "/data",
    "defaultapp"            => "files",
    "skeletondirectory"     => "",
    "templatedirectory"     => "",
    "knowledgebaseenabled"  => false,
    "appstoreenabled"       => false,
    "enable_previews"       => false,
    "trusted_proxies"       => ["swag"],
    "overwriteprotocol"     => "https",
    "overwrite.cli.url"     => "OVERWRITE_CLI_URL",
    "overwritehost"         => "OVERWRITE_HOST",
    "allow_user_to_change_display_name" => false,
];