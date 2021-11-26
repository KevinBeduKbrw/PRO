var ExtractTextPlugin = require("extract-text-webpack-plugin")
var path = require('path')

module.exports = {
    entry: './app.js',
    output: { 
      path : path.resolve(__dirname, '../priv/static'),
      filename: 'bundle.js' },
    
    module: {
      loaders: [
        {
          test: /.js?$/,
          loader: 'babel-loader',
          exclude: /node_modules/,
          query: {
            presets: ['es2015','react', [
              'jsxz',
              {
                  dir: 'webflow'
              }
          ]]
          }
        },
        {
          test: /\.css$/,
          use:  {
            loader: 'file-loader',
          }
        },
        {
          test:/\.(png|jpe?g|gif)$/i,
          use:  {
            loader: 'file-loader',
          }
        }
      ],
      
    },
  }