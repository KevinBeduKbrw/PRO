module.exports = {
    entry: './test.js',
    output: { filename: 'bundle.js' },
    plugins: [],
    module: {
      loaders: [
        {
          test: /.js?$/,
          loader: 'babel-loader',
          exclude: /node_modules/,
          query: {
            presets: ['es2015','react'],
            plugins:['./plugin01']
          }
        }
      ]
    },
  }