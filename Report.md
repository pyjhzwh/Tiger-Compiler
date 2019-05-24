# Report  

## 1 词法分析

## 1.1 正则表达式

## 1.2 正则表达式与Lex实现  

## 1.3 Tiger语法与Lex实现

Tiger语法是在Andrew W. Appel的书 *Modern Compiler Implementation in Java (Cambridge
University Press, 1998)* ，也叫“虎书”，中定义的一种语言。  

Tiger语法的关键词有

> array, break, do, else, end, for, function, if, in, let, nil, of, then, to, type, var, while



还支持以下标点和操作

>(, ), [, ], {, }, :, :=, ., ,, ;, *, /, +, -, =, <>, >, <, >=, <=, &, |

此外 Tiger 语法还支持Indentifiers( **id** and **tyId**), Integer literals(**intLit**),  String literals(**stringLit**)。以及空格、以/*开头、*/结尾的注释。 因此进行 lex 的正则解析处理如下： 首先排除无用字符，如空格，换行，以及注释等：