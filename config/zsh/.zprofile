# Tool-specific environment.
for file in ${ZDOTDIR}/rc.d/env*.zsh(N); do
    source ${file}
done
