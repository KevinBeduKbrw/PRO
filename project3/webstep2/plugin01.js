const { isLiteral } = require("babel-types");

module.exports = function (babel) {
  var t = babel.types;
  //console.log(babel);
  //babel.path.traverse(declarationHaveValueAttribute);
  return {
    name: "custom-jsx-plugin",
    visitor: {

      JSXElement(path) {
        //console.log(path.node);

        if(path.node.openingElement.name.name === "Declaration") {
          //path.traverse(declarationHaveValueAttribute)
          let decl = path.node.openingElement;
          if(decl.attributes.length === 2){

            let hasValue = null,hasVar=null;
            decl.attributes.forEach(function(attr){
              
              console.log(attr.value.type)
              if(attr.name.name === "value"){
                if(t.isJSXExpressionContainer(attr.value)){
                  hasValue=attr.value.expression.value
                }else if(t.isLiteral(attr.value)){
                  hasValue=attr.value.value
                }
              }
              if(attr.name.name === "var"){
                if(t.isLiteral(attr.value)){
                  hasVar=attr.value.value;
                }
              }
            });

            if(hasValue !== null && hasVar !== null){
              path.replaceWith(
                t.VariableDeclaration("var",[
                  t.variableDeclarator(
                    t.Identifier(hasVar),
                    typeof hasValue === "number" ? t.NumericLiteral(hasValue) : t.StringLiteral(hasValue)
                    )
                ])
              );
              
            }
            
          }
        
        }
      }
    }
  };
};
const getValue ={
  NumericLiteral(path){
    return "Numeric";
  },
  StringLiteral(path){
    return "string";
  }
}

const declaration_JSX ={
  JSXOpeningElement(path){
    
  }
}

const declarationHaveValueAttribute = {
  JSXAttribute(path) {
    
    if(path.node.name.name==="value"){
      //console.log(path.node)
      //console.log(path.node.value.loc)
      path.traverse(valueAttributeIsJSExpressionContainer);
    }
  }
};

const valueAttributeIsJSExpressionContainer = {
  JSXExpressionContainer(path){
    //console.log(path.node)
    path.traverse(switchJSXExpressionContainer)
  }
}

const switchJSXExpressionContainer = {
  Literal(path){
    path.replaceWithSourceString("LOOOOOOOL")
  }
}
// You can also create a visitor and add methods on it later
let visitor = {};
visitor.MemberExpression = function() {};
visitor.FunctionDeclaration = function() {}