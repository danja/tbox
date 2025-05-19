import { client, xml } from "@xmpp/client";
import debug from "@xmpp/debug";

// Credentials and connection info for local Prosody server
const xmpp = client({
  service: "xmpp://localhost:5222", // plain XMPP, not xmpps, as self-signed certs are used
  domain: "localhost",
  username: "danja",
  password: "Claudiopup",
  tls: { rejectUnauthorized: false }, // Accept self-signed certs for local/dev
});

debug(xmpp, true);

xmpp.on("error", (err) => {
  console.error("XMPP Error:", err);
});

xmpp.on("offline", () => {
  console.log("Client is offline");
});

let sent = false;

xmpp.on("online", async (address) => {
  console.log("Connected as", address.toString());
  if (!sent) {
    sent = true;
    const message = xml(
      "message",
      { type: "chat", to: "alice@localhost" },
      xml("body", {}, "Hello from dogbot client!")
    );
    try {
      await xmpp.send(message);
      console.log("Message sent!");
    } catch (err) {
      console.error("Failed to send message:", err);
    }
    // Disconnect after sending
    await xmpp.stop();
  }
});

xmpp.on("offline", () => {
  console.log("Client is offline, exiting.");
  process.exit(0);
});

xmpp.start().catch((err) => {
  console.error("XMPP start error:", err);
  process.exit(1);
});
