//require('!!file-loader?name=jquery-3.5.1.min.dc5e7f18c8.js')
require('!!file-loader?name=js/jquery.js!./webflow/ressources/jquery-3.5.1.min.dc5e7f18c8.js')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')

/* required css for our application */
require("./webflow/ressources/chapitre4.webflow.812bac897.css");

var Page = createReactClass( {
    render(){
      return <JSXZ in="orders" sel=".container">
      </JSXZ>
    }
    })
    
    ReactDOM.render(<Page />, document.getElementById('root'));