var Qs = require('qs')
var Cookie = require('cookie')

/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')
var XMLHttpRequest = require("xhr2")
const { Children } = require('react')

require('!!file-loader?name=js/jquery.js!./webflow/ressources/jquery-3.5.1.min.dc5e7f18c8.js')
require('!!file-loader?name=loader.gif!./webflow/ressources/loader.gif')
require("./webflow/ressources/chapitre4.webflow.812bac897.css");
require("./webflow/ressources/modal.css");

var browserState = {Child: Child}

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
  }
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
        
        {orders.map( (order,i) => (
          <JSXZ in="orders" sel=".linemainarraybody" key={i}>
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
        this.setState({modal: null},()=>{
          if(spec.callback) spec.callback(res)
        })
      }
    }})
  },
  loader(promise){
    this.setState({
      load:<Loader {...this.props}/>
    });
    var p = new Promise(function(resolve, reject)
    {
      promise.then((val)=>{
        resolve(val);
      },
      (error)=>{
        resolve(error)
      })
     
    }).then((res)=> {  
        this.setState({load:null});   
    });
      
    return p

  },
  render(){
    console.log("LAYOUT " , this.props,browserState)
    var _props = {
      ...this.props, modal: this.modal, loader : this.loader
    }

    var modal_component = {
      'delete': (props) => <DeleteModal {...props}/>
    }[this.state.modal && this.state.modal.type];

    modal_component = modal_component && modal_component(this.state.modal)

    //loader_component = loader_component && loader_component(this.state.loader)
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
    console.log("HEADER " , this.props)
    return <JSXZ in="neworders" sel=".header">
      
        <Z sel=".header-container">
          <Child {...this.props}/>
        </Z>
      </JSXZ>
  }
});

