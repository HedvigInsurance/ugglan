TMPDIR=/tmp

function runLokalise() {
    DEST=$TMPDIR/$(uuidgen)
    mkdir $DEST
    $TMPDIR/lokalise2 file download --project-id 743091915e9da969db9340.20943733 --token 4fe9c836530f3f946d86ce5cef36fb74ec437f56 --dest $DEST --format strings --unzip-to "./Projects/hCore/Resources" --placeholder-format ios --filter-langs en,sv_SE --escape-percent 1
}

if [[ -f $TMPDIR/lokalise2 ]]
then
    runLokalise
    exit 0
fi

curl -sfL https://raw.githubusercontent.com/lokalise/lokalise-cli-2-go/master/install.sh | sh

mv ./bin/lokalise2 /tmp/lokalise2

runLokalise
