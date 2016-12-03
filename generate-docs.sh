find src/kemalyst.cr src/kemalyst -type f | xargs crystal docs
rm -rf docs
mv doc docs
