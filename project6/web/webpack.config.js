module.exports = {
    entry: './myscript.js',
    output: { filename: 'bundle.js' },
    plugins: [],
    module: {
        loaders: [
          {
            test: /.js?$/,
            loader: 'babel-loader',
            exclude: /node_modules/,
            query: {
              presets: ['react','es2015']
            }
          }
        ]
      },
  }