var Qs = require('qs')
var Cookie = require('cookie')
require('!!file-loader?name=js/jquery.js!./webflow/ressources/jquery-3.5.1.min.dc5e7f18c8.js')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
var XMLHttpRequest = require("xhr2")
const { resolve } = require('path/posix')
/* required css for our application */
require("./webflow/ressources/chapitre4.webflow.812bac897.css");

var browserState = {Child: Child}
var remoteProps = {
  user: (props)=>{
    return {
      url: "/api/me",
      prop: "user"
    }
  },
  orders: (props)=>{
    if(!props.user)
      return
      
    var qs = {...props.qs, user_id: props.user.value.id}
    var query = Qs.stringify(qs)
    console.log("QUERY",qs);
    return {
      url: "/api/orders" + (query == '' ? '' : '?' + query),
      prop: "orders"
    }
  },
  order: (props)=>{
    return {
      url: "/api/order/" + props.order_id,
      prop: "order"
    }
  }
}

var HTTP = new (function(){
  this.get = (url)=>this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    console.log(method,url,data)
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept","application/json,*/*;0.8")
    req.setRequestHeader("content-type","application/json")
    req.onload = ()=>{
      console.log("ONLOAD",req.responseText,req);
      if(req.status >= 200 && req.status < 300){
        
        resolve(req.responseText && JSON.parse(req.responseText))
      }else{
        reject({http_code: req.status})
      }
    }
  req.onerror = (err)=>{
    reject({http_code: req.status})
  }
  req.send(data && JSON.stringify(data))
  })
})()

var Page = createReactClass( {
  render(){

    var orders = [
      {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
      {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
      {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
      {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
    ]

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
  
    return test
  }
});

var Child = createReactClass({
  render(){
    var [ChildHandler,...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
});

var Layout = createReactClass({
  render(){
    //console.log(this.props.handlerPath[0].remoteProps[0]());

    return <JSXZ in="neworders" sel=".layout">
        <Z sel=".layout-container">
          <Child {...this.props}/>
        </Z>
      </JSXZ>
  }
});

var Header = createReactClass(
  {statics: {
    remoteProps:[remoteProps.user] 
  },
  render(){
    return <JSXZ in="neworders" sel=".header">
      
        <Z sel=".header-container">
          <Child {...this.props}/>
        </Z>
      </JSXZ>
  }
});

var Orders = createReactClass(
  {statics: {
    remoteProps:[remoteProps.orders] 
  },
  render(){
    console.log("ORDERS ",this.props);
/*
[
      {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
      {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
      {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
      {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
    ]

{orders.map( order => (
          <JSXZ in="orders" sel=".linemainarraybody" key={order.remoteid}>
            <Z sel=".col-1">{order.remoteid}</Z>
            <Z sel=".col-2">{order.custom.customer.full_name}</Z>
            <Z sel=".col-3">{order.custom.billing_address}</Z>
            <Z sel=".col-4">{order.items}</Z>   
          </JSXZ>
        ))}*/
    return <JSXZ in="neworders" sel=".containerr">
        <Z sel=".mainarraybody">
        
        
      </Z>
      </JSXZ>
  }
});

var Order = createReactClass({
  render(){
    return <JSXZ in="neworder" sel=".containerr">
        
      </JSXZ>
  }
});

var ErrorPage= createReactClass({
  render(){
    return <div>{this.props.message}</div>;
  }
});

var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && {handlerPath: [Layout, Header,Orders]}
    }
  }, 
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      console.log(path);
      var r = new RegExp("/order/([^/]*)$").exec(path)
      return r && {handlerPath: [Layout, Header, Order],  order_id: r[1]}
    }
  }
};

var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs=='') ? '' : ('?'+qs))
  history.pushState({}, "", url)
  onPathChange()
}

function onPathChange() {
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)

  browserState = {
    ...browserState, 
    path: path, 
    qs: qs, 
    cookie: cookies
  }

  var route, routeProps;
  //We try to match  the requested path to one our our routes
  for(var key in routes) {
    routeProps = routes[key].match(path, qs)
    if(routeProps){
        route = key
          break;
    }
  }
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }


  addRemoteProps(browserState).then(
    (props) => {
      browserState = props
      //Log our new browserState
      console.log("BROWSER RRRR ",browserState)
      //Render our components using our remote data
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
    }, 
    (res) => {
      console.log("RES",res);
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code}/>, document.getElementById('root'))
    })
    

  /*
    addRemoteProps(browserState)
  //If we don't have a match, we render an Error component
  if(!route)
    return ReactDOM.render(<ErrorPage message={"Not Found 404BOUM"} code={404}/>, document.getElementById('root'))
  
  ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))*/
  
}



function addRemoteProps(props){
  

  var remoteProps = Array.prototype.concat.apply([],
    props.handlerPath
      .map((c)=> c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
      .filter((p)=> p) 
  );
  console.log("RMT PPS BEFORE",props,remoteProps);
  var remoteProps = remoteProps
      .map((spec_fun)=> spec_fun(props) ) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
                                // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
      .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url);
      
  if(remoteProps.length == 0)
    return props
  
  
  const promise_mapper = (spec) => {
    
    // we want to keep the url in the value resolved by the promise here. spec = {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
    return HTTP.get(spec.url).then((res) => { console.log("GETRETURN ",res);spec.value = res; return spec })
  }

  const reducer = (acc, spec) => {
    // spec = url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
    acc[spec.prop] = {url: spec.url, value: spec.value}
    return acc
  }
  console.log("RMT PPS AFTER",remoteProps.length,remoteProps[0].url);

  const promise_array = remoteProps.map(promise_mapper)
  console.log(promise_array);
  return Promise.all(promise_array)
    .then(xs => xs.reduce(reducer, props), (reject)=>console.log(reject))
    .then((p) => {
    // recursively call remote props, because props computed from
    // previous queries can give the missing data/props necessary
    // to define another query
    console.log("P " , p)
    //.then((p) => resolve(p),(e)=>reject(e))
    
    return addRemoteProps(p).then(resolve, reject)
  },
  reject)


};

window.addEventListener("popstate", ()=>{ onPathChange() })
onPathChange()