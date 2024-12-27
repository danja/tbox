admins = { }

modules_enabled = {
    "roster"; "saslauth"; "tls"; "dialback"; "disco";
    "posix"; "http_upload"; "ping"; "register";
    "admin_adhoc"; "offline"; "c2s"; "s2s";
    "http_monitoring";
}

allow_registration = true
c2s_require_encryption = true
s2s_require_encryption = true

http_monitoring_interval = 30

http_upload_file_size_limit = 104857600
http_upload_expire_after = 60 * 60 * 24 * 7
http_upload_path = "/var/lib/prosody/http_upload"

log = {
    info = "/var/log/prosody/prosody.log";
    error = "/var/log/prosody/error.log";
}

VirtualHost "localhost"
    ssl = {
        key = "/etc/prosody/certs/localhost.key";
        certificate = "/etc/prosody/certs/localhost.crt";
    }


