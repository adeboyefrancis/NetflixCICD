# netflix-clone-using-react-typescript-mui(Sandbox)

This repository contains a Netflix‑style frontend built with React, TypeScript, MUI and Vite.

## 🧪 Testing

The project is configured to use **Jest** powered by `ts-jest` for TypeScript support.  Because the Jest configuration itself is written in TypeScript, we also install `ts-node` so it can run on CI. A basic helper test is included to verify the configuration.

### Scripts

```bash
# install dependencies
npm install

# run tests once
npm run test

# run in watch mode during development
npm run test:watch
```

### Test files

Place your tests in the top‑level `test/` directory using the `.test.ts` / `.test.tsx` convention.  The `test/common.test.ts` file demonstrates some example assertions.

---

Feel free to expand the suite with component tests, mock stores, and React Testing Library as needed.
