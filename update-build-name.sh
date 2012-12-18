#!/bin/bash -xe

LATEST=`curl -s http://download.eclipse.org/eclipse/downloads/ \
    | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' \
    | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' \
    | grep -e "I201[2-3]" \
    | grep -v testResults \
    | sed -e 's:^drops4/::' -e 's:/$::' \
    | sort -u \
    | tail -n1`

CURRENT=`xmllint --noblanks pom-parent.xml \
    | egrep -o '<build-name>[^>]+<\/build-name>' \
    | sed -e 's/<build-name>//' -e 's/<\/build-name>//'`

echo "LATEST=[$LATEST]"
echo "CURRENT=[$CURRENT]"

MESSAGE="Updated build-name to $LATEST"

if [[ "$LATEST" == "$CURRENT" ]]
then
    echo "Up to date"
elif [[ -n "$LATEST" && -n "$CURRENT" ]]
then
    cp pom-parent.xml pom-parent.xml.bak
    cat pom-parent.xml.bak | sed "s/$CURRENT/$LATEST/g" > pom-parent.xml
    git commit pom-parent.xml -m "$MESSAGE"
else
    echo "Something is wrong"
    exit 1
fi
