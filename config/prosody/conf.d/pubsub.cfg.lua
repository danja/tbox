-- File: /home/danny/hyperdata/tbox/config/prosody/conf.d/pubsub.cfg.lua
-- Configures a Publish-Subscribe (PubSub) component

local domain = os.getenv("PROSODY_DOMAIN") or "localhost"
local pubsub_host = "pubsub." .. domain

Component(pubsub_host) "pubsub"
    name = "Publish-Subscribe service on " .. domain
    -- restrict_node_creation = "admin" -- or "local" or false
    -- modules_enabled = { "pubsub_max_items", "pubsub_pep" } -- PEP is often handled by the main vhost
    -- By default, pubsub nodes are persistent.
    -- pubsub_storage = "internal" -- Default, or specify another storage backend if configured
    ssl = {
        key = "/etc/prosody/certs/" .. domain .. ".key"; -- Reusing main domain's cert
        certificate = "/etc/prosody/certs/" .. domain .. ".crt"; -- Reusing main domain's cert
    }

-- You might also want to enable PEP (Personal Eventing Protocol) on your main VirtualHost
-- if it's not already implicitly handled. PEP uses PubSub.