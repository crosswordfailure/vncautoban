# vncautoban
reads eventlog entries from tightvnc and autobans failed logins with the windows firewall

To have some fun this morning I wrote an autoban script in PowerShell for tightvnc. Tightvnc logs to the application log when there are failed logins. I also saw there was no built-in autoban feature.

I first played around with rules on my home router which has a port forward setup, but it wasn't very advanced for creating rules nor scalable. I realized the windows firewall is easy to manipulate with PowerShell, as is reading the windows event log.

The way I'm using it is it runs every 10 minutes, and it looks 10 minutes back in time worth of logs. If it sees an IP fail login 3 or more times, it will add them to the firewall rule. Create the rule first, then run the script. You'll need at least one IP in the rule, so either pick a real one that is currently hitting you or something fake that you would never need to work for vnc like 4.4.4.4. Also, set it to only block traffic for port 5900, not all traffic. False positives like if you yourself auth fail 3 times in the interval, will go in there and you'll just simply have to remove yourself from the rule. It also has nothing in there to age out ip addresses.

I wrote this and tested using PowerShell 6, if you aren't using it already I suggest trying it out. PowerShell 6 fixes things like get-item with long paths, and is a re-write of PowerShell 5 and older using .net core. It isn't a complete replacement yet as it doesn't have all the cmdlets from earlier versions but for most things it has what you need.

Future thought is crowd sourcing - having the script send its new hits to the net and use that data to have the scripts download popular blocks from other instances of it.

Please let me know if you use it so I know if enough people are to justify future work, and also to then notify who uses it should I add that. You can reach me with this same name on reddit.

2.15.2020 update-
I've been running mine where it autobans on first failure attempt ($freak.count -ge 1) because I notice that there are many single attempts. I've left the github copy at -ge 2, as you do have to be careful with -ge1 if you yourself fail once. I also saw where the rule was getting over 1000 entries, so I put logic both to create the first firewall rule, but also create a new one when a rule has 512 entries and timestamp the existing rule by renaming it.
