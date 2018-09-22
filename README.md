# ParadiseOS

**Paradise OS** is a project to implement [Paradise](https://github.com/hundredrabbits/Paradise) as a file system/shell. It would be distributed as a small linux distro image, that boots into the Paradise shell, a terminal where a user can **embody vessels**, and **use actions** to create and modify their system, and interact with that of other's.

## Basics
- [Vessels](https://github.com/hundredrabbits/Paradise/blob/master/desktop/server/vessel.js) are files.
- [Actions](https://github.com/hundredrabbits/Paradise/blob/master/desktop/server/vessel.js) are applications.
- A user controls a vessel.
- Only vessels can act.

## Concept

There are no users, only vessel permissions. There are no applications, only actions.

## Implementation

- **Kernel**, in progress.
- **Shell**, done.
- **Vessel**, users and permissions management.
- **Action**, applications.
- **Wildcard**
- **Networking**, possibly datrs.

## Building GUI

The current flow for adding gui tools is via the `passive` trigger. The message will be appended to the passive UI element and updated as needed.

## Networking

Vessels can cross over to other instances.

```
warp to the library@172.20.10.2
say hello
```

## Resources

- [Operating Systems: Three Easy Pieces](https://www.cs.nmsu.edu/~pfeiffer/fuse-tutorial/)
- [OS Writing](https://wiki.osdev.org/Main_Page)
