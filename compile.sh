JSDIR="app/js"

for f in $JSDIR/*.coffee
do
    filebase=$(basename $f)
    filext="${filebase##*.}"
    filename="${filebase%.*}"
    echo "Compiling $f to $JSDIR/$filename-full.js"
    coffee -cblp $JSDIR $f > $JSDIR/$filename-full.js
    echo "Compressing $JSDIR/$filename-full.js to $JSDIR/$filename.js"
    java -jar compiler.jar --angular_pass \
        --js $JSDIR/$filename-full.js \
        --js_output_file $JSDIR/$filename.js \
        --compilation_level WHITESPACE_ONLY
done
