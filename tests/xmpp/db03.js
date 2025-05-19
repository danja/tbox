import { client, xml } from "@xmpp/client";
import debug from "@xmpp/debug";

const xmpp = client({
  service: "xmpp://localhost:5222",
  domain: "localhost",
  username: "alice",
  password: "wonderland",
  tls: { rejectUnauthorized: false },
});

debug(xmpp, true);

xmpp.on("error", (err) => {
  console.error("XMPP Error:", err);
});

xmpp.on("offline", () => {
  console.log("Client is offline, exiting.");
  process.exit(0);
});

xmpp.on("stanza", async (stanza) => {
  if (stanza.is("message") && stanza.getChildText("body")) {
    console.log("Received message:", stanza.getChildText("body"));
    // Optionally disconnect after receiving a message
    await xmpp.stop();
  }
});

xmpp.on("online", async (address) => {
  console.log("Connected as", address.toString());
  // Send initial presence so others see us as online
  await xmpp.send(xml("presence"));
});

xmpp.start().catch((err) => {
  console.error("XMPP start error:", err);
  process.exit(1);
});
