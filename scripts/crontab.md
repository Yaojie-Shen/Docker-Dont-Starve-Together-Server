# crontab

Every time the game is updated, the server needs to be restarted after the update before new clients can connect. 
To avoid frequent manual restarts, you can set up a scheduled restart. 
The following crontab configuration automatically restarts the server every day at 6:00 a.m.:

```
0 6 * * * docker restart dst_master dst_caves
```

It’s important to note that the game must be saved before logging out; otherwise, up to one day of game progress may be lost.

 - [ ] TODO: Announcements and auto-save before restart

