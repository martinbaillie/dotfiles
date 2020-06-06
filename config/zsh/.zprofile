# Build the environment.
source ${ZDOTDIR}/env.zsh
for file in ${ZDOTDIR}/rc.d/env.*.zsh(N); do
  source ${file}
done

# De-duplicate and export a final PATH.
PATH="$(perl -e 'print join(":", grep {not $s{$_}++} split(/:/, $ENV{PATH}))')"
export PATH
