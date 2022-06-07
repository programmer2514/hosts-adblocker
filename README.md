# Hosts File Adblocker
A simple script that installs an ad-blocking extension from the web to the Windows hosts file.

The hosts file can be found at `C:\Windows\System32\Drivers\etc\hosts`.

---

### Settings:
* Stored at `%AppData%\hosts-adblocker\hosts-adblocker.ini`.
* Options:
  * `hostsFileLength` - Length of hosts file before modification. Setting this incorrectly may lead to omission of custom blocking rules.
  * `blocklistURL` - URL of file to append to the hosts file. ___Make sure you trust this URL!___

---

### Backups:
* Stored at `%AppData%\hosts-adblocker\hosts.bak.<timestamp>`.
* A new backup is created _every time_ this script modifies the hosts file in any way.

---

### Arguments:
* `/S` - Run script in silent mode; suppresses reboot prompt upon success
  * Does _not_ suppress error messages
* `/P` - Purges all backup files
  * Moves files to Recycle Bin; does not permanently delete them
* `/U` - Uninstalls blocklist from hosts file
* `/?` - Displays the help dialog
