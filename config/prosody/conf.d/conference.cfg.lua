-- This file should be in: /home/danny/hyperdata/tbox/config/prosody/conf.d/conference.cfg.lua

-- Get the domain from PROSODY_DOMAIN environment variable, default to "localhost"
-- This ensures the component name and SSL settings align with the main config.
local domain = os.getenv("PROSODY_DOMAIN") or "localhost"
local conference_host = "conference." .. domain

Component(conference_host) "muc" -- "muc" is the component type for Multi-User Chat
    name = "Chatrooms on " .. conference_host
    restrict_room_creation = false -- Or "local", "admin" as per your requirements
    -- Admins for the MUC component, if needed
    -- admins = { "admin@" .. domain }

    -- If your MUC component needs to present its own SSL certificate (or reuse the main one)
    -- and your c2s/s2s settings require components to be secure.
    -- Often, components operate under the SSL context of their parent VirtualHost,
    -- but explicit configuration can be necessary for some setups or if it's on a different port.
    -- If it inherits SSL from the VirtualHost(domain) in prosody.cfg.lua, this might not be strictly needed
    -- unless you have specific requirements for the component's SSL.
    ssl = {
        key = "/etc/prosody/certs/" .. domain .. ".key"; -- Reusing main domain's cert
        certificate = "/etc/prosody/certs/" .. domain .. ".crt"; -- Reusing main domain's cert
    }

    -- You can add other MUC-specific modules here if needed, e.g.:
    -- modules_enabled = {
    --     "muc_mam", -- Message Archive Management for MUC
    -- }