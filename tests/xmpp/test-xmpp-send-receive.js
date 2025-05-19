// ES module test runner for XMPP send/receive
import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const receiverScript = path.join(__dirname, 'db03.js');
const senderScript = path.join(__dirname, 'db02.js');

console.log('Starting XMPP receiver (alice@localhost)...');
const receiver = spawn('node', ['--no-warnings', receiverScript], {
  env: { ...process.env, NODE_TLS_REJECT_UNAUTHORIZED: '0' },
  stdio: ['ignore', 'pipe', 'pipe']
});

let received = false;

receiver.stdout.on('data', (data) => {
  const str = data.toString();
  process.stdout.write('[RECEIVER] ' + str);
  if (str.includes('Received message: Hello from dogbot client!')) {
    received = true;
    receiver.kill();
    process.exit(0);
  }
});

receiver.stderr.on('data', (data) => {
  process.stderr.write('[RECEIVER-ERR] ' + data.toString());
});

receiver.on('spawn', () => {
  // Wait a moment for receiver to be ready, then send
  setTimeout(() => {
    console.log('Starting XMPP sender (danja@localhost)...');
    const sender = spawn('node', ['--no-warnings', senderScript], {
      env: { ...process.env, NODE_TLS_REJECT_UNAUTHORIZED: '0' },
      stdio: ['ignore', 'pipe', 'pipe']
    });
    sender.stdout.on('data', (data) => process.stdout.write('[SENDER] ' + data.toString()));
    sender.stderr.on('data', (data) => process.stderr.write('[SENDER-ERR] ' + data.toString()));
    sender.on('exit', (code) => {
      if (!received) {
        console.error('Sender exited but message not received.');
        process.exit(1);
      }
    });
  }, 1000);
});

receiver.on('exit', (code) => {
  if (!received) {
    console.error('Receiver exited before message received.');
    process.exit(1);
  }
});
