import type {Config} from '@jest/types';

const config: Config.InitialOptions = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
  },
  moduleNameMapper: {
    "^src/(.*)$": "<rootDir>/src/$1",
    '\\.(css|scss|sass|less)$': 'identity-obj-proxy',
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
  testMatch: ['<rootDir>/test/**/*.test.ts?(x)'],
  testPathIgnorePatterns: ['/node_modules/', '/dist/'],
  coverageDirectory: '<rootDir>/coverage',
};

export default config;
