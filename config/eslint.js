const globals = require("globals");
const js = require("@eslint/js");
const stylisticJs = require("@stylistic/eslint-plugin-js");

module.exports = [
  js.configs.recommended,
  {
    plugins: {
      "@stylistic": stylisticJs
    },
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: "script",
      globals: {
        ...globals.browser,
        ...globals.jquery,
        Cookies: "readonly",
        I18n: "readonly",
        L: "readonly",
        OSM: "writable",
        Matomo: "readonly",
        Turbo: "readonly",
        updateLinks: "readonly"
      }
    },
    rules: {
      "@stylistic/array-bracket-newline": ["error", "consistent"],
      "@stylistic/array-bracket-spacing": "error",
      "@stylistic/block-spacing": "error",
      "@stylistic/brace-style": ["error", "1tbs", { allowSingleLine: true }],
      "@stylistic/comma-dangle": "error",
      "@stylistic/comma-spacing": "error",
      "@stylistic/comma-style": "error",
      "@stylistic/computed-property-spacing": "error",
      "@stylistic/dot-location": ["error", "property"],
      "@stylistic/eol-last": "error",
      "@stylistic/func-call-spacing": "error",
      "@stylistic/indent": ["error", 2, {
        SwitchCase: 1,
        VariableDeclarator: "first",
        FunctionDeclaration: { parameters: "first" },
        FunctionExpression: { parameters: "first" },
        CallExpression: { arguments: "first" }
      }],
      "@stylistic/key-spacing": "error",
      "@stylistic/keyword-spacing": "error",
      "@stylistic/no-floating-decimal": "error",
      "@stylistic/no-mixed-operators": "error",
      "@stylistic/no-multiple-empty-lines": "error",
      "@stylistic/no-multi-spaces": "error",
      "@stylistic/no-trailing-spaces": "error",
      "@stylistic/no-whitespace-before-property": "error",
      "@stylistic/object-curly-newline": ["error", { consistent: true }],
      "@stylistic/object-curly-spacing": ["error", "always"],
      "@stylistic/object-property-newline": ["error", { allowAllPropertiesOnSameLine: true }],
      "@stylistic/operator-linebreak": ["error", "after"],
      "@stylistic/padded-blocks": ["error", "never"],
      "@stylistic/quote-props": ["error", "consistent-as-needed", { keywords: true, numbers: true }],
      "@stylistic/quotes": ["error", "double"],
      "@stylistic/semi": ["error", "always"],
      "@stylistic/semi-spacing": "error",
      "@stylistic/semi-style": "error",
      "@stylistic/space-before-blocks": "error",
      "@stylistic/space-before-function-paren": ["error", { named: "never" }],
      "@stylistic/space-in-parens": "error",
      "@stylistic/space-infix-ops": "error",
      "@stylistic/space-unary-ops": "error",
      "@stylistic/switch-colon-spacing": "error",
      "@stylistic/wrap-iife": "error",
      "@stylistic/wrap-regex": "error",

      "accessor-pairs": "error",
      "array-callback-return": "error",
      "block-scoped-var": "error",
      "curly": ["error", "multi-line", "consistent"],
      "dot-notation": "error",
      "eqeqeq": ["error", "smart"],
      "no-alert": "warn",
      "no-array-constructor": "error",
      "no-caller": "error",
      "no-console": "warn",
      "no-div-regex": "error",
      "no-eq-null": "error",
      "no-eval": "error",
      "no-extend-native": "error",
      "no-extra-bind": "error",
      "no-extra-label": "error",
      "no-implicit-coercion": "warn",
      "no-implicit-globals": "warn",
      "no-implied-eval": "error",
      "no-invalid-this": "error",
      "no-iterator": "error",
      "no-labels": "error",
      "no-label-var": "error",
      "no-lone-blocks": "error",
      "no-lonely-if": "error",
      "no-loop-func": "error",
      "no-multi-str": "error",
      "no-negated-condition": "error",
      "no-nested-ternary": "error",
      "no-new": "error",
      "no-new-func": "error",
      "no-new-object": "error",
      "no-new-wrappers": "error",
      "no-octal-escape": "error",
      "no-param-reassign": "error",
      "no-process-env": "error",
      "no-proto": "error",
      "no-script-url": "error",
      "no-self-compare": "error",
      "no-sequences": "error",
      "no-throw-literal": "error",
      "no-undef-init": "error",
      "no-undefined": "error",
      "no-unmodified-loop-condition": "error",
      "no-unneeded-ternary": "error",
      "no-unused-expressions": "off",
      "no-unused-vars": ["error", { caughtErrors: "none" }],
      "no-useless-call": "error",
      "no-useless-concat": "error",
      "no-useless-return": "error",
      "no-use-before-define": ["error", { functions: false }],
      "no-void": "error",
      "no-warning-comments": "warn",
      "radix": ["error", "always"],
      "yoda": "error"
    }
  },
  {
    // Additional configuration for test files
    files: ["test/**/*.js"],
    languageOptions: {
      globals: {
        ...globals.mocha,
        expect: "readonly",
        assert: "readonly",
        should: "readonly"
      }
    }
  },
  {
    files: ["config/eslint.js"],
    languageOptions: {
      ecmaVersion: 2019,
      sourceType: "commonjs",
      globals: {
        ...globals.commonjs
      }
    }
  }
];
