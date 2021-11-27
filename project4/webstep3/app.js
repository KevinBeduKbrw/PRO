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

      var orders = [
        {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
        {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
        {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
        {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
      ]
      //var test2 = <ArrayLine ord={orders}>XXX</ArrayLine>;
      //To render this JSON in the table, we will have to map the list on a **`JSXZ`** render. 
      var zzzz;
     /* orders.forEach(function(order) {
        zzzz += <Z sel=".col-1 .labellinearray">{order.remoteid}</Z>
      });*/
      console.log(zzzz);
      //orders.map( order => console.log(<div>Test</div>) )
      
      var test = <JSXZ in="orders" sel=".container">
        <Z sel=".mainarraybody">
          
          {orders.map( order => (
            <JSXZ in="orders" sel=".linemainarraybody">
              <Z sel=".col-1">{order.remoteid}</Z>
              <Z sel=".col-2">{order.custom.customer.full_name}</Z>
              <Z sel=".col-3">{order.custom.billing_address}</Z>
              <Z sel=".col-4">{order.items}</Z>   
            </JSXZ>
          ))}
        </Z>
      </JSXZ>
      /*var test = <JSXZ in="orders" sel=".container">
        <Z sel=".mainarraybody">
          <JSXZ in="orders" sel=".linemainarraybody">
            <Z sel=".col-1">{orders[0].remoteid}</Z>
            <Z sel=".col-2">{orders[0].custom.customer.full_name}</Z>
            <Z sel=".col-3">{orders[0].custom.billing_address}</Z>
            <Z sel=".col-4">{orders[0].items}</Z>   
          </JSXZ>

          <JSXZ in="orders" sel=".linemainarraybody">
            <Z sel=".col-1">{orders[0].remoteid}</Z>
            <Z sel=".col-2">{orders[0].custom.customer.full_name}</Z>
            <Z sel=".col-3">{orders[0].custom.billing_address}</Z>
            <Z sel=".col-4">{orders[0].items}</Z>   
          </JSXZ>
        </Z>
      </JSXZ>*/
      /*var results = 
      <JSXZ in="orders" sel=".linemainarraybody">
      {orders.map( order => (
      <Z sel=".col-1">{order.remoteid}</Z>
      
      ))}
      </JSXZ>
      console.log(results)*/
      return test
    }
    })

    var ArrayLine = createReactClass({
      render(){
        console.log(this.props);
        return <div>Test</div>
      }
    })

    ReactDOM.render(<Page />, document.getElementById('root'));
    //ReactDOM.render(<ArrayLine></ArrayLine>,document.getElementsByClassName("col-1"));

    