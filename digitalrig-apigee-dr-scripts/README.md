## Base common Ansible components for everything else

### Ansible Lint usage

Install https://github.com/metacloud/molecule/[molecule] and execute

```bash

# generate sample molecule configuration
ls -1 roles | xargs -I {} bash -c "cd roles/{} && if [ ! -f molecule.yml ]; then molecule init --driver=docker; fi"
# execute ansible-lint
ls -1 roles | xargs -I {} bash -c "echo 'Testing {}' && cd roles/{} && molecule verify"

```

### Next steps

. Use molecule to test roles
. Replace outdated role definitions with ansible-galaxy references
