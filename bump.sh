 if [ -z "$1" ]; then
    echo 'usage ./bump.sh [<newversion> | major | minor | patch | premajor | preminor | prepatch | prerelease | from-git]'
    exit 0
fi
if git diff-index --quiet HEAD --; then
    make compile-std
    cd elchemy-core
    sed -i "" "s/$SEMVER/$VER/g" mix.exs
    git pull origin master
    git commit -am "Release $VER"
    git tag $VER
    git push origin master $VER
    mix archive.build
    mix archive.install "elchemy-$VER.ez"

    cd ..
    git pull origin master
    npm version $1
    SEMVER='[0-9][0-9]*\.[0-9][0-9]*\.[0-9]*'
    VER=`npm ls | grep -o $SEMVER`
    sed -i "" "s/$SEMVER/$VER/g" src/Compiler.elm
    make compile
    make release

    sed -i "" "s/name\": \"elchemy\"/name\": \"elmchemy\"/g" package.json
    npm publish
    sed -i "" "s/name\": \"elmchemy\"/name\": \"elchemy\"/g" package.json
    npm publish

    git commit -am "Release $VER"
    git tag $VER
    git push origin master $VER
else
    echo "Git directory must be clean"
    exit 1
fi
