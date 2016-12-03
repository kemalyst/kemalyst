const webpack = require("webpack");
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  context: __dirname + "/src/assets",
  entry: {
    main: ["./javascripts/main.js", "./stylesheets/main.css"]
  },

  output: {
    path: __dirname + "/../public",
    filename: "javascripts/[name].js",
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          presets: ['es2015']
        }
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("css!sass")
      },
    ]
  },
  plugins: [
    new ExtractTextPlugin("stylesheets/[name].css"),
  ]
};
