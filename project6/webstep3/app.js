var Qs = require('qs')
var Cookie = require('cookie')
require('!!file-loader?name=js/jquery.js!./webflow/ressources/jquery-3.5.1.min.dc5e7f18c8.js')
require('!!file-loader?name=loader.gif!./webflow/ressources/loader.gif')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
var XMLHttpRequest = require("xhr2")
const { Children } = require('react')
//const { resolve } = require('path/posix')
/* required css for our application */
require("./webflow/ressources/chapitre4.webflow.812bac897.css");
require("./webflow/ressources/modal.css");

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
  },
  modal:(props=>{
      console.log("IN MODAL RT",this.props)
      return{
        url: "/api/delete/",
        prop: "orders"
      }
  })
}

var cn = function(){
  var args = arguments, classes = {}
  for (var i in args) {

    var arg = args[i]
    if(!arg) continue
    if ('string' === typeof arg || 'number' === typeof arg) {
      arg.split(" ").filter((c)=> c!="").map((c)=>{
        classes[c] = true
      })
    } else if ('object' === typeof arg) {
      for (var key in arg) classes[key] = arg[key]
    }
  }
  return Object.keys(classes).map((k)=> classes[k] && k || '').join(' ')
}

var HTTP = new (function(){
  this.get = (url)=>this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept","application/json,*/*;0.8")
    req.setRequestHeader("content-type","application/json")
    req.onload = ()=>{
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

var Layout = createReactClass(
  {
    getInitialState: function() {
      
    return {
      modal:false,
      load:null
    };
  },
  
  modal(spec){
    this.setState({modal: {
      ...spec, callback: (res)=>{
        
        if(res === true){
          this.loader(
            HTTP.delete("api/delete/"+this.state.modal.orderID).then((res) => {
              delete browserState.orders
              GoTo("orders",'','');
            },(err)=>console.log(err))
          );
        }

        this.setState({modal: null},()=>{
          if(spec.callback) spec.callback(res)
        })
      }
    }})
  },
  loader(promise){
    this.setState({load:<Loader {...this.props}/>});
    var p = new Promise(function(resolve, reject)
    {
      promise.then((val)=>{
        resolve("load resolve END");
      },
      (error)=>{
        reject("load error END")
      })
     
    }).then((res)=> {this.setState({load:null});});
    return p

  },
  render(){
    
    var _props = {
      ...this.props, modal: this.modal, load : this.state.load
    }

    var modal_component = {
      'delete': (props) => <DeleteModal {...props}/>
    }[this.state.modal && this.state.modal.type];
    modal_component = modal_component && modal_component(this.state.modal)

    //loader_component = loader_component && loader_component(this.state.loader)
    console.log("LOADER",this.state.load === null)

    return <JSXZ in="neworders" sel=".layout">
        <Z sel=".modal-wrapper" className={cn(classNameZ, {'hidden': !modal_component})}>
        {modal_component}
        </Z>
        <Z sel=".loader-wrapper" className={cn(classNameZ, {'hidden': this.state.load === null})}>
        {this.state.load}
        </Z>
        <Z sel=".layout-container">
          <Child {..._props}/>
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
  alertTest(){
    alert("OK");
  },
  goToOrderDetail(event){
    let id = $(event.target).parents(".linemainarraybody").children(".col-1").text()
    GoTo("order",id,'');
  },
  showLoader(event){
    this.props.loader({loader:true});
  },
  deleteOrder(event){
    this.props.modal({
      type: 'delete',
      title: 'Order deletion',
      message: `Are you sure you want to delete this ?`,
      orderID: $(event.target).parents(".linemainarraybody").children(".col-1").text(),
      callback: (value)=>{
        console.log("SETSTATE",value)
      }
    })
  },
  render(){
/*
    */

    return <JSXZ in="neworders" sel=".containerr">
        <Z sel=".mainarraybody">
        
        {this.props.orders.value.map( order => (
          <JSXZ in="neworders" sel=".linemainarraybody" key={order.remoteid}>
            <Z sel=".col-1" onClick={this.alertTest}>{order.remoteid}</Z>
            <Z sel=".col-2">{order.custom.customer.full_name}</Z>
            <Z sel=".col-3">{order.custom.billing_address}</Z>
            <Z sel=".col-4">{order.items}</Z>  
            <Z sel=".col-5">
            <JSXZ in="neworders" sel=".iconarrowrightcoldetails" onClick={this.goToOrderDetail}>
                
                </JSXZ>  
              </Z> 
            <Z sel=".col-7">
              <JSXZ in="neworders" sel=".icondeletearray" onClick={this.deleteOrder}>
                
              </JSXZ>  
            </Z> 
          </JSXZ>
        ))}
      </Z>
      </JSXZ>
  }
});

