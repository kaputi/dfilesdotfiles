module.exports = {
  tabWidth: 2,
  singleQuote: true,
  semi: true,
  trailingComma: "es5",
  overrides: [
    {
      files: [ "*.js", "*.jsx", "*.ts", "*.tsx" ],
      options: {
        tabWidth: 2,
        singleQuote: true,
        semi: true,
        trailingComma: "es5",
      }
    },
    {
      files: ["*.html"],
      options: {
        tabWidth: 4,
      }
    }
  ]
}