var Orders = createReactClass(
  {
    getInitialState: function() {
      
    return {
      searchValue:"",
      searchPage:1
    };
    
  },
  statics: {
    remoteProps:[remoteProps.orders] 
  },
  alertTest(){
    alert("OK");
  },
  search(){


      var req = "api/kbedu_orders?page="+this.state.searchPage+"&rows=30&type=nat_order&query=" + (typeof this.state.searchValue === "undefined" ? "*" : this.state.searchValue)
      this.props.loader(
        HTTP.get(req).then((res) => {
          browserState={
            ...browserState,
            orders :{
              url : browserState.orders.url,
              value: res
            }
          }

          GoTo("orders");
          return res
        },(err)=>console.log("XX",err))
      )

    
  },
  pageNumberChanged(number){
    if(this.state.searchPage <= 1 && number === -1){
      return;
    }
    if(this.state.searchPage <= 2 && number === -2){
      return;
    }
    this.setState({
      searchPage:this.state.searchPage + number
      },()=>{this.search()})
  },
  goToOrderDetail(event){
    //let id = $(event.target).parents(".linemainarraybody").children(".col-1").text()
    GoTo("order",id,'');
  },
  
  render(){
    console.log("ORDERS",this.props)
    return <JSXZ in="neworders" sel=".containerr">
        <Z sel=".mainarraybody">
        
        {this.props.orders.value.map( order => (
          <JSXZ in="neworders" sel=".linemainarraybody" key={order.id}>
            <Z sel=".col-1">{order.id}</Z>
            <Z sel=".col-2">{order.custom.customer.full_name}</Z>
            <Z sel=".col-3">{order.custom.billing_address.street[0]}</Z>
            <Z sel=".col-4">{ order.custom.items.reduce((p,n)=> p+n.quantity_to_fetch, 0)  }</Z>  
            <Z sel=".col-5">
            <JSXZ in="neworders" sel=".iconarrowrightcoldetails" onClick={()=>{GoTo("order",order.id,'')}}>
                
                </JSXZ>  
              </Z> 
            <Z sel=".col-7">
              <JSXZ in="neworders" sel=".icondeletearray" onClick={()=>{

                this.props.modal({
                  type: 'delete',
                  title: 'Order deletion',
                  message: `Are you sure you want to delete this ?`,
                  callback: (value)=>{
                    if(value === true){
                      this.props.loader(
                        HTTP.delete("api/delete/"+order.id).then(
                          (res)=>{
                            delete browserState.orders
                            GoTo("orders")
                            return true
                          },
                          (rej)=>{
                            console.log("ERROR",rej)
                            return false
                          }
                        )
                      )
                    }
                  }
                })

              }}>
                
              </JSXZ>  
            </Z> 
          </JSXZ>
        ))}
      </Z>
      <Z sel=".text-field" onKeyPress={(event)=>{
        if(event.charCode === 13){
          this.search()
        }
      }} 
      onChange={(event)=>{this.setState({searchValue:$(event.target).val()})}}>
        <ChildrenZ></ChildrenZ>
      </Z>
      <Z sel =".w-button" onClick={this.search}>
        <ChildrenZ></ChildrenZ>
      </Z>
        <Z sel=".labelpagenumber-1" onClick={(e)=>{this.pageNumberChanged(-2);}}>
          {this.state.searchPage == 1 || this.state.searchPage == 2 ? "" : this.state.searchPage-2 }
        </Z>
        <Z sel=".labelpagenumber-2" onClick={()=>{this.pageNumberChanged(-1);}}>
          {this.state.searchPage == 1 ? "" : this.state.searchPage -1 }
        </Z>
        <Z sel=".labelpagenumber-3">{this.state.searchPage}</Z>
        <Z sel=".labelpagenumber-4" onClick={()=>{this.pageNumberChanged(1);}}>
          {this.state.searchPage + 1}
        </Z>
        <Z sel=".labelpagenumber-5" onClick={()=>{this.pageNumberChanged(2);}}>
          {this.state.searchPage + 2}
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
    
    let ord =this.props.order.value;
    return <JSXZ in="neworder" sel=".containerr">
        <Z sel=".informationsbar">
          <JSXZ in="neworder" sel=".leftinformationsbar" >
            
            
          </JSXZ>
          <JSXZ in="neworder" sel=".rightinformationsbar" >
            
            <Z sel=".customername_informationbar">{ord.length === 0 ? "" : ord.custom.customer.full_name}</Z>
            <Z sel=".address_informationbar">{ord.length === 0 ? "" :ord.custom.customer.email}</Z>
            <Z sel=".idnumber_informationbar">{ord.length === 0 ? "" :ord.id}</Z>
          </JSXZ>
        </Z>
        <Z sel=".containergoback">
          <JSXZ in="neworder" sel=".gobackorderbutton" onClick={()=>{GoTo("orders",'','')}}>
          </JSXZ> 
        </Z>
        <Z sel=".mainarraybody">
        {
        ord.length === 0 ? "" : 
        ord.custom.items.map( (order,i) => (
          <JSXZ in="neworder" sel=".linemainarraybody" key={i}>
            <Z sel=".col-1">{order.product_title}</Z>
            <Z sel=".col-2">{order.quantity_to_fetch}</Z>
            <Z sel=".col-3">{order.unit_price}</Z>
            <Z sel=".col-4">{order.quantity_to_fetch * order.unit_price}</Z> 
          </JSXZ>
        ))}
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
    return <JSXZ in="modal" sel=".modal-content">
      <Z sel=".titlemodal">{this.props.title}</Z>
      <Z sel=".messagemodal">{this.props.message}</Z>
      <Z sel=".buttonyesmodal" onClick={this.yesModal}><ChildrenZ></ChildrenZ></Z>
      <Z sel=".buttonnomodal" onClick={this.noModal}><ChildrenZ ></ChildrenZ></Z>
    </JSXZ>
  }
})



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
    }, 
    (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code}/>, document.getElementById('root'))
    })
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