var Order = createReactClass(
  {statics: {
    remoteProps:[remoteProps.order] 
  },
  goBackToOrders(event){
    GoTo("orders",'','');
  },
 
  render(){
    console.log(this.props.order.value)
    let ord =this.props.order.value;
    return <JSXZ in="neworder" sel=".containerr">
        <Z sel=".informationsbar">
          <JSXZ in="neworder" sel=".leftinformationsbar" >
            
            
          </JSXZ>
          <JSXZ in="neworder" sel=".rightinformationsbar" >
            
            <Z sel=".customername_informationbar">{ord.custom.customer.full_name}</Z>
            <Z sel=".address_informationbar">{ord.custom.billing_address}</Z>
            <Z sel=".idnumber_informationbar">{ord.remoteid}</Z>
          </JSXZ>
        </Z>
        <Z sel=".containergoback">
        <JSXZ in="neworder" sel=".gobackorderbutton" onClick={this.goBackToOrders}>
        </JSXZ> 
        </Z>
      </JSXZ>
  }
});

var ErrorPage= createReactClass({
  render(){
    return <div>{this.props.message}</div>;
  }
});

var Loader= createReactClass({
  render(){
    console.log('in LOADER MODAL')
    return <JSXZ in="loader" sel=".loader-content">
      
    </JSXZ>
  }
});

var DeleteModal = createReactClass({
  yesModal(){
    this.props.callback(true);
  },
  noModal(){
    this.props.callback(false);
  },
  render(){
    console.log('in DELETE MODAL')
    return <JSXZ in="modal" sel=".modal-content">
      <Z sel=".titlemodal">{this.props.title}</Z>
      <Z sel=".messagemodal">{this.props.message}</Z>
      <Z sel=".buttonyesmodal" onClick={this.yesModal}><ChildrenZ></ChildrenZ></Z>
      <Z sel=".buttonnomodal" onClick={this.noModal}><ChildrenZ ></ChildrenZ></Z>
    </JSXZ>
  }
})

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
      //Render our components using our remote data
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))

      console.log("browserState",browserState);
      /*
      playThing = this.props.modal({
        modal:false,
        callback:()=>{console.log("CALLBACK")}
      });*/
    }, 
    (res) => {
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
  
  return new Promise((resolve, reject)=>{
  var remoteProps = Array.prototype.concat.apply([],
    props.handlerPath
      .map((c)=> c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
      .filter((p)=> p) 
  );

  var remoteProps = remoteProps
      .map((spec_fun)=> spec_fun(props) ) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
                                // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
      .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url);
      
  if(remoteProps.length == 0)
    return resolve(props);
  
  
  const promise_mapper = (spec) => {
    
    // we want to keep the url in the value resolved by the promise here. spec = {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
    return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
  }

  const reducer = (acc, spec) => {
    // spec = url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
    acc[spec.prop] = {url: spec.url, value: spec.value}
    return acc
  }
  const promise_array = remoteProps.map(promise_mapper)

  return Promise.all(promise_array)
    .then(xs => xs.reduce(reducer, props), (reject)=>console.log(reject))
    .then((p) => {
    // recursively call remote props, because props computed from
    // previous queries can give the missing data/props necessary
    // to define another query
    return addRemoteProps(p).then(resolve, reject)
  },
  reject)

  })
};

window.addEventListener("popstate", (event)=>{
  onPathChange()
 })

 onPathChange()
 //GoTo(location.pathname,"",location.search)
//onPathChange()



