interface EnvConfig {
  VITE_RAFFLE_CONTRACT_ADDRESS: string;
  VITE_INDEXER_URL: string;
  VITE_WALLETCONNECT_PROJECT_ID: string;
  VITE_TARGET_CHAIN_ID: string;
  VITE_ALCHEMY_API_KEY?: string;
  VITE_MOCK_SSE?: string;
}

class EnvValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'EnvValidationError';
  }
}

function validateEnv(): EnvConfig {
  const missing: string[] = [];

  const requiredVars = [
    'VITE_RAFFLE_CONTRACT_ADDRESS',
    'VITE_INDEXER_URL',
    'VITE_WALLETCONNECT_PROJECT_ID',
    'VITE_TARGET_CHAIN_ID',
  ];

  requiredVars.forEach((varName) => {
    if (!import.meta.env[varName]) {
      missing.push(varName);
    }
  });

  if (missing.length > 0) {
    throw new EnvValidationError(
      `Missing required environment variables:\n${missing.map(v => `  - ${v}`).join('\n')}\n\n` +
      'Please check your .env file and ensure all required variables are set.'
    );
  }

  return {
    VITE_RAFFLE_CONTRACT_ADDRESS: import.meta.env.VITE_RAFFLE_CONTRACT_ADDRESS,
    VITE_INDEXER_URL: import.meta.env.VITE_INDEXER_URL,
    VITE_WALLETCONNECT_PROJECT_ID: import.meta.env.VITE_WALLETCONNECT_PROJECT_ID,
    VITE_TARGET_CHAIN_ID: import.meta.env.VITE_TARGET_CHAIN_ID,
    VITE_ALCHEMY_API_KEY: import.meta.env.VITE_ALCHEMY_API_KEY,
    VITE_MOCK_SSE: import.meta.env.VITE_MOCK_SSE,
  };
}

export const env = validateEnv();

export const TARGET_CHAIN_ID = Number(env.VITE_TARGET_CHAIN_ID);
