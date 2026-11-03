interface Greeting {
  message: string;
  timestamp: Date;
}

function greet(name: string): Greeting {
  return {
    message: `Hello, ${name}! Welcome to your Nix-powered TypeScript project.`,
    timestamp: new Date(),
  };
}

const info = greet("Developer");
console.log(info.message);
console.log(`Initialized at: ${info.timestamp.toISOString()}`);
