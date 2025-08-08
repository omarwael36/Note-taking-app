# note_app (Ansible Role)

Deploys the Flask Note Taking App with SQLite and systemd (Gunicorn).

## Variables

- `note_app_repo_url` (string, required): Git repo URL of the app
- `note_app_repo_version` (string, default: `main`)
- `note_app_user`/`note_app_group` (default: `noteapp`)
- `note_app_base_dir` (default: `/opt/noteapp`)
- `note_app_bind_host` (default: `0.0.0.0`)
- `note_app_bind_port` (default: `80`)
- `note_app_secret_key` (string, required)
- `note_app_flask_config` (default: `production`)
- `note_app_env_extra` (dict, default: `{}`)

## Example Playbook

```yaml
- hosts: noteapp_hosts
  become: true
  vars:
    note_app_repo_url: https://github.com/youruser/Note-taking-app.git
    note_app_secret_key: super-secret
  roles:
    - note_app
```

## Galaxy

Update `meta/main.yml` with your `author`, `license`, and tags, then:

```bash
ansible-galaxy role build ansible/roles/note_app
ansible-galaxy role publish <generated-tarball> --token <GALAXY_API_TOKEN>
```


