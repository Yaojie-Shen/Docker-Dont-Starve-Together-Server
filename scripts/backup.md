# Backup and Packaging

Although the game provides save history, regular manual backups are recommended.
Backups are also useful for uploading and downloading save data to/from a server.

This script packages the entire project directory into a single compressed archive for backup and transfer purposes.

The script is located at:

```
scripts/backup.sh
```

## Usage

```bash
$ ./scripts/backup.sh -h
Usage: backup.sh [options]

Options:
  -p, --prefix PREFIX     Backup filename prefix (default: dst)
  -d, --dir DIR           Backup output directory (default: <project_parent>/backup)
  -y, --yes               Assume yes; skip confirmation
  -h, --help              Show this help message
```

## Save Directory Layout

By default, the archive is saved to a backup/ directory at the same level as the project directory. For example:

```
.
├── Docker-Dont-Starve-Together-Server/ # project directory
│   ├── scripts/
│   │   └── backup.sh
│   ├── config/
│   └── ...
└── backup/
    └── dst_250601T1121.tar.gz # output
```

**Note**: This script determines the project directory by taking the parent directory of the folder where the script is located.
For this reason, the script must remain in `scripts/backup.sh` and should not be moved.

## Examples

Basic usage (with confirmation):

```bash
./scripts/backup.sh
```

Custom prefix:

```bash
./scripts/backup.sh -p prod
```

Custom output directory:

```bash
./scripts/backup.sh -d /mnt/backups
```

