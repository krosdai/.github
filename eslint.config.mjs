import js from "@eslint/js";
import { defineConfig, globalIgnores } from "eslint/config";
import globals from "globals";
import tseslint from "typescript-eslint";

/**
 * Common ignore patterns shared across all workspaces
 * Usage: globalIgnores(commonIgnorePatterns)
 */
export const commonIgnorePatterns = [
  "dist",
  "node_modules",
  "**/*.d.ts",
  "**/*.d.mts",
  "**/*.d.cts",
];
/**
 * Create language options config for TypeScript files
 * @param {string} tsconfigRootDir - The root directory for tsconfig.json (use import.meta.dirname)
 * @param {'node' | 'browser'} environment - Runtime environment
 * @param {number} ecmaVersion - ECMAScript version (default: 2020)
 * @returns ESLint language options configuration
 */
export const createTypeScriptConfig = (
  tsconfigRootDir,
  environment = "node",
  ecmaVersion = 2020,
) => ({
  files: ["**/*.{ts,tsx}"],
  languageOptions: {
    ecmaVersion,
    globals: environment === "browser" ? globals.browser : globals.node,
    parserOptions: {
      projectService: true, // 🎯 Core config: auto-detect tsconfig
      tsconfigRootDir,
    },
  },
});

/**
 * Base ESLint configuration for all workspaces
 * Workspaces can import and extend this config
 */
export const baseConfig = [
  // 1. Base ESLint rules
  js.configs.recommended,

  // 2. Linter options
  {
    linterOptions: {
      // ⚠️ 禁止修改：强制报告未使用的 disable 指令，保持代码库清洁
      // ⚠️ DO NOT MODIFY: Report unused eslint-disable directives as errors to keep codebase clean
      reportUnusedDisableDirectives: "error", // 'error', 'warn'
    },
  },

  // 3. TypeScript syntax rules (no type info required)
  ...tseslint.configs.strict,
  ...tseslint.configs.stylistic,

  // 4. 🔑 Full Type-Aware rules
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,

  // 5. Disable type-aware rules for .js files
  {
    files: ["**/*.js", "**/*.mjs", "**/*.cjs"],
    ...tseslint.configs.disableTypeChecked,
  },

  // 6. Relax type-aware rules for test files (Bun/Jest often lack complete type definitions)
  {
    files: ["**/tests/**/*.ts", "**/*.test.ts"],
    rules: {
      "@typescript-eslint/no-unsafe-assignment": "off",
      "@typescript-eslint/no-unsafe-call": "off",
      "@typescript-eslint/no-unsafe-member-access": "off",
      "@typescript-eslint/no-unsafe-argument": "off",
      "@typescript-eslint/no-unsafe-return": "off",
    },
  },
];

/**
 * Root-level ESLint configuration
 * Ignores workspace directories as they have their own configs
 */
export default defineConfig([
  // Ignore workspace directories (they have their own eslint configs)
  globalIgnores([...commonIgnorePatterns, "apps/**", "packages/**"]),

  // Apply base config to root-level files
  ...baseConfig,

  // Configure type information source for root
  createTypeScriptConfig(import.meta.dirname, "node", 2020),
]);
