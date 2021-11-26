console.log("ok")
//require('!!file-loader?name=webflow.js')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
/* required css for our application */
require('./chap4_2.css');
//import css from "./chap4.css"
var Page = createReactClass( {
    render(){
      return <JSXZ in="orders" sel=".container">
      </JSXZ>
    }
    })
    
    ReactDOM.render(<Page />, document.getElementById('root'));