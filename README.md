# buildkite-node
A buildkite agent to run multiple version nodejs test(WIP)

To run the agent

```
docker run -e BUILDKITE_AGENT_TOKEN="YOUR_TOKEN" fraserxu/buildkite-node
```

In order to be able to clone code from Github, you need to [enable Github repo access to the agent](https://buildkite.com/docs/guides/github-repo-access).

For me here I'm not in a team and do not want to create a new user, so I ssh into the box and generate public ssh key and add it to deploy key to my repo.

```
/ # mkdir -p ~/.ssh && cd ~/.ssh
~/.ssh # ssh-keygen -t rsa -b 4096 -C "xvfeng123@gmail.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:/KgUwinhS+SnWzKNomlgWtI7c4flTui+QqFdU6MriLY xvfeng123@gmail.com
The key's randomart image is:
+---[RSA 4096]----+
|                 |
|      o          |
|  o  o .         |
| +.o+. .         |
|.==o=o. S        |
|*+*B.o.. o       |
|*+Bo++o . .      |
|oE=*ooo.         |
|+ .*++o          |
+----[SHA256]-----+
~/.ssh # cat ~/.ssh/id_rsa.pub
```

### License
MIT
