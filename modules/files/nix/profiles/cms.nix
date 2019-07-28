with import <nixpkgs> {
  overlays = [
    (self: super:
      let
        inherit (super.python36Packages) buildPythonPackage fetchPypi;
      in

      {
        python36Packages = (super.python36Packages or {}) // rec {
          django-jenkins = buildPythonPackage rec {
            pname = "django-jenkins";
            version = "0.110.0";

            src = fetchPypi {
              inherit pname version;
              sha256 = "0mhrnki73sk705aldj4k1ssl13qw6j2fbz41wxvxr41w6a3i98d8";
            };

            doCheck = false;

            propagatedBuildInputs = with self.python36Packages; [ django ];
          };

          pip-review = buildPythonPackage rec {
            pname = "pip-review";
            version = "1.0";

            src = fetchPypi {
              inherit pname version;
              sha256 = "0bm8fj0ybi5gbv3qk3f3gcbq6y65fjslw0przc67s2abgr2qqdma";
            };

            doCheck = false;

            propagatedBuildInputs = with self.python36Packages; [ packaging pip ];
          };

          astroid = super.python36Packages.astroid.overridePythonAttrs (old: rec {
            version = "2.2.5";

            src = fetchPypi {
              inherit (old) pname;
              inherit version;
              sha256 = "1x5c8fiqa18frwwfdsw41lpqsyff3w4lxvjx9d5ccs4zfkhy2q35";
            };

            propagatedBuildInputs = with self.python36Packages; old.propagatedBuildInputs ++ [ typed-ast ];
          });

          pylint = super.python36Packages.pylint.overridePythonAttrs (old: rec {
            version = "2.3.1";

            src = fetchPypi {
              inherit (old) pname;
              inherit version;
              sha256 = "1wgzq0da87m7708hrc9h4bc5m4z2p7379i4xyydszasmjns3sgkj";
            };

            doCheck = false;

            propagatedBuildInputs = with self.python36Packages; [ astroid isort mccabe ];
          });

          pylint-plugin-utils = buildPythonPackage rec {
            pname = "pylint-plugin-utils";
            version = "0.5";

            src = fetchPypi {
              inherit pname version;
              sha256 = "0x0bpbvfjhqixz15nz7469m8jdaj9as3dwghw41h0ywbxbak37ld";
            };

            propagatedBuildInputs = with self.python36Packages; [ pylint ];
          };

          pylint-django = buildPythonPackage rec {
            pname = "pylint-django";
            version = "2.0.9";

            src = fetchPypi {
              inherit pname version;
              sha256 = "1xbnmsh3d820am2blrpc5cl371il66182z80dni9gp7vpxi2amn0";
            };

            doCheck = false;

            propagatedBuildInputs = with self.python36Packages; [ pylint-plugin-utils pylint ];
          };
        };
      }
    )
  ];
};

with python36Packages;

mkShell {
  buildInputs = [
    python

    astroid
    coverage
    django
    django-jenkins
    entrypoints
    flake8
    isort
    lazy-object-proxy
    mccabe
    mysqlclient
    packaging
    pep8
    pip-review
    pycodestyle
    pyflakes
    pylint
    pylint-django
    pylint-plugin-utils
    pyparsing
    pytz
    six
    sqlparse
    typed-ast
    wrapt
  ];

  shellHook = ''
    ln -snf ${python}/bin/python python > /dev/null
  '';
}
