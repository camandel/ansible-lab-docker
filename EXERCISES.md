# Exercises
### Table of content
- [EX01 - Inventory](#EX01-Inventory)
- [EX02 - Commands](#EX02-Commands)
- [EX03 - Loops](#EX03-Loops)
- [EX04 - Loops](#EX04-Loops)
- [EX05 - Templates](#EX05-Templates)
- [EX06 - Tasks](#EX06-Tasks)
- [EX07 - Variables](#EX07-Variables)
- [EX08 - Imports](#EX08-Imports)
- [EX09 - Filters](#EX09-Filters)
- [EX10 - Loadbalancer](#EX10-Loadbalancer)
- [EX11 - Application](#EX11-Application)
### EX01 Inventory
Create an inventory with these groups (g) and hosts (h):
```
us (g):
  florida (g):
    miami (h)
    orlando (h)
  california (g):
    los-angeles (h)
    san-diego (h)
eu (g):
  italy (g):
    turin (h)
    milan (h)
  germany (g):
    berlin (h)
    munich (h)
```
and assign correct "currency" variables (dollar/euro).

[View exercise solution](#SL01-Inventory)

### EX02 Commands
Check hosts connections and display uptime for all servers. Install vim-enhanced on host01.

[View exercise solution](#SL02-Commands)

### EX03 Loops
Create a playbook that install curl, wget and vim-enhanced on all servers.

[View exercise solution](#SL03-Loops)

### EX04 Loops
Create 3 users called user[1-3]. Each user should use /bin/sh as their default shell. Create a home directory with the same name as the user for each. Each user is part of a different group (group[1-3]).

[View exercise solution](#SL04-Loops)

### EX05 Templates
When a user logs in, a standard message from /etc/motd is displayed. Modify that message to welcome the user and display some information about the system like the following:
- hostname
- processors
- memory

[View exercise solution](#SL05-Templates)

### EX06 Tasks
Write a playbook with three tasks (you can use debug module) and find a way to only run one or two of them? 

[View exercise solution](#SL06-Tasks)

### EX07 Variables
Find a way to pass variable to ansible playbook in the command line (set a default to "Null" if the variable is undefined).

[View exercise solution](#SL07-Variables)

### EX08 Imports
Write a playbook and import tasks based on the OS that installs apache on Debian (apt and apache2) and Red Hat distributions (yum and httpd).

[View exercise solution](#SL08-Imports)

### EX09 Filters
NOTE: this exercise requires ansible >= 2.8

Create 3 directories /tmp/dir[1-3], inside them create other 3 sub-directories (/tmp/dir1/sub[1-3]) and finally create 3 files inside every sub-dir (/tmp/dir1/sub1/file[1-3])

[View exercise solution](#SL09-Filters)

### EX10 Loadbalancer
Write a playbook that installs httpd on host01 and host01, creates an index html that indicates the hostname. Then use nginx on host03 to balance the two web servers:
- web: host0[1-2]
- lb: host03

[View exercise solution](#SL10-Loadbalancer)

### EX11 Application
Install mariadb, create a db and one user then populate the db with data on host03. Write a simple python app that connects to the db and shows a table with all data (on host02). Finally use nginx on host01 as front-end to host02.
- fe: host01
- be: host02
- db: host03

[View exercise solution](#SL11-Application)

## Solutions
### SL01 Inventory
myinv file:
```
[california]
los-angeles
san-diego

[florida]
miami
orlando

[italy]
turin
milan

[germany]
berlin
munich

[us:children]
california
florida

[eu:children]
italy
germany

[us:vars]
currency=dollar

[eu:vars]
currency=euro
```
Show all hosts:
```
# ansible --list-hosts -i myinv all
  hosts (8):
    milan
    turin
    berlin
    munich
    miami
    orlando
    los-angeles
    san-diego
```
same thing but in yaml:
```
# ansible-inventory -i myinv --list --yaml
all:
  children:
    eu:
      children:
        germany:
          hosts:
            berlin:
              currency: euro
            munich:
              currency: euro
        italy:
          hosts:
            milan:
              currency: euro
            turin:
              currency: euro
    ungrouped: {}
    us:
      children:
        california:
          hosts:
            los-angeles:
              currency: dollar
            san-diego:
              currency: dollar
        florida:
          hosts:
            miami:
              currency: dollar
            orlando:
              currency: dollar
```
Show hosts in "california" group:
```
# ansible --list-hosts -i myinv california
  hosts (2):
    los-angeles
    san-diego
```
Show them in a graphical layout:
```
# ansible-inventory -i myinv --graph
@all:
  |--@eu:
  |  |--@germany:
  |  |  |--berlin
  |  |  |--munich
  |  |--@italy:
  |  |  |--milan
  |  |  |--turin
  |--@ungrouped:
  |--@us:
  |  |--@california:
  |  |  |--los-angeles
  |  |  |--san-diego
  |  |--@florida:
  |  |  |--miami
  |  |  |--orlando
```
### SL02 Commands
```
ansible-doc -l
ansible all -m ping
ansible-doc command
ansible all -a "uptime"
ansible-doc yum
ansible host01 -m yum -a "name=vim-enhanced state=installed"
```
### SL03 Loops
User a loop with_item:
```
---
- hosts: all
  gather_facts: false
  tasks:
    - name: Install packages
      yum:
        name: "{{ item }}"
        state: present
      with_items:
        - vim-enhanced
        - curl
        - wget
```
With recent ansible releases use a list directly in "yum" module without any loop:
```
---
- hosts: all
  gather_facts: false
  tasks:
    - name: Install packages
      yum:
        name: [ "vim-enhanced", "curl", "wget" ]
        state: present
```
### SL04 Loops
```
---
- hosts: host01
  gather_facts: false
  tasks:
    - name: Create groups
      group:
        name: "{{ item }}"
        state: present
      with_list:
        - group1
        - group2
        - group3
    - name: Create users
      user:
        name: "{{ item.name }}"
        group: "{{ item.group }}"
        shell: "{{ item.shell }}"
        state: present
      with_list:
        - { name: user1, shell: /bin/sh, group: group1 }
        - { name: user2, shell: /bin/sh, group: group2 }
        - { name: user3, shell: /bin/sh, group: group3 }
```
### SL05 Templates
motd template:
```
motd.j2
 
Hostname: {{ ansible_fqdn }}
Processors: {{ ansible_processor_vcpus }}
Memory: {{ (ansible_memtotal_mb / 1024) | round(1) }} GB
```
and playbook:
```
- hosts: all
  gather_facts: false
  tasks:
    - name: modify motd
      template:
        src: motd.j2
        dest: /etc/motd
```
### SL06 Tasks
You create a playbook with tags:
```
- hosts: host01
  gather_facts: false
  tasks:
    - name: first task
      debug:
        msg: "my first task"
      tags: first
    - name: second task
      debug:
        msg: "my second task"
      tags: second
    - name: third task
      debug:
        msg: "my third task"
      tags: third
```
and execute tasks based on tags:
```
ansible-playbook /tmp/test.yml --tags second
```
### SL07 Variables
```
- hosts: host01
  gather_facts: false
  tasks:
    - name: debug variable
      debug:
        msg: "myvar = {{ myvar | default('Null') }}"
```
and pass the value via command line:
```
ansible-playbook -e myvar="myvalue" /tmp/test.yml
```
### SL08 Imports
playbook with imports:
```
- hosts: host01
  gather_facts: true
  tasks:
    - name: import task for Red Hat systems
      import_tasks: redhat.yml
      when: ansible_facts['os_family']|lower == 'redhat'
    - name: import task for Debian systems
      import_tasks: debian.yml
      when: ansible_facts['os_family']|lower == 'debian'
```
redhat.yml
```
- yum:
    name: "httpd"
    state: present
```
debian.yml
```
- apt:
    name: "apache2"
    state: present
```
### SL09 Filters
```
---
- hosts: host01
  gather_facts: false
  vars:
    dirs: ['dir1', 'dir2', 'dir3']
    subs: ['sub1', 'sub2', 'sub3']
    files: ['file1', 'file2', 'file3']
  tasks:
    - name: create directories
      file:
        path: "/{{ item[0] }}/{{ item[1] }}"
        state: directory
      loop: "{{ dirs | product(subs) | list }}"
    - name: create files
      file:
        path: "/{{ item[0][0] }}/{{ item[0][1] }}/{{ item[1] }}"
        state: touch
      loop: "{{ dirs | product(subs) | product(files) | list }}"
```
### SL10 Loadbalancer
Example code is [here](master/ansible/examples/lb-with-web/)

Test the final result from master01:
```
# curl http://host03
```
Or from the browser in you PC running vagrant:
```
http://localhost:8003 (port-forwarding to host03:80)
```
### SL11 Application
Example code is [here](master/ansible/examples/fe-be-db/)

Test the final result from master01:
```
# curl http://host01
```
Or from the browser in you PC running vagrant:
```
http://localhost:8001 (port-forwarding to host01:80)
```
