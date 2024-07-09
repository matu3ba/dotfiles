# Install opam with ocaml
git clone https://github.com/rems-project/cerberus
opam install --deps-only ./cerberus-lib.opam ./cerberus.opam
make
make install DESTDIR=$HOME/.local/cerberus
echo 'PATH=${PATH}:"$HOME/.local/cerberus/bin"' >> ~/.bashrc
eval (opam env)
cerberus --help