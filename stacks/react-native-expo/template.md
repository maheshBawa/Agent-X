# React Native + Expo Project Scaffold

## Directory Structure
```
├── app/                        # Expo Router file-based routing
│   ├── _layout.tsx             # Root layout
│   ├── index.tsx               # Home screen
│   └── (tabs)/                 # Tab navigation
├── components/                 # React Native components
│   ├── ui/                     # Reusable UI components
│   └── features/               # Feature-specific components
├── lib/                        # Utility functions
│   ├── api.ts                  # API client
│   ├── auth.ts                 # Authentication
│   └── storage.ts              # Local storage utilities
├── hooks/                      # Custom hooks
├── types/                      # TypeScript types
├── assets/                     # Images, fonts
├── tests/                      # Test files
├── .env.example
├── app.json
├── tsconfig.json
└── package.json
```

## Setup Commands
```bash
npx create-expo-app@latest . --template tabs
npm install expo-router react-native-safe-area-context
npm install -D @testing-library/react-native jest prettier
```
