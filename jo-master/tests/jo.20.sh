# read json array elements

echo '{"a":1,"b":"val"}' > $$.1
echo '{"a":478,"b":"other"}' > $$.2

${JO:-jo} -a :$$.1 :$$.2

rm -f $$.1
rm -f $$.2
