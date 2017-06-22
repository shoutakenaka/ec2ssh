# ec2ssh

## How to install

* Install percol, inifile and AWS SDK for Ruby v2

```
pip install percol
gem install inifile aws-sdk
```

* Put ec2ssh to somewhere in exec path

## Usage

* Add your private key file to ssh-agent

```
ssh-add ~/.ssh/<YOUR_PRIVATE_KEY>.pem
```

* Run ec2ssh and select an instance you want to log in to

```
ec2ssh
```

## Options

| Option     | Description     |
| ---------- | --------------- |
| -f         | Flush cache     |
| -p PROFILE | Specify profile |
| -r REGION  | Specify region  |