export default {
  // Eslint for TypeScript files
  "**/*.{ts,tsx}": ["pnpx eslint --fix"],
  // Prettier and Autocorrect for all files
  "**/*": ["pnpx prettier --write --ignore-unknown", "pnpx autocorrect-node --fix"],
};
