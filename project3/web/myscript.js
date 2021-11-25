$(document).ready(function() {
    $('#buttonClickMe').on('click',function(event){
        //myAlert("BOUM")
        createDiv("Hey I was created from React!","root")
    });
});

function createDiv(text,id){
    //let elem = React.createElement('div', {}, text) 
    let elem = <div>{text}</div>
    ReactDOM.render(elem, document.getElementById(id));
}
var test2 = () => {}

function myAlert(text){
    alert(text);
}