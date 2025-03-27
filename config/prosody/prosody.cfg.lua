admins = { "admin@localhost" }

modules_enabled = {
    "roster"; "saslauth"; "tls"; "dialback"; "disco";
    "posix"; "ping"; "register";
    "admin_adhoc"; "offline"; "c2s"; "s2s";
    "muc"; "muc_mam"; "vcard";
}

allow_registration = true
c2s_require_encryption = false
s2s_require_encryption = false

http_monitoring_interval = 30

http_upload_file_size_limit = 104857600
http_upload_expire_after = 60 * 60 * 24 * 7
http_upload_path = "/var/lib/prosody/http_upload"

log = {
    debug = "*console";
}

VirtualHost "localhost"
    ssl = {
        key = "/etc/prosody/certs/localhost.key";
        certificate = "/etc/prosody/certs/localhost.crt";
    }

Component "conference.localhost" "muc"
    name = "Conference Rooms"
    restrict_room_creation = false


