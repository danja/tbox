admins = { "admin@localhost" }

modules_enabled = {
    "roster"; "saslauth"; "tls"; "dialback"; "disco";
    "posix"; "ping"; "register";
    "admin_adhoc"; "offline"; "c2s"; "s2s";
    "vcard";
}

-- Authentication settings
authentication = "internal_plain"
allow_unencrypted_plain_auth = true
c2s_require_encryption = false
s2s_require_encryption = false

-- Registration settings
allow_registration = true
-- Conflict management - if a second connection with the same resource connects, kick the first one
conflict_resolve = "kick_oldest"

-- Logging settings
http_monitoring_interval = 30

http_upload_file_size_limit = 104857600
http_upload_expire_after = 60 * 60 * 24 * 7
http_upload_path = "/var/lib/prosody/http_upload"

log = {
    debug = "*console";
}

-- Virtual hosts
VirtualHost "localhost"
    ssl = {
        key = "/etc/prosody/certs/localhost.key";
        certificate = "/etc/prosody/certs/localhost.crt";
    }

VirtualHost "xmpp"
    ssl = {
        key = "/etc/prosody/certs/localhost.key";
        certificate = "/etc/prosody/certs/localhost.crt";
    }
    authentication = "internal_plain"
    allow_unencrypted_plain_auth = true

-- Multi-user chat rooms
Component "conference.localhost" "muc"
    name = "Conference Rooms"
    restrict_room_creation = false

Component "conference.xmpp" "muc"
    name = "Conference Rooms"
    restrict_room_creation = false