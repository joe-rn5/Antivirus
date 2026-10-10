# Lab 2: Simple Antivirus Daemon

## Overview

In this lab I built a simplified antivirus daemon: a shell script that periodically checks a directory for changes, and when a change is detected, scans the directory for files it considers malicious.
Malicious files are flagged, printed to the terminal, quarantined into a separate directory, and removed from the original location. 
I also built a restore tool that lets a user pick quarantined files from a list, one at a time, and decide whether each was falsely flagged or genuinely
malicious.

## Folder Structure

```text
OS-lab2/
├── antivirusd.sh
├── antivirus-cron.sh
├── restore.sh
├── Makefile
└── README.md
```
- The make command creates malicious_dir/ if needed. 
- I must create dir/ myself before running the scripts. 
- The whitelist.txt file is created when a file is successfully restored through the restore tool.

## Prerequisites
```
Tools needed: bash 4+, make, grep, coreutils, cron

The Ubuntu install command: 
sudo apt update
sudo apt install -y make cron

The Ubuntu version: (after run " lsb_release -a ")
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.5 LTS
Release:	24.04
Codename:	noble

```

## Running the Antivirus Daemon

1. **Make the scripts executable:**
    Open a terminal in the project directory and run:

    ```
    chmod +x antivirusd.sh restore.sh antivirus-cron.sh
    ```
2. **Prepare the directories:**
    create the monitored directory
    ```
    mkdir -p dir
    ```

3. **Start the antivirus daemon:**

     You can start it using the Makefile:

    ```
    make run

    Or, run the script directly:
    
    ./antivirusd.sh dir malicious_dir 2
    ```

4. **Understand the arguments:**

   - `dir`: The directory to monitor.

   - `malicious_dir`: The directory where detected malicious files are quarantined.

   - `2`: The interval, in seconds, between directory checks.



5. **Monitor the daemon.**

   The daemon checks for directory changes and scans files when a change is detected. When it finds a malicious file, it copies the file into `malicious_dir/`, deletes the original if the copy succeeds, and prints a message such as:

   ```
   test.exe is malicious and it is DELETED
   ```


## Running the Restore Tool

1. **Open a second terminal**
2. **Start the restore :** Run -> ./restore.sh dir malicious_dir
3. **Choose a file**
4. **Choose an action for the file**

## Flagged Extensions and Keywords
The antivirus identifies malicious files using 2 criteria: file extensions and keywords found in file contents
**The Flagged Extensions:**
- `.exe`
- `.bat`
- `.vbs`
- `.scr`
- `.ps1`
<hr>

**Flagged Keywords:**
- `virus`
- `malware`
- `trojan`
- `worm`
- `ransomware`

**Where the Lists Are Defined:**
After the final code edits, run these commands to find the exact line numbers:
```
grep -n "extensions=" antivirusd.sh
grep -n "keywords=" antivirusd.sh
```

## How Detection Works

The antivirus uses `ls -l` to record the directory contents and `cmp` to compare the latest snapshot with the previous one. When a change is detected, the daemon scans the files and copy any malicious files to the quarantine directory. After scanning, it updates `directory-info.last` for the next compare.

## Bonus 1: Cron Job

The `antivirus-cron.sh` script performs one scan and then exits. Cron runs it automatically every minute, while `sleep 23` delays the scan by approximately 23 seconds. The output and errors are saved in `cron.log`.

To configure cron:

1. Install and start cron
    ```
    sudo apt update
    sudo apt install -y cron
    sudo systemctl enable --now cron
    ```
2. Make the script executable
    ```
    chmod +x antivirus-cron.sh
    ```
3. Open the crontab
    ```
    crontab -e
    ```
4. Add the scheduled command
    ```
    * * * * * /absolute/path/to/OS-lab2/antivirus-cron.sh /absolute/path/to/OS-lab2/dir /absolute/path/to/OS-lab2/malicious_dir >> /absolute/path/to/OS-lab2/cron.log 2>&1
    ```

Cron’s schedule has five fields:
```
minute  hour  day-of-month  month  day-of-week
```

**For the third Friday of each month at 12:31 AM:**
The 3rd Friday on a day between 15 to 21 
```
31 0 15-21 * * [ "$(date +\%u)" = 5 ] && /absolute/path/to/OS-lab2/antivirus-cron.sh /absolute/path/to/OS-lab2/dir /absolute/path/to/OS-lab2/malicious_dir >> /absolute/path/to/OS-lab2/cron.log 2>&1
```


## Bonus 2: Whitelist

When a user restores a file using option 1 in `restore.sh`, its filename is added to `whitelist.txt`. During future scans, `antivirusd.sh` checks this file and skips any matching filename.

The whitelist is stored on disk, so its entries remain available after the daemon restarts. However, the whitelist checks filenames only, meaning another file with the same name will also be skipped.