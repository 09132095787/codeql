cargo build --release

cargo run --release -p ruby-generator
codeql query format -i ql\src\codeql_ruby\ast\internal\TreeSitter.qll

rm -Recurse -Force extractor-pack
mkdir extractor-pack | Out-Null
cp codeql-extractor.yml, ql\src\ruby.dbscheme, ql\src\ruby.dbscheme.stats extractor-pack
cp -Recurse tools extractor-pack
mkdir extractor-pack\tools\win64 | Out-Null
cp target\release\ruby-extractor.exe extractor-pack\tools\win64\extractor.exe
